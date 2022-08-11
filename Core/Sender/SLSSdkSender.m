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

- (NSString *) provideLogFileName: (SLSCredentials *) credentials {
    return @"data.dat";
}
- (NSString *) provideEndpoint: (SLSCredentials *) credentials {
    return credentials.endpoint;
}
- (NSString *) provideProjectName: (SLSCredentials *) credentials {
    return credentials.project;
}
- (NSString *) provideLogstoreName: (SLSCredentials *) credentials {
    return [self getLogstoreByInstanceId:credentials.instanceId];
}
- (NSString *) provideAccessKeyId: (SLSCredentials *) credentials {
    return credentials.accessKeyId;
}
- (NSString *) provideAccessKeySecret: (SLSCredentials *) credentials {
    return credentials.accessKeySecret;
}
- (NSString *) provideSecurityToken: (SLSCredentials *) credentials {
    return credentials.securityToken;
}

- (void) initialize: (SLSCredentials *) credentials {
    NSString *endpoint = [self provideEndpoint:credentials];
    NSString *project = [self provideProjectName:credentials];
    NSString *logstore = [self provideLogstoreName:credentials];
    
    NSString *accessKeyId = [self provideAccessKeyId:credentials];
    NSString *accessKeySecret = [self provideAccessKeySecret:credentials];
    NSString *securityToken = [self provideSecurityToken:credentials];
    
    _config = [[LogProducerConfig alloc]
               initWithEndpoint:endpoint
               project:project
               logstore:logstore
               accessKeyID:accessKeyId
               accessKeySecret:accessKeySecret
               securityToken:securityToken
    ];
    
    [_config SetTopic:@"sls_ios"];
    [_config SetPacketLogBytes:(1024 * 1024)];
    [_config SetPacketLogCount: 4096];
    [_config SetPacketTimeout:2000];
    [_config SetMaxBufferLimit:(64*1024*1024)];
    [_config SetSendThreadCount:1];
    
    NSString *fileName = [self provideLogFileName:credentials];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[[paths lastObject] stringByAppendingPathComponent:@"sls"] stringByAppendingPathComponent:@"logs"];
    BOOL isDir = FALSE;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [_config SetPersistent:1];
    [_config SetPersistentFilePath:[path stringByAppendingPathComponent:fileName]];
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
    if (!_config || !credentials) {
        return;
    }
    
    if (credentials.securityToken && credentials.securityToken.length > 0) {
        if (credentials.accessKeyId && credentials.accessKeyId.length > 0
            && credentials.accessKeySecret && credentials.accessKeySecret.length > 0) {
            [_config ResetSecurityToken:credentials.accessKeyId
                        accessKeySecret:credentials.accessKeySecret
                          securityToken:credentials.securityToken
            ];
        }
    } else {
        if (credentials.accessKeyId && credentials.accessKeyId.length > 0
            && credentials.accessKeySecret && credentials.accessKeySecret.length > 0) {
            [_config setAccessKeyId:credentials.accessKeyId];
            [_config setAccessKeySecret:credentials.accessKeySecret];
        }

    }
    
    if (credentials.endpoint && credentials.endpoint.length > 0) {
        [_config setEndpoint:credentials.endpoint];
    }
    if (credentials.project && credentials.project.length > 0) {
        [_config setProject:credentials.project];
    }
    if (credentials.instanceId && credentials.instanceId.length > 0) {
        [_config setLogstore:[self getLogstoreByInstanceId:credentials.instanceId]];
    }
    
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
