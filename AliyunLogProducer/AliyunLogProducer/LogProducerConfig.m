//
//  LogProducerConfig.m
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogProducerConfig.h"
#import "inner_log.h"



@interface LogProducerConfig ()

@end

@implementation LogProducerConfig

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret
{
    if (self = [super init])
    {
        self = [self initWithEndpoint:endpoint project:project logstore:logstore];
        const char *accesskeyidChar=[accessKeyID UTF8String];
        log_producer_config_set_access_id(config, accesskeyidChar);
        const char *accesskeysecretChar=[accessKeySecret UTF8String];
        log_producer_config_set_access_key(config, accesskeysecretChar);
    }

    return self;
}

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken
{
    if (self = [super init])
    {
        self = [self initWithEndpoint:endpoint project:project logstore:logstore];
        const char *accesskeyidChar=[accessKeyID UTF8String];
        const char *accesskeysecretChar=[accessKeySecret UTF8String];
        const char *securityTokenChar=[securityToken UTF8String];
        log_producer_config_reset_security_token(config, accesskeyidChar, accesskeysecretChar, securityTokenChar);
    }

    return self;
}

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore
{
    if (self = [super init])
    {
        config = create_log_producer_config();
        
        const char *endpointChar=[endpoint UTF8String];
        log_producer_config_set_endpoint(config, endpointChar);
        const char *projectChar=[project UTF8String];
        log_producer_config_set_project(config, projectChar);
        const char *logstoreChar=[logstore UTF8String];
        log_producer_config_set_logstore(config, logstoreChar);

        log_producer_config_set_packet_timeout(config, 3000);
        log_producer_config_set_packet_log_count(config, 1024);
        log_producer_config_set_packet_log_bytes(config, 1024*1024);
        log_producer_config_set_send_thread_count(config, 1);
    }

    return self;
}

- (void)SetTopic:(NSString *) topic
{
    const char *topicChar=[topic UTF8String];
    log_producer_config_set_topic(config, topicChar);
}

- (void)AddTag:(NSString *) key value:(NSString *)value
{
    const char *keyChar=[key UTF8String];
    const char *valueChar=[value UTF8String];
    log_producer_config_add_tag(config, keyChar, valueChar);
}

- (void)SetPacketLogBytes:(int) num
{
    log_producer_config_set_packet_log_bytes(config, num);
}

- (void)SetPacketLogCount:(int) num
{
    log_producer_config_set_packet_log_count(config, num);
}

- (void)SetPacketTimeout:(int) num
{
    log_producer_config_set_packet_timeout(config, num);
}

- (void)SetMaxBufferLimit:(int) num
{
    log_producer_config_set_max_buffer_limit(config, num);
}

- (void)SetSendThreadCount:(int) num
{
    log_producer_config_set_send_thread_count(config, num);
}

- (void)SetPersistent:(int) num
{
    log_producer_config_set_persistent(config, num);
}

- (void)SetPersistentFilePath:(NSString *) path
{
    const char *pathChar=[path UTF8String];
    log_producer_config_set_persistent_file_path(config, pathChar);
}

- (void)SetPersistentForceFlush:(int) num
{
    log_producer_config_set_persistent_force_flush(config, num);
}

- (void)SetPersistentMaxFileCount:(int ) num
{
    log_producer_config_set_persistent_max_file_count(config, num);
}

- (void)SetPersistentMaxFileSize:(int) num
{
    log_producer_config_set_persistent_max_file_size(config, num);
}

- (void)SetPersistentMaxLogCount:(int) num
{
    log_producer_config_set_persistent_max_log_count(config, num);
}

- (void)ResetSecurityToken:(NSString *) accessKeyID accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken
{
    const char *accessKeyIDChar=[accessKeyID UTF8String];
    const char *accessKeySecretChar=[accessKeySecret UTF8String];
    const char *securityTokenChar=[securityToken UTF8String];
    log_producer_config_reset_security_token(config, accessKeyIDChar, accessKeySecretChar, securityTokenChar);
}

+ (void)Debug
{
    aos_log_set_level(AOS_LOG_DEBUG);
}


@end
