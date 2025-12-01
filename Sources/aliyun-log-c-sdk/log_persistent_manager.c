//
// Created by davidzhang on 2020/8/23.
//

#include "log_persistent_manager.h"
#include "log_producer_manager.h"
#include "inner_log.h"
#include "log_builder.h"
#include "log_sds.h"

#define MAX_CHECKPOINT_FILE_SIZE (sizeof(log_persistent_checkpoint) * 1024)
#define LOG_PERSISTENT_HEADER_MAGIC (0xf7216a5b76df67f5)

static int32_t is_valid_log_checkpoint(log_persistent_checkpoint * checkpoint)
{
    return checkpoint->check_sum == checkpoint->start_log_uuid + checkpoint->now_log_uuid +
                                       checkpoint->start_file_offset + checkpoint->now_file_offset;
}

static int32_t recover_log_checkpoint(log_persistent_manager * manager)
{
    FILE * tmpFile = fopen(manager->checkpoint_file_path, "rb");
    if (tmpFile == NULL)
    {
        if (errno == ENOENT)
        {
            return 0;
        }
        return -1;
    }
    fseek(tmpFile, 0, SEEK_END);
    long pos = ftell(tmpFile);
    if (pos == 0)
    {
        // empty file
        return 0;
    }
    long fixedPos = pos - pos%sizeof(log_persistent_checkpoint);
    long lastPos = fixedPos == 0? 0 : fixedPos - sizeof(log_persistent_checkpoint);
    fseek(tmpFile, lastPos, SEEK_SET);
    if (1 != fread((void *)&(manager->checkpoint), sizeof(log_persistent_checkpoint), 1, tmpFile))
    {
        fclose(tmpFile);
        return -2;
    }
    if (!is_valid_log_checkpoint(&(manager->checkpoint)))
    {
        fclose(tmpFile);
        return -3;
    }
    fclose(tmpFile);
    manager->checkpoint_file_size = pos;
    return 0;
}

int save_log_checkpoint(log_persistent_manager * manager)
{
    log_persistent_checkpoint * checkpoint = &(manager->checkpoint);
    checkpoint->check_sum = checkpoint->start_log_uuid + checkpoint->now_log_uuid +
            checkpoint->start_file_offset + checkpoint->now_file_offset;
    if (manager->checkpoint_file_size >= MAX_CHECKPOINT_FILE_SIZE)
    {
        if (manager->checkpoint_file_ptr != NULL)
        {
            fclose(manager->checkpoint_file_ptr);
            manager->checkpoint_file_ptr = NULL;
        }
        char tmpFilePath[256];
        strcpy(tmpFilePath, manager->checkpoint_file_path);
        strcat(tmpFilePath, ".bak");
        aos_info_log("start switch checkpoint index file %s \n", manager->checkpoint_file_path);
        FILE * tmpFile = fopen(tmpFilePath, "wb+");
        if (tmpFile == NULL)
            return -1;
        if (1 !=
            fwrite((const void *)(&manager->checkpoint), sizeof(log_persistent_checkpoint), 1, tmpFile))
        {
            fclose(tmpFile);
            return -2;
        }
        if (fclose(tmpFile) != 0)
            return -3;
        if (rename(tmpFilePath, manager->checkpoint_file_path) != 0 )
            return -4;
        manager->checkpoint_file_size = sizeof(log_persistent_checkpoint);
        return 0;
    }
    if (manager->checkpoint_file_ptr == NULL)
    {
        manager->checkpoint_file_ptr = fopen(manager->checkpoint_file_path, "ab+");
        if (manager->checkpoint_file_ptr == NULL)
            return -5;
    }
    if (1 !=
        fwrite((const void *)(&manager->checkpoint), sizeof(log_persistent_checkpoint), 1, manager->checkpoint_file_ptr))
        return -6;
    if (fflush(manager->checkpoint_file_ptr) != 0)
        return -7;
    manager->checkpoint_file_size += sizeof(log_persistent_checkpoint);
    return 0;
}

