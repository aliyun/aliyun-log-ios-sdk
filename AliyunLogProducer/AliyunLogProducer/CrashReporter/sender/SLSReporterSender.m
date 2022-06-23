//
//  SLSReporterSender.m
//  AliyunLogCrashReporter
//
//  Created by gordon on 2021/5/19.
//

#import "SLSSystemCapabilities.h"
#import "SLSReporterSender.h"

@implementation SLSReporterSender

LogProducerConfig *logConfig = nil;
LogProducerClient *client = nil;
NSString *endpoint;
NSString *project;
NSString * const logstore = @"sls-alysls-track-base";
NSString *accessKeyId;
NSString *accessKeySec;
NSString *securityToken;

- (void)initWithSLSConfig:(SLSConfig *)config {
    endpoint = config.endpoint;
    project = config.pluginLogproject;
    SLSLogV(@"endpoint: %@, project: %@", endpoint, project);
    
    logConfig = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:config.accessKeyId accessKeySecret:config.accessKeySecret securityToken:config.securityToken];
    
    [logConfig SetTopic:@"crash_report"];

#if SLS_HOST_MAC
    [logConfig AddTag:@"crash_report" value:@"macOS"];
#elif SLS_HOST_TV
    [logConfig AddTag:@"crash_report" value:@"tvOS"];
#else
    [logConfig AddTag:@"crash_report" value:@"iOS"];
#endif
    
    [logConfig SetPacketLogBytes:(1024 * 1024 * 5)];
    [logConfig SetPacketLogCount: 4096];
    [logConfig SetMaxBufferLimit:(64*1024*1024)];
    [logConfig SetPacketTimeout:100];
    [logConfig SetSendThreadCount:1];
    
    [logConfig SetPersistent:1];
#if SLS_HOST_TV
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
#endif
    NSString *path = [[paths lastObject] stringByAppendingString:@"/crash_log.dat"];
    [logConfig SetPersistentFilePath:path];
    [logConfig SetPersistentForceFlush:0];
    [logConfig SetPersistentMaxFileCount:10];
    [logConfig SetPersistentMaxFileSize:(1024*1024*10)];
    [logConfig SetPersistentMaxLogCount:65536];
    [logConfig SetDropDelayLog:0];
    [logConfig SetDropUnauthorizedLog:0];
    
    client = [[LogProducerClient alloc]initWithLogProducerConfig:logConfig callback:on_log_send_done];
}

- (void)resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    SLSLogV(@"accessKeyId: %@, accessKeySecret: %@, token: %@", accessKeyId, accessKeySecret, token);
    if ([token length] == 0) {
        [logConfig setAccessKeyId:accessKeyId];
        [logConfig setAccessKeySecret:accessKeySecret];
    } else {
        [logConfig ResetSecurityToken:accessKeyId accessKeySecret:accessKeySecret securityToken:token];
    }
}

- (void) resetProject:(NSString *)endpoint project:(NSString *)project logstore:(NSString *)logstore {
    SLSLogV(@"endpoint: %@, project: %@, logstore: %@", endpoint, project, logstore);
    [logConfig setEndpoint:endpoint];
    [logConfig setProject:project];
//    [logConfig setLogstore:logstore];
}

void on_log_send_done(const char * config_name, log_producer_result result, size_t log_bytes, size_t compressed_bytes, const char * req_id, const char * message, const unsigned char * raw_buffer, void * userparams) {
    if (result == LOG_PRODUCER_OK) {
        SLSLogV(@"report success. config: %s, result: %d, log bytes: %d, compressed bytes: %d, request id: %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id);
    } else {
        SLSLog(@"report fail. config: %s, result: %d, log bytes: %d, compressed bytes: %d, request id: %s, error message : %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id, message);
    }
}

- (BOOL)sendDada:(TCData *)tcdata {
    if(nil == client) {
        return NO;
    }
    
    if(nil == tcdata) {
        return NO;
    }
    
    Log *log = [[Log alloc] init];
    NSDictionary *dict = [tcdata toDictionary];
    for (NSString *key in dict.allKeys) {
        [log PutContent:key value:[dict objectForKey:key]];
    }
    
    [TimeUtils fixTime:log];
    
    return LogProducerOK == [client AddLog:log];
}

@end
