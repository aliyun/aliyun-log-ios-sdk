//
// Created by davidzhang on 2020/8/23.
//

#include "log_inner_include.h"
#include "log_producer_config.h"
#include "log_ring_file.h"
#include "log_builder.h"
#include "log_producer_manager.h"

#ifndef LOG_C_SDK_LOG_PERSISTENT_MANAGER_H
#define LOG_C_SDK_LOG_PERSISTENT_MANAGER_H

typedef struct _log_persistent_checkpoint {
    uint64_t version;
    unsigned char signature[16]; // persistent config signature
    uint64_t start_file_offset; // logic file start offset in buffer
    uint64_t now_file_offset; // logic now file offset
    int64_t start_log_uuid; // start log uuid in buffer
    int64_t now_log_uuid; // now log uuid
    uint64_t check_sum; // start_file_offset + now_file_offset + start_log_uuid + now_log_uuid
    unsigned char preserved[32];
}log_persistent_checkpoint;

typedef struct _log_persistent_item_header
{
    uint64_t magic_code;
    int64_t log_uuid;
    int64_t log_size;
    uint64_t preserved;
}log_persistent_item_header;

// 恢复期间日志缓存项
typedef struct _log_recover_cache_item {
    char * log_data;
    size_t log_size;
    uint32_t log_time;
    int64_t uuid;
    struct _log_recover_cache_item * next;
} log_recover_cache_item;

// 恢复期间日志缓存队列
typedef struct _log_recover_cache_queue {
    log_recover_cache_item * head;
    log_recover_cache_item * tail;
    int32_t count;
    int32_t max_count;
    size_t total_size;
    size_t max_size;
} log_recover_cache_queue;

typedef struct _log_persistent_manager{
    CRITICALSECTION lock;
    log_persistent_checkpoint checkpoint;
    uint32_t * in_buffer_log_sizes;
    log_producer_config * config;
    log_group_builder * builder;
    int8_t is_invalid;
    int8_t first_checkpoint_saved;
    log_ring_file * ring_file;

    FILE * checkpoint_file_ptr;
    char * checkpoint_file_path;
    size_t checkpoint_file_size;
    
    // 异步恢复相关字段（使用原子变量确保线程安全）
    _Atomic int8_t is_recovering;
    _Atomic int8_t recover_completed;
    _Atomic int8_t recover_success;
    THREAD recover_thread;
    COND recover_cond;
    
    // 恢复期间日志缓存队列
    log_recover_cache_queue * recover_cache;
    CRITICALSECTION recover_cache_lock;
    
    // UUID管理：防止缓存日志与正常写入冲突
    int64_t cache_log_uuid_base;      // 缓存日志的UUID基础值
    int64_t cache_log_uuid_counter;   // 缓存日志的UUID计数器
    int8_t cache_uuid_initialized;    // 缓存UUID是否已初始化
}log_persistent_manager;


log_persistent_manager * create_log_persistent_manager(log_producer_config * config);
void destroy_log_persistent_manager(log_persistent_manager * manager);

void on_log_persistent_manager_send_done_uuid(const char * config_name,
                                               log_producer_result result,
                                               size_t log_bytes,
                                               size_t compressed_bytes,
                                               const char * req_id,
                                               const char * error_message,
                                               const unsigned char * raw_buffer,
                                               void *persistent_manager,
                                               int64_t startId,
                                               int64_t endId);

int log_persistent_manager_save_log(log_persistent_manager * manager, const char * logBuf, size_t logSize);
int log_persistent_manager_is_buffer_enough(log_persistent_manager * manager, size_t logSize);

int save_log_checkpoint(log_persistent_manager * manager);

int log_persistent_manager_recover(log_persistent_manager * manager, log_producer_manager * producer_manager);
int log_persistent_manager_recover_async(log_persistent_manager * manager, log_producer_manager * producer_manager);
int log_persistent_manager_wait_recover_complete(log_persistent_manager * manager);

// 恢复期间日志缓存相关函数
int log_persistent_manager_cache_log_during_recover(log_persistent_manager * manager, const char * log_data, size_t log_size, uint32_t log_time);
int log_persistent_manager_process_recover_cache(log_persistent_manager * manager, log_producer_manager * producer_manager);
void log_persistent_manager_clear_recover_cache(log_persistent_manager * manager);

#endif //LOG_C_SDK_LOG_PERSISTENT_MANAGER_H