void on_log_persistent_manager_send_done_uuid(const char * config_name,
                                              log_producer_result result,
                                              size_t log_bytes,
                                              size_t compressed_bytes,
                                              const char * req_id,
                                              const char * error_message,
                                              const unsigned char * raw_buffer,
                                              void *persistent_manager,
                                              int64_t startId,
                                              int64_t endId)
{
    if (result != LOG_PRODUCER_OK && result != LOG_PRODUCER_DROP_ERROR && result != LOG_PRODUCER_INVALID)
    {
        return;
    }
    log_persistent_manager * manager = (log_persistent_manager *)persistent_manager;
    if (manager == NULL)
    {
        return;
    }
    if (manager->is_invalid)
    {
        return;
    }
    if (startId < 0 || endId < 0 || startId > endId || endId - startId > 1024 * 1024)
    {
        aos_fatal_log("invalid id range %lld %lld", startId, endId);
        manager->is_invalid = 1;
        return;
    }

    // multi thread send is not allowed, and this should never happen
    if (startId > manager->checkpoint.start_log_uuid)
    {
        aos_fatal_log("project %s, logstore %s, invalid checkpoint start log uuid %lld %lld",
                      manager->config->project,
                      manager->config->logstore,
                      startId,
                      manager->checkpoint.start_log_uuid);
        manager->is_invalid = 1;
        return;
    }
    CS_ENTER(manager->lock);
    // cal log size
    uint64_t totalOffset = 0;
    for (int64_t id = startId; id <= endId; ++id)
    {
        totalOffset += manager->in_buffer_log_sizes[id % manager->config->maxPersistentLogCount];
    }

    manager->checkpoint.start_file_offset += totalOffset;
    manager->checkpoint.start_log_uuid = endId + 1;
    int rst = save_log_checkpoint(manager);
    if (rst != 0)
    {
        aos_error_log("project %s, logstore %s, save checkpoint failed, reason %d",
                      manager->config->project,
                      manager->config->logstore,
                      rst);
    }
    log_ring_file_clean(manager->ring_file, manager->checkpoint.start_file_offset - totalOffset, manager->checkpoint.start_file_offset);

    CS_LEAVE(manager->lock);
}


static void log_persistent_manager_init(log_persistent_manager * manager, log_producer_config *config)
{
    memset(manager, 0, sizeof(log_persistent_manager));
    manager->builder = log_group_create();
    manager->checkpoint.start_log_uuid = (int64_t)(time(NULL)) * 1000LL * 1000LL * 1000LL;
    manager->checkpoint.now_log_uuid = manager->checkpoint.start_log_uuid;
    manager->config = config;
    manager->lock = CreateCriticalSection();
    manager->in_buffer_log_sizes = (uint32_t *)malloc(sizeof(uint32_t) * config->maxPersistentLogCount);
    manager->checkpoint_file_path = log_sdscat(log_sdsdup(config->persistentFilePath), ".idx");
    memset(manager->in_buffer_log_sizes, 0, sizeof(uint32_t) * config->maxPersistentLogCount);
    manager->ring_file = log_ring_file_open(config->persistentFilePath, config->maxPersistentFileCount, config->maxPersistentFileSize, config->forceFlushDisk);
    
    // 初始化异步恢复相关字段（使用原子操作）
    atomic_store(&manager->is_recovering, 0);
    atomic_store(&manager->recover_completed, 0);
    atomic_store(&manager->recover_success, 0);
    manager->recover_cond = CreateCond();
    
    // 初始化恢复期间日志缓存队列
    manager->recover_cache = (log_recover_cache_queue *)malloc(sizeof(log_recover_cache_queue));
    memset(manager->recover_cache, 0, sizeof(log_recover_cache_queue));
    manager->recover_cache->max_count = 1000;  // 最大缓存1000条日志
    manager->recover_cache->max_size = 10 * 1024 * 1024;  // 最大缓存10MB
    manager->recover_cache_lock = CreateCriticalSection();
    
    // 初始化缓存UUID管理
    manager->cache_log_uuid_base = 0;
    manager->cache_log_uuid_counter = 0;
    manager->cache_uuid_initialized = 0;
}

