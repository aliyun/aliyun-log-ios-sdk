//
// Created by ZhangCheng on 20/11/2017.
//

#include "log_producer_client.h"
#include "log_producer_manager.h"
#include "inner_log.h"
#include "log_api.h"
#include <stdarg.h>
#include <string.h>
#include "log_persistent_manager.h"
#include "log_sds.h"

static uint32_t s_init_flag = 0;
static log_producer_result s_last_result = 0;

unsigned int LOG_GET_TIME();

// 优化后的恢复状态检查函数
static int check_recover_status_and_cache_log(log_persistent_manager * persistent_manager, 
                                              log_producer_manager * manager,
                                              int32_t pair_count, char ** keys, size_t * key_lens, 
                                              char ** values, size_t * val_lens, int flush)
{
    // 使用原子操作进行快速检查
    if (atomic_load(&persistent_manager->is_recovering) && !atomic_load(&persistent_manager->recover_completed))
    {
        // 需要缓存日志，此时才加锁
        CS_ENTER(persistent_manager->lock);
        
        // 双重检查，防止在加锁期间状态发生变化
        if (atomic_load(&persistent_manager->is_recovering) && !atomic_load(&persistent_manager->recover_completed))
        {
            // 构建日志数据用于缓存
            add_log_full(persistent_manager->builder, LOG_GET_TIME(), pair_count, keys, key_lens, values, val_lens);
            char * logBuf = persistent_manager->builder->grp->logs.buffer;
            size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
            clear_log_tag(&(persistent_manager->builder->grp->logs));
            
            // 缓存日志
            int cache_rst = log_persistent_manager_cache_log_during_recover(persistent_manager, logBuf, logSize, LOG_GET_TIME());
            CS_LEAVE(persistent_manager->lock);
            
            if (cache_rst == 0)
            {
                aos_debug_log("project %s, logstore %s, log cached during recover, size %d",
                              manager->producer_config->project,
                              manager->producer_config->logstore,
                              (int)logSize);
                return LOG_PRODUCER_OK;
            }
            else
            {
                aos_warn_log("project %s, logstore %s, failed to cache log during recover, fallback to memory mode, result %d",
                             manager->producer_config->project,
                             manager->producer_config->logstore,
                             cache_rst);
                // 缓存失败，降级到内存模式
                return log_producer_manager_add_log(manager, pair_count, keys, key_lens, values, val_lens, flush, -1);
            }
        }
        else
        {
            CS_LEAVE(persistent_manager->lock);
        }
    }
    
    // 如果恢复失败，也使用内存模式
    if (atomic_load(&persistent_manager->recover_completed) && !atomic_load(&persistent_manager->recover_success))
    {
        return log_producer_manager_add_log(manager, pair_count, keys, key_lens, values, val_lens, flush, -1);
    }
    
    return -1; // 需要继续正常处理
}

typedef struct _producer_client_private {

    log_producer_manager * producer_manager;
    log_producer_config * producer_config;
    log_persistent_manager * persistent_manager;

}producer_client_private ;

struct _log_producer {
    log_producer_client * root_client;
};

log_producer_result log_producer_env_init()
{
    // if already init, just return s_last_result
    if (s_init_flag == 1)
    {
        return s_last_result;
    }
    s_init_flag = 1;
    if (0 != sls_log_init())
    {
        s_last_result = LOG_PRODUCER_INVALID;
    }
    else
    {
        s_last_result = LOG_PRODUCER_OK;
    }
    return s_last_result;
}

void log_producer_env_destroy()
{
    if (s_init_flag == 0)
    {
        return;
    }
    s_init_flag = 0;
    sls_log_destroy();
}

