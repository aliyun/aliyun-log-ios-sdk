//
//  LogProducerConfig.m
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#ifdef DEBUG
#define SLSLog(...) NSLog(__VA_ARGS__)
#else
#define SLSLog(...)
#endif

#import <Foundation/Foundation.h>
#import "AliyunLogProducerConfig.h"
#import "inner_log.h"
#import "TimeUtils.h"



@interface AliyunLogProducerConfig ()

@end

@implementation AliyunLogProducerConfig

static NSString *VERSION = @"sls-ios-sdk_v2.2.25";

static int os_http_post(const char *url,
                char **header_array,
                int header_count,
                const void *data,
                int data_len)
{
    if(url == NULL || *url == 0 || header_array == NULL || header_count < 1 || data == NULL || data_len <= 0)
        return 400; // bad request

    NSString *urlString = [NSString stringWithUTF8String:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:urlString]];

    // set headers
    for(int i=0; i<header_count; i++) {
        char *kv = header_array[i];
        if(kv != NULL) {
            char *eq = strchr(kv, ':');
            if(eq != NULL && eq != kv && eq[1] != 0) {
                *eq = 0;
                [request addValue:[NSString stringWithUTF8String:eq+1] forHTTPHeaderField:[NSString stringWithUTF8String:kv]];
                *eq = '='; // restore
            }
        }
    }

    [request setValue:VERSION forHTTPHeaderField:@"User-Agent"];

    // set body
    NSData *postData = [NSData dataWithBytes:data length:data_len];
    [request setHTTPBody:postData];

    // send
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *resData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(response != nil){
        int responseCode = (int)[response statusCode];
        NSDictionary *fields = [response allHeaderFields];
        NSString *timeVal = fields[@"x-log-time"];
        if ([timeVal length] != 0) {
            NSInteger serverTime = [timeVal integerValue];
            if (serverTime > 1500000000 && serverTime < 4294967294) {
                [TimeUtils updateServerTime:serverTime];
            }
        }
        if (responseCode != 200) {
            NSString *res = [[NSString alloc] initWithData:resData encoding:NSUTF8StringEncoding];
            SLSLog(@"%@: %ld %@ %@", VERSION, [response statusCode], [response allHeaderFields], res);
        }
        return responseCode;
    }
    else {
        if(error != nil){
            NSString *res = [[NSString alloc] initWithData:resData encoding:NSUTF8StringEncoding];
            SLSLog(@"%@: error: %@, res:%@", VERSION, error, res);
            if (error.code == kCFURLErrorUserCancelledAuthentication)
                return 401;
            if (error.code == kCFURLErrorBadServerResponse)
                return 500;
        }
        return -1;
    }
}

+ (void)load{
    log_set_http_post_func(os_http_post);
}


- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore
{
    if (self = [super init])
    {
        self = [self initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:nil accessKeySecret:nil];
    }

    return self;
}

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret
{
    if (self = [super init])
    {
        self = [self initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:accessKeyID accessKeySecret:accessKeySecret securityToken:nil];
    }

    return self;
}

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken
{
    if (self = [super init])
    {
        self->config = create_log_producer_config();
        const char *sourceChar = "iOS";
        log_producer_config_set_source(self->config, sourceChar);
        log_producer_config_set_packet_timeout(self->config, 3000);
        log_producer_config_set_packet_log_count(self->config, 1024);
        log_producer_config_set_packet_log_bytes(self->config, 1024*1024);
        log_producer_config_set_send_thread_count(self->config, 1);
        log_producer_config_set_drop_unauthorized_log(self->config, 0);
        log_producer_config_set_drop_delay_log(self->config, 0);
        log_set_get_time_unix_func(time_func);

        [self setEndpoint:endpoint];
        [self setProject:project];
        [self setLogstore:logstore];
        [self setAccessKeyId:accessKeyID];
        [self setAccessKeySecret:accessKeySecret];
        if ([securityToken length] != 0) {
            [self ResetSecurityToken:accessKeyID accessKeySecret:accessKeySecret securityToken:securityToken];
        }
    }

    return self;
}

unsigned int time_func() {
    NSInteger timeInMillis = [TimeUtils getTimeInMilliis];
    return timeInMillis;
}

- (void)setEndpoint:(NSString *)endpoint
{
    if ([endpoint length] == 0) {
        endpoint = @"please_set_endpoint";
    }
    self->endpoint = endpoint;
    log_producer_config_set_endpoint(self->config, [endpoint UTF8String]);
}

- (NSString *)getEndpoint
{
    return self->endpoint;
}

- (void)setProject:(NSString *)project
{
    if ([project length] == 0) {
        project = @"please_set_project";
    }
    self->project = project;
    log_producer_config_set_project(self->config, [project UTF8String]);
}

- (NSString *)getProject
{
    return self->project;
}

- (void)setLogstore:(NSString *)logstore
{
    if ([logstore length] == 0) {
        logstore = @"please_set_logstore";
    }
    self->logstore = logstore;
    log_producer_config_set_logstore(self->config, [logstore UTF8String]);
}