static void log_persistent_manager_clear(log_persistent_manager * manager)
{
    // 使用原子操作进行快速检查，避免不必要的锁操作
    if (atomic_load(&manager->is_recovering) && !atomic_load(&manager->recover_completed))
    {
        // 只有在需要等待时才加锁
        CS_ENTER(manager->lock);
        while (atomic_load(&manager->is_recovering) && !atomic_load(&manager->recover_completed))
        {
            COND_WAIT(manager->recover_cond, manager->lock);
        }
        CS_LEAVE(manager->lock);
        
        // 等待恢复线程结束
        if (manager->recover_thread)
        {
            THREAD_JOIN(manager->recover_thread);
        }
    }
    
    log_group_destroy(manager->builder);
    ReleaseCriticalSection(manager->lock);
    if (manager->checkpoint_file_ptr != NULL)
    {
        fclose(manager->checkpoint_file_ptr);
        manager->checkpoint_file_ptr = NULL;
    }
    free(manager->in_buffer_log_sizes);
    log_sdsfree(manager->checkpoint_file_path);
    log_ring_file_close(manager->ring_file);
    
    // 清理异步恢复相关资源
    if (manager->recover_cond)
    {
        DeleteCond(manager->recover_cond);
    }
    
    // 清理恢复期间日志缓存队列
    log_persistent_manager_clear_recover_cache(manager);
    if (manager->recover_cache)
    {
        ReleaseCriticalSection(manager->recover_cache_lock);
        free(manager->recover_cache);
        manager->recover_cache = NULL;
    }
}

log_persistent_manager *
create_log_persistent_manager(log_producer_config *config)
{
    if (!log_producer_persistent_config_is_enabled(config))
    {
        return NULL;
    }
    log_persistent_manager * manager = (log_persistent_manager *)malloc(sizeof(log_persistent_manager));
    log_persistent_manager_init(manager, config);
    return manager;
}

void destroy_log_persistent_manager(log_persistent_manager *manager)
{
    if (manager == NULL)
    {
        return;
    }
    log_persistent_manager_clear(manager);
    free(manager);
}

int log_persistent_manager_save_log(log_persistent_manager *manager,
                                    const char *logBuf, size_t logSize)
{
    // save binlog
    const void * buffer[2];
    size_t bufferSize[2];

    log_persistent_item_header header;
    header.magic_code = LOG_PERSISTENT_HEADER_MAGIC;
    header.log_uuid = manager->checkpoint.now_log_uuid;
    header.log_size = logSize;
    header.preserved = 0;

    buffer[0] = &header;
    buffer[1] = logBuf;
    bufferSize[0] = sizeof(log_persistent_item_header);
    bufferSize[1] = logSize;
    int rst = log_ring_file_write(manager->ring_file, manager->checkpoint.now_file_offset, 2, buffer, bufferSize);
    if (rst != bufferSize[0] + bufferSize[1])
    {
        aos_error_log("project %s, logstoe %s, write bin log failed, rst %d",
                      manager->config->project,
                      manager->config->logstore,
                      rst);
        return LOG_PRODUCER_PERSISTENT_ERROR;
    }
    // update in memory checkpoint
    manager->in_buffer_log_sizes[manager->checkpoint.now_log_uuid % manager->config->maxPersistentLogCount] = rst;
    manager->checkpoint.now_file_offset += rst;
    ++manager->checkpoint.now_log_uuid;
    aos_debug_log("project %s, logstore %s, write bin log success, offset %lld, uuid %lld, log size %d",
                  manager->config->project,
                  manager->config->logstore,
                  manager->checkpoint.now_file_offset,
                  manager->checkpoint.now_log_uuid,
                  rst);
    if (manager->first_checkpoint_saved == 0)
    {
        save_log_checkpoint(manager);
        manager->first_checkpoint_saved = 1;
    }
    return 0;
}

int log_persistent_manager_is_buffer_enough(log_persistent_manager *manager,
                                            size_t logSize)
{
    if (manager->checkpoint.now_file_offset - manager->checkpoint.start_file_offset + logSize + 1024 >
        (uint64_t)manager->config->maxPersistentFileCount * manager->config->maxPersistentFileSize &&
        manager->checkpoint.now_log_uuid - manager->checkpoint.start_log_uuid < manager->config->maxPersistentLogCount - 1)
    {
        return 0;
    }
    return 1;
}