log_producer * create_log_producer(log_producer_config * config, on_log_producer_send_done_function send_done_function, void *user_param)
{
    if (!log_producer_config_is_valid(config))
    {
        return NULL;
    }
    log_producer * producer = (log_producer *)malloc(sizeof(log_producer));
    log_producer_client * producer_client = (log_producer_client *)malloc(sizeof(log_producer_client));
    producer_client_private * client_private = (producer_client_private *)malloc(sizeof(producer_client_private));
    producer_client->private_data = client_private;
    client_private->producer_config = config;
    client_private->producer_manager = create_log_producer_manager(config);
    client_private->producer_manager->send_done_function = send_done_function;
    client_private->producer_manager->user_param = user_param;
    client_private->persistent_manager = create_log_persistent_manager(config);
    if (client_private->persistent_manager != NULL)
    {
        client_private->producer_manager->uuid_user_param = client_private->persistent_manager;
        client_private->producer_manager->uuid_send_done_function = on_log_persistent_manager_send_done_uuid;
        
        // 使用异步恢复，避免阻塞初始化
        int recoverRst = log_persistent_manager_recover_async(client_private->persistent_manager, client_private->producer_manager);
        if (recoverRst != 0)
        {
            aos_error_log("project %s, logstore %s, start async recover log persistent manager failed, result %d",
                          config->project,
                          config->logstore,
                          recoverRst);
        }
        else
        {
            aos_info_log("project %s, logstore %s, start async recover log persistent manager success",
                          config->project,
                          config->logstore);
        }
    }

    aos_debug_log("create producer client success, config : %s", config->logstore);
    producer_client->valid_flag = 1;
    producer->root_client = producer_client;
    return producer;
}


void destroy_log_producer(log_producer * producer)
{
    if (producer == NULL)
    {
        return;
    }
    log_producer_client * client = producer->root_client;
    client->valid_flag = 0;
    producer_client_private * client_private = (producer_client_private *)client->private_data;
    destroy_log_producer_manager(client_private->producer_manager);
    destroy_log_producer_config(client_private->producer_config);
    destroy_log_persistent_manager(client_private->persistent_manager);
    free(client_private);
    free(client);
    free(producer);
}

extern log_producer_client * get_log_producer_client(log_producer * producer, const char * config_name)
{
    if (producer == NULL)
    {
        return NULL;
    }
    return producer->root_client;
}

void log_producer_client_network_recover(log_producer_client * client)
{
    if (client == NULL)
    {
        return;
    }
    log_producer_manager * manager = ((producer_client_private *)client->private_data)->producer_manager;
    manager->networkRecover = 1;
}

log_group_builder * log_producer_client_new_log_group_builder(void)
{
    return log_group_create();
}

log_producer_result log_producer_client_add_log(log_producer_client * client, int32_t kv_count, ...)
{
    if (client == NULL || !client->valid_flag)
    {
        return LOG_PRODUCER_INVALID;
    }
    va_list argp;
    va_start(argp, kv_count);

    int32_t pairs = kv_count / 2;

    char ** keys = (char **)malloc(pairs * sizeof(char *));
    char ** values = (char **)malloc(pairs * sizeof(char *));
    size_t * key_lens = (size_t *)malloc(pairs * sizeof(size_t));
    size_t * val_lens = (size_t *)malloc(pairs * sizeof(size_t));

    int32_t i = 0;
    for (; i < pairs; ++i)
    {
        const char * key = va_arg(argp, const char *);
        const char * value = va_arg(argp, const char *);
        keys[i] = (char *)key;
        values[i] = (char *)value;
        key_lens[i] = strlen(key);
        val_lens[i] = strlen(value);
    }

    log_producer_result rst = log_producer_client_add_log_with_len(client, pairs, keys, key_lens, values, val_lens, 0);
    free(keys);
    free(values);
    free(key_lens);
    free(val_lens);
    return rst;
}

