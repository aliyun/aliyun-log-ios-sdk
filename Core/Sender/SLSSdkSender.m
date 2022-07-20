//
//  SLSSdkSender.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSSdkSender.h"
#import "AliyunLogProducer/AliyunLogProducer.h"

@interface SLSSdkSender ()

@property(nonatomic, strong) LogProducerClient *client;
@property(nonatomic, strong) LogProducerConfig *config;
- (NSString *) getLogstoreByInstanceId: (NSString *) instanceId;
@end

@implementation SLSSdkSender

+ (instancetype) sender {
    return [[SLSSdkSender alloc] init];
}

- (void) initialize: (SLSCredentials *) credentials {
    NSString *endpoint = credentials.endpoint;
    NSString *project = credentials.project;
    NSString *logstore = [self getLogstoreByInstanceId:credentials.instanceId];
    
    _config = [[LogProducerConfig alloc]
               initWithEndpoint:endpoint
               project:project
               logstore:logstore
               accessKeyID:credentials.accessKeyId
               accessKeySecret:credentials.accessKeySecret
               securityToken:credentials.securityToken
    ];
    
    [_config SetTopic:@"sls_ios"];
    [_config SetPacketLogBytes:(1024 * 1024)];
    [_config SetPacketLogCount: 4096];
    [_config SetPacketTimeout:2000];
    [_config SetMaxBufferLimit:(64*1024*1024)];
    [_config SetSendThreadCount:1];
    
    [_config SetPersistent:1];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths lastObject] stringByAppendingString:@"/sls_ios.dat"];
    [_config SetPersistentFilePath:path];
    [_config SetPersistentForceFlush:0];
    [_config SetPersistentMaxFileCount:10];
    [_config SetPersistentMaxFileSize:(1024*1024*10)];
    [_config SetPersistentMaxLogCount:65536];
    [_config SetDropDelayLog:0];
    [_config SetDropUnauthorizedLog:0];
    
    _client = [[LogProducerClient alloc] initWithLogProducerConfig:self.config callback:_on_log_send_done];
}
- (BOOL) send: (Log *) log {
    if (!_client) {
        return NO;
    }
    
    return LogProducerOK == [_client AddLog:log];
}
- (BOOL) onEnd: (SLSSpan *)span {
    if (!span) {
        return NO;
    }
    
    Log *log = [Log log];
    [log putContents:[span toDict]];
    
    return [self send:log];
}
- (void) setCredentials: (SLSCredentials *) credentials {
    
}

- (NSString *) getLogstoreByInstanceId: (NSString *) instanceId {
    if (!instanceId) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@-track-raw", instanceId];
}

static void _on_log_send_done(
                              const char * config_name,
                              log_producer_result result,
                              size_t log_bytes,
                              size_t compressed_bytes,
                              const char * req_id,
                              const char * message,
                              const unsigned char * raw_buffer,
                              void * userparams
                              ) {
    SLSLogV(@"send success, config : %s, result : %d, log bytes : %zu, compressed bytes : %zu, request id : %s", config_name, result, log_bytes, compressed_bytes, req_id);
}

@end