static int log_persistent_manager_recover_inner(log_persistent_manager *manager,
                                                log_producer_manager *producer_manager)
{
    int rst = recover_log_checkpoint(manager);
    if (rst != 0)
    {
        return rst;
    }

    aos_info_log("project %s, logstore %s, recover persistent checkpoint success, checkpoint %lld %lld %lld %lld",
                 manager->config->project,
                 manager->config->logstore,
                 manager->checkpoint.start_file_offset,
                 manager->checkpoint.now_file_offset,
                 manager->checkpoint.start_log_uuid,
                 manager->checkpoint.now_log_uuid);

    if (manager->checkpoint.start_file_offset == 0 && manager->checkpoint.now_file_offset == 0)
    {
        // no need to recover
        return 0;
    }

    // try recover ring file

    log_persistent_item_header header;

    uint64_t fileOffset = manager->checkpoint.start_file_offset;
    int64_t logUUID = manager->checkpoint.start_log_uuid;

    char * buffer = NULL;
    int max_buffer_size = 0;

    while (1)
    {
        rst = log_ring_file_read(manager->ring_file, fileOffset, &header, sizeof(log_persistent_item_header));
        if (rst != sizeof(log_persistent_item_header))
        {
            if (rst == 0)
            {
                aos_info_log("project %s, logstore %s, read end of file",
                             manager->config->project,
                             manager->config->logstore);
                if (buffer != NULL)
                {
                    free(buffer);
                    buffer = NULL;
                }
                break;
            }
            aos_error_log("project %s, logstore %s, read binlog file header failed, offset %lld, result %d",
                          manager->config->project,
                          manager->config->logstore,
                          fileOffset,
                          rst);
            if (buffer != NULL)
            {
                free(buffer);
                buffer = NULL;
            }
            return -1;
        }
        if (header.magic_code != LOG_PERSISTENT_HEADER_MAGIC ||
            header.log_uuid < logUUID ||
            header.log_size <= 0 || header.log_size > 10*1024*1024 )
        {
            aos_info_log("project %s, logstore %s, read binlog file success, uuid %lld %lld",
                          manager->config->project,
                          manager->config->logstore,
                          header.log_uuid,
                          logUUID);
            break;
        }
        if (buffer == NULL || max_buffer_size < header.log_size)
        {
            if (buffer != NULL)
            {
                free(buffer);
            }
            buffer = (char *)malloc(header.log_size * 2);
            max_buffer_size = header.log_size * 2;
        }
        rst = log_ring_file_read(manager->ring_file, fileOffset + sizeof(log_persistent_item_header), buffer, header.log_size);
        if (rst != header.log_size)
        {
            // if read fail, just break
            aos_warn_log("project %s, logstore %s, read binlog file content failed, offset %lld, result %d",
                          manager->config->project,
                          manager->config->logstore,
                          fileOffset + sizeof(log_persistent_item_header),
                          rst);
            break;
        }
        if (header.log_uuid - logUUID > 1024*1024)
        {
            aos_error_log("project %s, logstore %s, log uuid jump, %lld %lld",
                          manager->config->project,
                          manager->config->logstore,
                          header.log_uuid,
                          logUUID);
            if (buffer != NULL)
            {
                free(buffer);
                buffer = NULL;
            }
            return -3;
        }
        // set empty log uuid len 0
        for (int64_t emptyUUID = logUUID + 1; emptyUUID < header.log_uuid; ++emptyUUID)
        {
            manager->in_buffer_log_sizes[emptyUUID % manager->config->maxPersistentLogCount] = 0;
        }
        manager->in_buffer_log_sizes[header.log_uuid % manager->config->maxPersistentLogCount] = header.log_size + sizeof(log_persistent_item_header);

        logUUID = header.log_uuid;
        fileOffset += header.log_size + sizeof(log_persistent_item_header);

        rst = log_producer_manager_add_log_raw(producer_manager, buffer, header.log_size, 0, header.log_uuid);
        if (rst != 0)
        {
            aos_error_log("project %s, logstore %s, add log to producer manager failed, this log will been dropped",
                          manager->config->project,
                          manager->config->logstore);
        }

    }
    if (buffer != NULL)
    {
        free(buffer);
        buffer = NULL;
    }

    if (logUUID < manager->checkpoint.now_log_uuid - 1)
    {
        // replay fail
        aos_fatal_log("project %s, logstore %s, replay bin log failed, now log uuid %lld, expected min log uuid %lld, start uuid %lld, start offset  %lld, now offset  %lld, replayed offset %lld",
                      manager->config->project,
                      manager->config->logstore,
                      logUUID,
                      manager->checkpoint.now_log_uuid,
                      manager->checkpoint.start_log_uuid,
                      manager->checkpoint.start_file_offset,
                      manager->checkpoint.now_file_offset,
                      fileOffset);
        return -4;
    }

    // update new checkpoint when replay bin log success
    if (fileOffset > manager->checkpoint.start_file_offset)
    {
        manager->checkpoint.now_log_uuid = logUUID + 1;
        manager->checkpoint.now_file_offset = fileOffset;
    }

    aos_info_log("project %s, logstore %s, replay bin log success, now checkpoint %lld %lld %lld %lld",
                 manager->config->project,
                 manager->config->logstore,
                 manager->checkpoint.start_log_uuid,
                 manager->checkpoint.now_log_uuid,
                 manager->checkpoint.start_file_offset,
                 manager->checkpoint.now_file_offset);

    // save new checkpoint
    rst = save_log_checkpoint(manager);
    if (rst != 0)
    {
        aos_error_log("project %s, logstore %s, save checkpoint failed, reason %d",
                      manager->config->project,
                      manager->config->logstore,
                      rst);
    }
    return rst;
}