log_producer_result log_producer_client_send_log(log_producer_manager * producer_manager, log_group_builder * builder)
{
    log_producer_config * config = producer_manager->producer_config;
    int i = 0;
    for (i = 0; i < config->tagCount; ++i)
    {
        add_tag(builder, config->tags[i].key, strlen(config->tags[i].key), config->tags[i].value, strlen(config->tags[i].value));
    }
    if (config->topic != NULL)
    {
        add_topic(builder, config->topic, strlen(config->topic));
    }
    if (producer_manager->source != NULL)
    {
        add_source(builder, producer_manager->source, strlen(producer_manager->source));
    }
    if (producer_manager->pack_prefix != NULL)
    {
        add_pack_id(builder, producer_manager->pack_prefix, strlen(producer_manager->pack_prefix), producer_manager->pack_index++);
    }

    lz4_log_buf * lz4_buf = NULL;
    // check compress type
    if (config->compressType == 1)
    {
        lz4_buf = serialize_to_proto_buf_with_malloc_lz4(builder);
    }
    else
    {
        lz4_buf = serialize_to_proto_buf_with_malloc_no_lz4(builder);
    }
    log_group_destroy(builder);
    if (lz4_buf == NULL)
    {
        return LOG_PRODUCER_DROP_ERROR;
    }

    log_post_option option;
    memset(&option, 0, sizeof(log_post_option));
    option.connect_timeout = config->connectTimeoutSec;
    option.operation_timeout = config->sendTimeoutSec;
    option.interface = config->netInterface;
    option.compress_type = config->compressType;
    option.using_https = config->using_https;
    option.ntp_time_offset = config->ntpTimeOffset;
    log_sds accessKeyId = NULL;
    log_sds accessKey = NULL;
    log_sds stsToken = NULL;
    log_producer_config_get_security(config, &accessKeyId, &accessKey, &stsToken);
    post_log_result * rst = post_logs_from_lz4buf_with_config(config, config->endpoint, config->project, config->logstore, accessKeyId, accessKey, stsToken, lz4_buf, &option);
    log_sdsfree(accessKeyId);
    log_sdsfree(accessKey);
    log_sdsfree(stsToken);

    log_producer_send_result send_result = AosStatusToResult(rst);

    post_log_result_destroy(rst);
    free_lz4_log_buf(lz4_buf);

    return send_result == LOG_SEND_OK ?
            LOG_PRODUCER_OK :
            (LOG_PRODUCER_SEND_NETWORK_ERROR + send_result - LOG_SEND_NETWORK_ERROR);
}

log_producer_result log_producer_client_add_log_with_len(log_producer_client * client, int32_t pair_count, char ** keys, size_t * key_lens, char ** values, size_t * val_lens, int flush)
{
    if (client == NULL || !client->valid_flag)
    {
        return LOG_PRODUCER_INVALID;
    }

    log_producer_manager * manager = ((producer_client_private *)client->private_data)->producer_manager;
    if (flush == 2)
    {
        log_group_builder *builder = log_producer_client_new_log_group_builder();
        add_log_full(builder, LOG_GET_TIME(), pair_count, keys, key_lens, values, val_lens);
        return log_producer_client_send_log(manager, builder);
    }
    
    log_persistent_manager * persistent_manager = ((producer_client_private *)client->private_data)->persistent_manager;
    if (persistent_manager != NULL && persistent_manager->is_invalid == 0)
    {
        // 使用优化的恢复状态检查函数
        int cache_result = check_recover_status_and_cache_log(persistent_manager, manager, pair_count, keys, key_lens, values, val_lens, flush);
        if (cache_result != -1)
        {
            return cache_result; // 已经处理完成（缓存或内存模式）
        }
        
        // 需要正常处理，此时才加锁
        CS_ENTER(persistent_manager->lock);
        
        // 如果恢复成功且刚刚完成，先处理缓存的日志
        if (atomic_load(&persistent_manager->recover_completed) && atomic_load(&persistent_manager->recover_success))
        {
            // 检查是否有缓存的日志需要处理
            if (persistent_manager->recover_cache != NULL && persistent_manager->recover_cache->count > 0)
            {
                CS_LEAVE(persistent_manager->lock);
                int cached_count = log_persistent_manager_process_recover_cache(persistent_manager, manager);
                if (cached_count > 0)
                {
                    aos_info_log("project %s, logstore %s, processed %d cached logs after recover",
                                 manager->producer_config->project,
                                 manager->producer_config->logstore,
                                 cached_count);
                }
                CS_ENTER(persistent_manager->lock);
            }
        }
        
        add_log_full(persistent_manager->builder, LOG_GET_TIME(), pair_count, keys, key_lens, values, val_lens);
        char * logBuf = persistent_manager->builder->grp->logs.buffer;
        size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
        clear_log_tag(&(persistent_manager->builder->grp->logs));
        if (!log_persistent_manager_is_buffer_enough(persistent_manager, logSize) ||
            manager->totalBufferSize > manager->producer_config->maxBufferBytes)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        int rst = log_persistent_manager_save_log(persistent_manager, logBuf, logSize);
        if (rst != LOG_PRODUCER_OK)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        rst = log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, persistent_manager->checkpoint.now_log_uuid - 1);
        CS_LEAVE(persistent_manager->lock);
        return rst;
    }

    return log_producer_manager_add_log(manager, pair_count, keys, key_lens, values, val_lens, flush, -1);
}