- (void)SetTopic:(NSString *) topic
{
    const char *topicChar=[topic UTF8String];
    log_producer_config_set_topic(self->config, topicChar);
}

- (void)SetSource:(NSString *)source
{
    const char *sourceChar = [source UTF8String];
    log_producer_config_set_source(self->config, sourceChar);
}

- (void)AddTag:(NSString *) key value:(NSString *)value
{
    const char *keyChar=[key UTF8String];
    const char *valueChar=[value UTF8String];
    log_producer_config_add_tag(self->config, keyChar, valueChar);
}

- (void)SetPacketLogBytes:(int) num
{
    log_producer_config_set_packet_log_bytes(self->config, num);
}

- (void)SetPacketLogCount:(int) num
{
    log_producer_config_set_packet_log_count(self->config, num);
}

- (void)SetPacketTimeout:(int) num
{
    log_producer_config_set_packet_timeout(self->config, num);
}

- (void)SetMaxBufferLimit:(int) num
{
    log_producer_config_set_max_buffer_limit(self->config, num);
}

- (void)SetSendThreadCount:(int) num
{
    log_producer_config_set_send_thread_count(self->config, num);
}

- (void)SetPersistent:(int) num
{
    log_producer_config_set_persistent(self->config, num);
}

- (void)SetPersistentFilePath:(NSString *) path
{
    const char *pathChar=[path UTF8String];
    log_producer_config_set_persistent_file_path(self->config, pathChar);
}

- (void)SetPersistentForceFlush:(int) num
{
    log_producer_config_set_persistent_force_flush(self->config, num);
}

- (void)SetPersistentMaxFileCount:(int ) num
{
    log_producer_config_set_persistent_max_file_count(self->config, num);
}

- (void)SetPersistentMaxFileSize:(int) num
{
    log_producer_config_set_persistent_max_file_size(self->config, num);
}

- (void)SetPersistentMaxLogCount:(int) num
{
    log_producer_config_set_persistent_max_log_count(self->config, num);
}

- (void)SetUsingHttp:(int) num;
{
    log_producer_config_set_using_http(self->config, num);
}

- (void)SetNetInterface:(NSString *) netInterface;
{
    const char *netInterfaceChar=[netInterface UTF8String];
    log_producer_config_set_net_interface(self->config, netInterfaceChar);
}

- (void)SetConnectTimeoutSec:(int) num;
{
    log_producer_config_set_connect_timeout_sec(self->config, num);
}

- (void)SetSendTimeoutSec:(int) num;
{
    log_producer_config_set_send_timeout_sec(self->config, num);
}

- (void)SetDestroyFlusherWaitSec:(int) num;
{
    log_producer_config_set_destroy_flusher_wait_sec(self->config, num);
}

- (void)SetDestroySenderWaitSec:(int) num;
{
    log_producer_config_set_destroy_sender_wait_sec(self->config, num);
}

- (void)SetCompressType:(int) num;
{
    log_producer_config_set_compress_type(self->config, num);
}

- (void)SetNtpTimeOffset:(int) num;
{
    log_producer_config_set_ntp_time_offset(self->config, num);
}

- (void)SetMaxLogDelayTime:(int) num;
{
    log_producer_config_set_max_log_delay_time(self->config, num);
}

- (void)SetDropDelayLog:(int) num;
{
    log_producer_config_set_drop_delay_log(self->config, num);
}

- (void)SetDropUnauthorizedLog:(int) num;
{
    log_producer_config_set_drop_unauthorized_log(self->config, num);
}

- (void)SetGetTimeUnixFunc:(unsigned int (*)()) f;
{
    log_set_get_time_unix_func(f);
}

- (int)IsValid;
{
    return log_producer_config_is_valid(self->config);
}

- (int)IsEnabled;
{
    return log_producer_persistent_config_is_enabled(self->config);
}

- (void)setAccessKeyId:(NSString *)accessKeyId
{
    if ([accessKeyId length] == 0) {
        accessKeyId = @"please_set_accesskeyid";
    }
    log_producer_config_set_access_id(self->config, [accessKeyId UTF8String]);
}

- (void)setAccessKeySecret:(NSString *)accessKeySecret
{
    if ([accessKeySecret length] == 0){
        accessKeySecret = @"please_set_accesskeysecret";
    }
    log_producer_config_set_access_key(self->config, [accessKeySecret UTF8String]);
}

- (void)ResetSecurityToken:(NSString *) accessKeyID accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken
{
    if ([accessKeyID length] == 0 || [accessKeySecret length] == 0 || [securityToken length] == 0) {
        return;
    }
    
    const char *accessKeyIDChar=[accessKeyID UTF8String];
    const char *accessKeySecretChar=[accessKeySecret UTF8String];
    const char *securityTokenChar=[securityToken UTF8String];
    log_producer_config_reset_security_token(self->config, accessKeyIDChar, accessKeySecretChar, securityTokenChar);
}

+ (void)Debug
{
    aos_log_set_level(AOS_LOG_DEBUG);
}


@end