static void log_persistent_manager_reset(log_persistent_manager * manager)
{
    log_producer_config * config = manager->config;
    log_persistent_manager_clear(manager);
    log_persistent_manager_init(manager, config);
    manager->checkpoint.start_log_uuid = (int64_t)(time(NULL)) * 1000LL * 1000LL * 1000LL + 500LL * 1000LL * 1000LL;
    manager->checkpoint.now_log_uuid = manager->checkpoint.start_log_uuid;
    manager->is_invalid = 0;
}

// 异步恢复线程函数
#ifdef WIN32
DWORD WINAPI log_persistent_manager_recover_thread(LPVOID param)
#else
void * log_persistent_manager_recover_thread(void * param)
#endif
{
    typedef struct {
        log_persistent_manager * manager;
        log_producer_manager * producer_manager;
    } recover_thread_param_t;
    
    recover_thread_param_t * thread_param = (recover_thread_param_t *)param;
    log_persistent_manager * manager = thread_param->manager;
    log_producer_manager * producer_manager = thread_param->producer_manager;
    
    aos_info_log("project %s, logstore %s, start async recover persistent manager",
                 manager->config->project,
                 manager->config->logstore);
    
    // 执行恢复操作
    int rst = log_persistent_manager_recover_inner(manager, producer_manager);
    
    // 更新恢复状态（使用原子操作）
    CS_ENTER(manager->lock);
    atomic_store(&manager->is_recovering, 0);
    atomic_store(&manager->recover_completed, 1);
    atomic_store(&manager->recover_success, (rst == 0) ? 1 : 0);
    
    if (rst != 0)
    {
        // 如果恢复失败，重置persistent manager
        manager->is_invalid = 1;
        log_persistent_manager_reset(manager);
        aos_error_log("project %s, logstore %s, async recover persistent manager failed, result %d",
                      manager->config->project,
                      manager->config->logstore,
                      rst);
    }
    else
    {
        manager->is_invalid = 0;
        aos_info_log("project %s, logstore %s, async recover persistent manager success",
                     manager->config->project,
                     manager->config->logstore);
    }
    
    COND_SIGNAL(manager->recover_cond);
    CS_LEAVE(manager->lock);
    
    // 释放线程参数
    free(thread_param);
    
    return 0;
}