log_producer_result log_producer_client_add_raw_log_buffer(log_producer_client * client, size_t log_bytes, size_t compressed_bytes, const unsigned char * raw_buffer)
{
  if (client == NULL || !client->valid_flag || raw_buffer == NULL)
  {
      return LOG_PRODUCER_INVALID;
  }

  log_producer_manager * manager = ((producer_client_private *)client->private_data)->producer_manager;
  return log_producer_manager_send_raw_buffer(manager, log_bytes, compressed_bytes, raw_buffer);
}

log_producer_result
log_producer_client_add_log_raw(log_producer_client *client, char *logBuf,
                                size_t logSize, int flush)
{
    if (client == NULL || !client->valid_flag)
    {
        return LOG_PRODUCER_INVALID;
    }
    log_producer_manager * manager = ((producer_client_private *)client->private_data)->producer_manager;
    if (flush == 2)
    {
        log_group_builder * builder = log_producer_client_new_log_group_builder();
        add_log_raw(builder, logBuf, logSize);
        return log_producer_client_send_log(manager, builder);
    }
    
    log_persistent_manager * persistent_manager = ((producer_client_private *)client->private_data)->persistent_manager;
    if (persistent_manager != NULL && persistent_manager->is_invalid == 0)
    {
        CS_ENTER(persistent_manager->lock);
        
        // 如果正在恢复中且未完成，缓存日志而不是直接发送
        if (atomic_load(&persistent_manager->is_recovering) && !atomic_load(&persistent_manager->recover_completed))
        {
            // 缓存日志
            int cache_rst = log_persistent_manager_cache_log_during_recover(persistent_manager, logBuf, logSize, LOG_GET_TIME());
            CS_LEAVE(persistent_manager->lock);
            
            if (cache_rst == 0)
            {
                aos_debug_log("project %s, logstore %s, raw log cached during recover, size %d",
                              manager->producer_config->project,
                              manager->producer_config->logstore,
                              (int)logSize);
                return LOG_PRODUCER_OK;
            }
            else
            {
                aos_warn_log("project %s, logstore %s, failed to cache raw log during recover, fallback to memory mode, result %d",
                             manager->producer_config->project,
                             manager->producer_config->logstore,
                             cache_rst);
                // 缓存失败，降级到内存模式
                return log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, -1);
            }
        }
        
        // 如果恢复失败，也使用内存模式
        if (atomic_load(&persistent_manager->recover_completed) && !atomic_load(&persistent_manager->recover_success))
        {
            CS_LEAVE(persistent_manager->lock);
            return log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, -1);
        }
        
        // 如果恢复成功且刚刚完成，先处理缓存的日志
        if (atomic_load(&persistent_manager->recover_completed) && atomic_load(&persistent_manager->recover_success))
        {
            // 检查是否有缓存的日志需要处理
            if (persistent_manager->recover_cache != NULL && persistent_manager->recover_cache->count > 0)
            {
                CS_LEAVE(persistent_manager->lock);
                int cached_count = log_persistent_manager_process_recover_cache(persistent_manager, manager);
                if (cached_count > 0)
                {
                    aos_info_log("project %s, logstore %s, processed %d cached logs after recover (raw)",
                                 manager->producer_config->project,
                                 manager->producer_config->logstore,
                                 cached_count);
                }
                CS_ENTER(persistent_manager->lock);
            }
        }
        
        if (!log_persistent_manager_is_buffer_enough(persistent_manager, logSize) ||
                manager->totalBufferSize > manager->producer_config->maxBufferBytes)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        int rst = log_persistent_manager_save_log(persistent_manager, logBuf, logSize);
        if (rst != LOG_PRODUCER_OK)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        rst = log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, persistent_manager->checkpoint.now_log_uuid - 1);
        CS_LEAVE(persistent_manager->lock);
        return rst;
    }

    int rst = log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, -1);
    return rst;
}

