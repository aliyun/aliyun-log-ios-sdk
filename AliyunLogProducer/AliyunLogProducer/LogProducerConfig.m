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
#import "LogProducerConfig.h"
#import "inner_log.h"



@interface LogProducerConfig ()

@end

@implementation LogProducerConfig

static NSString *VERSION = @"sls-ios-sdk_v2.2.12";
static NSInteger LocalServerDeltaTime = 0;
NSLock *TimeLock;


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
            double serverTime = [timeVal doubleValue];
            if (serverTime > 1500000000 && serverTime < 4294967294) {
                int sysTime = [[NSDate date] timeIntervalSince1970];
                int deltaTime = serverTime - sysTime;
                if (deltaTime > 600 || deltaTime < -600) {
                    [TimeLock lock];
                    LocalServerDeltaTime = deltaTime;
                    [TimeLock unlock];
                }
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
            SLSLog(@"%@: %@ %@", VERSION, error, res);
            if (error.code == kCFURLErrorUserCancelledAuthentication)
                return 401;
            if (error.code == kCFURLErrorBadServerResponse)
                return 500;
        }
        return -1;
    }
}

+ (void)load{
    TimeLock = [[NSLock alloc] init];
    log_set_http_post_func(os_http_post);
}

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
        
        log_set_get_time_unix_func(time_func);
    }

    return self;
}

unsigned int time_func(){
    return time(NULL) + LocalServerDeltaTime;
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

- (void)SetUsingHttp:(int) num;
{
    log_producer_config_set_using_http(config, num);
}

- (void)SetNetInterface:(NSString *) netInterface;
{
    const char *netInterfaceChar=[netInterface UTF8String];
    log_producer_config_set_net_interface(config, netInterfaceChar);
}

- (void)SetConnectTimeoutSec:(int) num;
{
    log_producer_config_set_connect_timeout_sec(config, num);
}

- (void)SetSendTimeoutSec:(int) num;
{
    log_producer_config_set_send_timeout_sec(config, num);
}

- (void)SetDestroyFlusherWaitSec:(int) num;
{
    log_producer_config_set_destroy_flusher_wait_sec(config, num);
}

- (void)SetDestroySenderWaitSec:(int) num;
{
    log_producer_config_set_destroy_sender_wait_sec(config, num);
}

- (void)SetCompressType:(int) num;
{
    log_producer_config_set_compress_type(config, num);
}

- (void)SetNtpTimeOffset:(int) num;
{
    log_producer_config_set_ntp_time_offset(config, num);
}

- (void)SetMaxLogDelayTime:(int) num;
{
    log_producer_config_set_max_log_delay_time(config, num);
}

- (void)SetDropDelayLog:(int) num;
{
    log_producer_config_set_drop_delay_log(config, num);
}

- (void)SetDropUnauthorizedLog:(int) num;
{
    log_producer_config_set_drop_unauthorized_log(config, num);
}

- (void)SetGetTimeUnixFunc:(unsigned int (*)()) f;
{
    log_set_get_time_unix_func(f);
}

- (int)IsValid;
{
    return log_producer_config_is_valid(config);
}

- (int)IsEnabled;
{
    return log_producer_persistent_config_is_enabled(config);
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