int log_persistent_manager_recover(log_persistent_manager *manager,
                                   log_producer_manager *producer_manager)
{
    aos_info_log("project %s, logstore %s, start recover persistent manager",
                 manager->config->project,
                 manager->config->logstore);
    CS_ENTER(manager->lock);
    int rst = log_persistent_manager_recover_inner(manager, producer_manager);
    if (rst != 0)
    {
        // if recover failed, reset persistent manager
        manager->is_invalid = 1;
        log_persistent_manager_reset(manager);
    }
    else
    {
        manager->is_invalid = 0;
    }
    CS_LEAVE(manager->lock);
    return rst;
}

int log_persistent_manager_recover_async(log_persistent_manager *manager,
                                         log_producer_manager *producer_manager)
{
    if (manager == NULL || producer_manager == NULL)
    {
        return -1;
    }
    
    // 使用原子操作进行快速检查，避免不必要的锁操作
    if (atomic_load(&manager->is_recovering))
    {
        return 0; // 已经在恢复中，直接返回
    }
    
    if (atomic_load(&manager->recover_completed))
    {
        return atomic_load(&manager->recover_success) ? 0 : -1;
    }
    
    // 只有在需要启动恢复时才加锁
    CS_ENTER(manager->lock);
    
    // 双重检查，防止在加锁期间状态发生变化
    if (atomic_load(&manager->is_recovering))
    {
        CS_LEAVE(manager->lock);
        return 0;
    }
    
    if (atomic_load(&manager->recover_completed))
    {
        CS_LEAVE(manager->lock);
        return atomic_load(&manager->recover_success) ? 0 : -1;
    }
    
    // 准备线程参数
    typedef struct {
        log_persistent_manager * manager;
        log_producer_manager * producer_manager;
    } recover_thread_param_t;
    
    recover_thread_param_t * thread_param = (recover_thread_param_t *)malloc(sizeof(recover_thread_param_t));
    if (thread_param == NULL)
    {
        CS_LEAVE(manager->lock);
        return -2;
    }
    
    thread_param->manager = manager;
    thread_param->producer_manager = producer_manager;
    
    // 设置恢复状态（使用原子操作）
    atomic_store(&manager->is_recovering, 1);
    atomic_store(&manager->recover_completed, 0);
    atomic_store(&manager->recover_success, 0);
    
    // 创建恢复线程
    THREAD_INIT(manager->recover_thread, log_persistent_manager_recover_thread, thread_param);
    
    CS_LEAVE(manager->lock);
    
    aos_info_log("project %s, logstore %s, start async recover persistent manager",
                 manager->config->project,
                 manager->config->logstore);
    
    return 0;
}

int log_persistent_manager_wait_recover_complete(log_persistent_manager *manager)
{
    if (manager == NULL)
    {
        return -1;
    }
    
    // 快速检查是否已经完成，避免不必要的锁操作
    if (!atomic_load(&manager->is_recovering) && atomic_load(&manager->recover_completed))
    {
        return atomic_load(&manager->recover_success) ? 0 : -1;
    }
    
    CS_ENTER(manager->lock);
    
    // 等待恢复完成（使用原子操作）
    while (atomic_load(&manager->is_recovering) && !atomic_load(&manager->recover_completed))
    {
        COND_WAIT(manager->recover_cond, manager->lock);
    }
    
    int result = atomic_load(&manager->recover_success) ? 0 : -1;
    
    CS_LEAVE(manager->lock);
    
    // 等待线程结束
    if (manager->recover_thread)
    {
        THREAD_JOIN(manager->recover_thread);
    }
    
    // 如果恢复成功，处理缓存的日志
    if (result == 0 && manager->recover_cache != NULL)
    {
        // 这里需要获取producer_manager，我们需要通过其他方式获取
        // 暂时先记录日志，实际处理会在第一次日志添加时触发
        aos_info_log("project %s, logstore %s, recover completed, cached logs will be processed on next log add",
                     manager->config->project,
                     manager->config->logstore);
    }
    
    return result;
}

// 恢复期间日志缓存相关函数实现