log_producer_result
log_producer_client_add_log_with_array(log_producer_client *client,
                                       uint32_t logTime, size_t logItemCount,
                                       const char *logItemsBuf,
                                       const uint32_t *logItemsSize, int flush)
{
    if (client == NULL || !client->valid_flag)
    {
        return LOG_PRODUCER_INVALID;
    }
    log_producer_manager * manager = ((producer_client_private *)client->private_data)->producer_manager;
    if (flush == 2)
    {
        log_group_builder * builder = log_producer_client_new_log_group_builder();
        add_log_full_v2(builder, logTime, logItemCount, logItemsBuf, logItemsSize);
        return log_producer_client_send_log(manager, builder);
    }
    
    log_persistent_manager * persistent_manager = ((producer_client_private *)client->private_data)->persistent_manager;
    if (persistent_manager != NULL && persistent_manager->is_invalid == 0)
    {
        CS_ENTER(persistent_manager->lock);
        
        // 如果正在恢复中且未完成，缓存日志而不是直接发送
        if (atomic_load(&persistent_manager->is_recovering) && !atomic_load(&persistent_manager->recover_completed))
        {
            // 构建日志数据用于缓存
            add_log_full_v2(persistent_manager->builder, logTime, logItemCount, logItemsBuf, logItemsSize);
            char * logBuf = persistent_manager->builder->grp->logs.buffer;
            size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
            clear_log_tag(&(persistent_manager->builder->grp->logs));
            
            // 缓存日志
            int cache_rst = log_persistent_manager_cache_log_during_recover(persistent_manager, logBuf, logSize, logTime);
            CS_LEAVE(persistent_manager->lock);
            
            if (cache_rst == 0)
            {
                aos_debug_log("project %s, logstore %s, array log cached during recover, size %d",
                              manager->producer_config->project,
                              manager->producer_config->logstore,
                              (int)logSize);
                return LOG_PRODUCER_OK;
            }
            else
            {
                aos_warn_log("project %s, logstore %s, failed to cache array log during recover, fallback to memory mode, result %d",
                             manager->producer_config->project,
                             manager->producer_config->logstore,
                             cache_rst);
                // 缓存失败，降级到内存模式
                return log_producer_manager_add_log_with_array(manager, logTime, logItemCount, logItemsBuf, logItemsSize, flush, -1);
            }
        }
        
        // 如果恢复失败，也使用内存模式
        if (atomic_load(&persistent_manager->recover_completed) && !atomic_load(&persistent_manager->recover_success))
        {
            CS_LEAVE(persistent_manager->lock);
            return log_producer_manager_add_log_with_array(manager, logTime, logItemCount, logItemsBuf, logItemsSize, flush, -1);
        }
        
        // 如果恢复成功且刚刚完成，先处理缓存的日志
        if (atomic_load(&persistent_manager->recover_completed) && atomic_load(&persistent_manager->recover_success))
        {
            // 检查是否有缓存的日志需要处理
            if (persistent_manager->recover_cache != NULL && persistent_manager->recover_cache->count > 0)
            {
                CS_LEAVE(persistent_manager->lock);
                int cached_count = log_persistent_manager_process_recover_cache(persistent_manager, manager);
                if (cached_count > 0)
                {
                    aos_info_log("project %s, logstore %s, processed %d cached logs after recover (array)",
                                 manager->producer_config->project,
                                 manager->producer_config->logstore,
                                 cached_count);
                }
                CS_ENTER(persistent_manager->lock);
            }
        }

        add_log_full_v2(persistent_manager->builder, logTime, logItemCount, logItemsBuf, logItemsSize);
        char * logBuf = persistent_manager->builder->grp->logs.buffer;
        size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
        clear_log_tag(&(persistent_manager->builder->grp->logs));
        if (!log_persistent_manager_is_buffer_enough(persistent_manager, logSize) ||
            manager->totalBufferSize > manager->producer_config->maxBufferBytes)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        int rst = log_persistent_manager_save_log(persistent_manager, logBuf, logSize);
        if (rst != LOG_PRODUCER_OK)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        rst = log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, persistent_manager->checkpoint.now_log_uuid - 1);
        CS_LEAVE(persistent_manager->lock);
        return rst;
    }

    int rst = log_producer_manager_add_log_with_array(manager, logTime, logItemCount, logItemsBuf, logItemsSize, flush, -1);

    return rst;
}

