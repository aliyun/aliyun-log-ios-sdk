//
//  LogProducerConfig.h
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#ifndef LogProducerConfig_h
#define LogProducerConfig_h


#endif /* LogProducerConfig_h */

#import "log_producer_config.h"
#import "log_http_interface.h"


@interface LogProducerConfig : NSObject
{
    @package log_producer_config* config;
}

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret;

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken;

- (id) initWithEndpoint:(NSString *) endpoint project:(NSString *)project logstore:(NSString *)logstore;

- (void)SetTopic:(NSString *) topic;

- (void)AddTag:(NSString *) key value:(NSString *)value;

- (void)SetPacketLogBytes:(int) num;

- (void)SetPacketLogCount:(int) num;

- (void)SetPacketTimeout:(int) num;

- (void)SetMaxBufferLimit:(int) num;

- (void)SetSendThreadCount:(int) num;

- (void)SetPersistent:(int) num;

- (void)SetPersistentFilePath:(NSString *) path;

- (void)SetPersistentForceFlush:(int) num;

- (void)SetPersistentMaxFileCount:(int) num;

- (void)SetPersistentMaxFileSize:(int) num;

- (void)SetPersistentMaxLogCount:(int) num;

- (void)SetUsingHttp:(int) num;

- (void)SetNetInterface:(NSString *) netInterface;

- (void)SetConnectTimeoutSec:(int) num;

- (void)SetSendTimeoutSec:(int) num;

- (void)SetDestroyFlusherWaitSec:(int) num;

- (void)SetDestroySenderWaitSec:(int) num;

- (void)SetCompressType:(int) num;

- (void)SetNtpTimeOffset:(int) num;

- (void)SetMaxLogDelayTime:(int) num;

- (void)SetDropDelayLog:(int) num;

- (void)SetDropUnauthorizedLog:(int) num;

- (void)SetGetTimeUnixFunc:(unsigned int (*)()) f;

- (int)IsValid;

- (int)IsEnabled;

- (void)ResetSecurityToken:(NSString *) accessKeyID accessKeySecret:(NSString *)accessKeySecret securityToken:(NSString *)securityToken;

+ (void)Debug;

@end