int log_persistent_manager_cache_log_during_recover(log_persistent_manager * manager, const char * log_data, size_t log_size, uint32_t log_time)
{
    if (manager == NULL || manager->recover_cache == NULL || log_data == NULL || log_size == 0)
    {
        return -1;
    }
    
    CS_ENTER(manager->recover_cache_lock);
    
    // 初始化缓存UUID空间（只在第一次缓存时初始化）
    if (!manager->cache_uuid_initialized)
    {
        // 使用一个很大的基础值，确保不与正常UUID冲突
        // 正常UUID基于时间戳，缓存UUID使用负值空间
        manager->cache_log_uuid_base = -1000000000000000000LL; // 负值空间
        manager->cache_log_uuid_counter = 0;
        manager->cache_uuid_initialized = 1;
        
        aos_info_log("project %s, logstore %s, initialized cache UUID space, base %lld",
                     manager->config->project,
                     manager->config->logstore,
                     manager->cache_log_uuid_base);
    }
    
    // 检查缓存是否已满
    if (manager->recover_cache->count >= manager->recover_cache->max_count ||
        manager->recover_cache->total_size + log_size > manager->recover_cache->max_size)
    {
        // 缓存已满，丢弃最旧的日志
        if (manager->recover_cache->head != NULL)
        {
            log_recover_cache_item * old_item = manager->recover_cache->head;
            manager->recover_cache->head = old_item->next;
            if (manager->recover_cache->head == NULL)
            {
                manager->recover_cache->tail = NULL;
            }
            
            manager->recover_cache->count--;
            manager->recover_cache->total_size -= old_item->log_size;
            free(old_item->log_data);
            free(old_item);
        }
    }
    
    // 创建新的缓存项
    log_recover_cache_item * new_item = (log_recover_cache_item *)malloc(sizeof(log_recover_cache_item));
    if (new_item == NULL)
    {
        CS_LEAVE(manager->recover_cache_lock);
        return -2;
    }
    
    new_item->log_data = (char *)malloc(log_size);
    if (new_item->log_data == NULL)
    {
        free(new_item);
        CS_LEAVE(manager->recover_cache_lock);
        return -3;
    }
    
    memcpy(new_item->log_data, log_data, log_size);
    new_item->log_size = log_size;
    new_item->log_time = log_time;
    
    // 使用独立的缓存UUID空间
    new_item->uuid = manager->cache_log_uuid_base + manager->cache_log_uuid_counter++;
    new_item->next = NULL;
    
    // 添加到队列尾部
    if (manager->recover_cache->tail == NULL)
    {
        manager->recover_cache->head = new_item;
        manager->recover_cache->tail = new_item;
    }
    else
    {
        manager->recover_cache->tail->next = new_item;
        manager->recover_cache->tail = new_item;
    }
    
    manager->recover_cache->count++;
    manager->recover_cache->total_size += log_size;
    
    CS_LEAVE(manager->recover_cache_lock);
    
    aos_debug_log("project %s, logstore %s, cache log during recover, size %d, cache_uuid %lld, count %d, total_size %d",
                  manager->config->project,
                  manager->config->logstore,
                  (int)log_size,
                  new_item->uuid,
                  manager->recover_cache->count,
                  (int)manager->recover_cache->total_size);
    
    return 0;
}