log_producer_result
log_producer_client_add_log_with_len_int32(log_producer_client *client,
                                           int32_t pair_count, char **keys,
                                           int32_t *key_lens, char **values,
                                           int32_t *value_lens, int flush)
{
    if (client == NULL || !client->valid_flag)
    {
        return LOG_PRODUCER_INVALID;
    }

    log_producer_manager * manager = ((producer_client_private *)client->private_data)->producer_manager;
    if (flush == 2)
    {
        log_group_builder * builder = log_producer_client_new_log_group_builder();
        add_log_full_int32(builder, LOG_GET_TIME(), pair_count, keys, key_lens, values, value_lens);
        return log_producer_client_send_log(manager, builder);
    }
    
    log_persistent_manager * persistent_manager = ((producer_client_private *)client->private_data)->persistent_manager;
    if (persistent_manager != NULL && persistent_manager->is_invalid == 0)
    {
        CS_ENTER(persistent_manager->lock);
        
        // 如果正在恢复中且未完成，缓存日志而不是直接发送
        if (atomic_load(&persistent_manager->is_recovering) && !atomic_load(&persistent_manager->recover_completed))
        {
            // 构建日志数据用于缓存
            add_log_full_int32(persistent_manager->builder, LOG_GET_TIME(), pair_count, keys, key_lens, values, value_lens);
            char * logBuf = persistent_manager->builder->grp->logs.buffer;
            size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
            clear_log_tag(&(persistent_manager->builder->grp->logs));
            
            // 缓存日志
            int cache_rst = log_persistent_manager_cache_log_during_recover(persistent_manager, logBuf, logSize, LOG_GET_TIME());
            CS_LEAVE(persistent_manager->lock);
            
            if (cache_rst == 0)
            {
                aos_debug_log("project %s, logstore %s, int32 log cached during recover, size %d",
                              manager->producer_config->project,
                              manager->producer_config->logstore,
                              (int)logSize);
                return LOG_PRODUCER_OK;
            }
            else
            {
                aos_warn_log("project %s, logstore %s, failed to cache int32 log during recover, fallback to memory mode, result %d",
                             manager->producer_config->project,
                             manager->producer_config->logstore,
                             cache_rst);
                // 缓存失败，降级到内存模式
                return log_producer_manager_add_log_int32(manager, pair_count, keys, key_lens, values, value_lens, flush, -1);
            }
        }
        
        // 如果恢复失败，也使用内存模式
        if (atomic_load(&persistent_manager->recover_completed) && !atomic_load(&persistent_manager->recover_success))
        {
            CS_LEAVE(persistent_manager->lock);
            return log_producer_manager_add_log_int32(manager, pair_count, keys, key_lens, values, value_lens, flush, -1);
        }
        
        // 如果恢复成功且刚刚完成，先处理缓存的日志
        if (atomic_load(&persistent_manager->recover_completed) && atomic_load(&persistent_manager->recover_success))
        {
            // 检查是否有缓存的日志需要处理
            if (persistent_manager->recover_cache != NULL && persistent_manager->recover_cache->count > 0)
            {
                CS_LEAVE(persistent_manager->lock);
                int cached_count = log_persistent_manager_process_recover_cache(persistent_manager, manager);
                if (cached_count > 0)
                {
                    aos_info_log("project %s, logstore %s, processed %d cached logs after recover (int32)",
                                 manager->producer_config->project,
                                 manager->producer_config->logstore,
                                 cached_count);
                }
                CS_ENTER(persistent_manager->lock);
            }
        }
        
        add_log_full_int32(persistent_manager->builder, LOG_GET_TIME(), pair_count, keys, key_lens, values, value_lens);
        char * logBuf = persistent_manager->builder->grp->logs.buffer;
        size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
        clear_log_tag(&(persistent_manager->builder->grp->logs));
        if (!log_persistent_manager_is_buffer_enough(persistent_manager, logSize) ||
            manager->totalBufferSize > manager->producer_config->maxBufferBytes)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        int rst = log_persistent_manager_save_log(persistent_manager, logBuf, logSize);
        if (rst != LOG_PRODUCER_OK)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        rst = log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, persistent_manager->checkpoint.now_log_uuid - 1);
        CS_LEAVE(persistent_manager->lock);
        return rst;
    }

    return log_producer_manager_add_log_int32(manager, pair_count, keys, key_lens, values, value_lens, flush, -1);
}