int log_persistent_manager_process_recover_cache(log_persistent_manager * manager, log_producer_manager * producer_manager)
{
    if (manager == NULL || manager->recover_cache == NULL || producer_manager == NULL)
    {
        return -1;
    }
    
    // 先获取缓存锁，复制所有缓存项到临时列表
    CS_ENTER(manager->recover_cache_lock);
    
    if (manager->recover_cache->count == 0)
    {
        CS_LEAVE(manager->recover_cache_lock);
        return 0;
    }
    
    // 创建临时列表，避免长时间持有缓存锁
    log_recover_cache_item * temp_list = NULL;
    log_recover_cache_item * temp_tail = NULL;
    int temp_count = manager->recover_cache->count;
    
    log_recover_cache_item * current = manager->recover_cache->head;
    while (current != NULL)
    {
        log_recover_cache_item * temp_item = (log_recover_cache_item *)malloc(sizeof(log_recover_cache_item));
        if (temp_item == NULL)
        {
            // 内存不足，清理已分配的内存
            while (temp_list != NULL)
            {
                log_recover_cache_item * next = temp_list->next;
                free(temp_list->log_data);
                free(temp_list);
                temp_list = next;
            }
            CS_LEAVE(manager->recover_cache_lock);
            return -2;
        }
        
        temp_item->log_data = (char *)malloc(current->log_size);
        if (temp_item->log_data == NULL)
        {
            free(temp_item);
            // 内存不足，清理已分配的内存
            while (temp_list != NULL)
            {
                log_recover_cache_item * next = temp_list->next;
                free(temp_list->log_data);
                free(temp_list);
                temp_list = next;
            }
            CS_LEAVE(manager->recover_cache_lock);
            return -3;
        }
        
        memcpy(temp_item->log_data, current->log_data, current->log_size);
        temp_item->log_size = current->log_size;
        temp_item->log_time = current->log_time;
        temp_item->uuid = current->uuid;
        temp_item->next = NULL;
        
        if (temp_tail == NULL)
        {
            temp_list = temp_item;
            temp_tail = temp_item;
        }
        else
        {
            temp_tail->next = temp_item;
            temp_tail = temp_item;
        }
        
        current = current->next;
    }
    
    // 清空原始缓存队列
    manager->recover_cache->head = NULL;
    manager->recover_cache->tail = NULL;
    manager->recover_cache->count = 0;
    manager->recover_cache->total_size = 0;
    
    // 重置缓存UUID状态
    manager->cache_uuid_initialized = 0;
    manager->cache_log_uuid_base = 0;
    manager->cache_log_uuid_counter = 0;
    
    CS_LEAVE(manager->recover_cache_lock);
    
    // 现在处理临时列表，不需要持有任何锁
    int processed_count = 0;
    current = temp_list;
    
    while (current != NULL)
    {
        // 保存日志到持久化存储（这里会获取manager->lock，但不会与缓存锁冲突）
        int rst = log_persistent_manager_save_log(manager, current->log_data, current->log_size);
        if (rst == LOG_PRODUCER_OK)
        {
            // 添加到发送队列（使用新分配的UUID）
            rst = log_producer_manager_add_log_raw(producer_manager, current->log_data, current->log_size, 0, manager->checkpoint.now_log_uuid - 1);
            if (rst == LOG_PRODUCER_OK)
            {
                processed_count++;
                aos_debug_log("project %s, logstore %s, process cached log success, cache_uuid %lld -> normal_uuid %lld, size %d",
                              manager->config->project,
                              manager->config->logstore,
                              current->uuid,
                              manager->checkpoint.now_log_uuid - 1,
                              (int)current->log_size);
            }
            else
            {
                aos_error_log("project %s, logstore %s, add cached log to producer manager failed, cache_uuid %lld, result %d",
                              manager->config->project,
                              manager->config->logstore,
                              current->uuid,
                              rst);
            }
        }
        else
        {
            aos_error_log("project %s, logstore %s, save cached log failed, cache_uuid %lld, result %d",
                          manager->config->project,
                          manager->config->logstore,
                          current->uuid,
                          rst);
        }
        
        // 移动到下一个
        log_recover_cache_item * next = current->next;
        free(current->log_data);
        free(current);
        current = next;
    }
    
    aos_info_log("project %s, logstore %s, process recover cache completed, processed %d logs",
                 manager->config->project,
                 manager->config->logstore,
                 processed_count);
    
    return processed_count;
}

void log_persistent_manager_clear_recover_cache(log_persistent_manager * manager)
{
    if (manager == NULL || manager->recover_cache == NULL)
    {
        return;
    }
    
    CS_ENTER(manager->recover_cache_lock);
    
    log_recover_cache_item * current = manager->recover_cache->head;
    while (current != NULL)
    {
        log_recover_cache_item * next = current->next;
        free(current->log_data);
        free(current);
        current = next;
    }
    
    manager->recover_cache->head = NULL;
    manager->recover_cache->tail = NULL;
    manager->recover_cache->count = 0;
    manager->recover_cache->total_size = 0;
    
    CS_LEAVE(manager->recover_cache_lock);
    
    aos_info_log("project %s, logstore %s, clear recover cache completed",
                 manager->config->project,
                 manager->config->logstore);
}