log_producer_result
log_producer_client_add_log_with_len_time_int32(log_producer_client *client,
                                                uint32_t time_sec,
                                                int32_t pair_count, char **keys,
                                                int32_t *key_lens, char **values,
                                                int32_t *value_lens, int flush)
{
    if (client == NULL || !client->valid_flag)
    {
        return LOG_PRODUCER_INVALID;
    }

    log_producer_manager * manager = ((producer_client_private *)client->private_data)->producer_manager;
    if (flush == 2)
    {
        log_group_builder * builder = log_producer_client_new_log_group_builder();
        add_log_full_int32(builder, time_sec, pair_count, keys, key_lens, values, value_lens);
        return log_producer_client_send_log(manager, builder);
    }
    
    log_persistent_manager * persistent_manager = ((producer_client_private *)client->private_data)->persistent_manager;
    if (persistent_manager != NULL && persistent_manager->is_invalid == 0)
    {
        CS_ENTER(persistent_manager->lock);
        
        // 如果正在恢复中且未完成，缓存日志而不是直接发送
        if (atomic_load(&persistent_manager->is_recovering) && !atomic_load(&persistent_manager->recover_completed))
        {
            // 构建日志数据用于缓存
            add_log_full_int32(persistent_manager->builder, time_sec, pair_count, keys, key_lens, values, value_lens);
            char * logBuf = persistent_manager->builder->grp->logs.buffer;
            size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
            clear_log_tag(&(persistent_manager->builder->grp->logs));
            
            // 缓存日志
            int cache_rst = log_persistent_manager_cache_log_during_recover(persistent_manager, logBuf, logSize, time_sec);
            CS_LEAVE(persistent_manager->lock);
            
            if (cache_rst == 0)
            {
                aos_debug_log("project %s, logstore %s, time_int32 log cached during recover, size %d",
                              manager->producer_config->project,
                              manager->producer_config->logstore,
                              (int)logSize);
                return LOG_PRODUCER_OK;
            }
            else
            {
                aos_warn_log("project %s, logstore %s, failed to cache time_int32 log during recover, fallback to memory mode, result %d",
                             manager->producer_config->project,
                             manager->producer_config->logstore,
                             cache_rst);
                // 缓存失败，降级到内存模式
                return log_producer_manager_add_log_int32(manager, pair_count, keys, key_lens, values, value_lens, flush, -1);
            }
        }
        
        // 如果恢复失败，也使用内存模式
        if (atomic_load(&persistent_manager->recover_completed) && !atomic_load(&persistent_manager->recover_success))
        {
            CS_LEAVE(persistent_manager->lock);
            return log_producer_manager_add_log_int32(manager, pair_count, keys, key_lens, values, value_lens, flush, -1);
        }
        
        // 如果恢复成功且刚刚完成，先处理缓存的日志
        if (atomic_load(&persistent_manager->recover_completed) && atomic_load(&persistent_manager->recover_success))
        {
            // 检查是否有缓存的日志需要处理
            if (persistent_manager->recover_cache != NULL && persistent_manager->recover_cache->count > 0)
            {
                CS_LEAVE(persistent_manager->lock);
                int cached_count = log_persistent_manager_process_recover_cache(persistent_manager, manager);
                if (cached_count > 0)
                {
                    aos_info_log("project %s, logstore %s, processed %d cached logs after recover (time_int32)",
                                 manager->producer_config->project,
                                 manager->producer_config->logstore,
                                 cached_count);
                }
                CS_ENTER(persistent_manager->lock);
            }
        }
        
        add_log_full_int32(persistent_manager->builder, time_sec, pair_count, keys, key_lens, values, value_lens);
        char * logBuf = persistent_manager->builder->grp->logs.buffer;
        size_t logSize = persistent_manager->builder->grp->logs.now_buffer_len;
        clear_log_tag(&(persistent_manager->builder->grp->logs));
        if (!log_persistent_manager_is_buffer_enough(persistent_manager, logSize) ||
            manager->totalBufferSize > manager->producer_config->maxBufferBytes)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        int rst = log_persistent_manager_save_log(persistent_manager, logBuf, logSize);
        if (rst != LOG_PRODUCER_OK)
        {
            CS_LEAVE(persistent_manager->lock);
            return LOG_PRODUCER_DROP_ERROR;
        }
        rst = log_producer_manager_add_log_raw(manager, logBuf, logSize, flush, persistent_manager->checkpoint.now_log_uuid - 1);
        CS_LEAVE(persistent_manager->lock);
        return rst;
    }

    return log_producer_manager_add_log_int32(manager, pair_count, keys, key_lens, values, value_lens, flush, -1);
}

