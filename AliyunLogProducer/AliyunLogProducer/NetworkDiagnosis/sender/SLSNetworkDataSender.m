//
//  SLSNetworkDataSender.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/27.
//

#import "SLSNetworkDataSender.h"
#import <AliyunLogProducer/AliyunLogProducer.h>

@interface SLSNetworkDataSender ()
@property(nonatomic, strong) LogProducerConfig *config;
@property(nonatomic, strong) LogProducerClient *client;

@end

@implementation SLSNetworkDataSender
- (void) initWithSLSConfig: (SLSConfig *)config {
    NSString *endpoint = @"https://cn-shanghai.log.aliyuncs.com";
    NSString *project = @"sls-aysls-network-diagnosis";
    NSString *storeName = @"central-logsotre";
    SLSLogV(@"endpoint: %@, project: %@, store: %@", endpoint, project, storeName);
    
    _config = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:storeName];
    
    [_config SetTopic:@"network_diagnosis"];
    [_config SetPacketLogBytes:(1024 * 1024 * 5)];
    [_config SetPacketLogCount: 4096];
    [_config SetMaxBufferLimit:(64*1024*1024)];
    [_config SetPacketTimeout:2000];
    [_config SetSendThreadCount:1];
    
    [_config SetPersistent:1];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths lastObject] stringByAppendingString:@"/network_log.dat"];
    [_config SetPersistentFilePath:path];
    [_config SetPersistentForceFlush:0];
    [_config SetPersistentMaxFileCount:10];
    [_config SetPersistentMaxFileSize:(1024*1024*10)];
    [_config SetPersistentMaxLogCount:65536];
    [_config SetDropDelayLog:0];
    [_config SetDropUnauthorizedLog:0];
    
    [_config setUseWebtracking:YES];

    _client = [[LogProducerClient alloc]initWithLogProducerConfig:_config callback:_on_log_send_done];
}

static void _on_log_send_done(const char * config_name, log_producer_result result, size_t log_bytes, size_t compressed_bytes, const char * req_id, const char * message, const unsigned char * raw_buffer, void * userparams) {
    if (result == LOG_PRODUCER_OK) {
        SLSLogV(@"report success. config: %s, result: %d, log bytes: %d, compressed bytes: %d, request id: %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id);
    } else {
        SLSLogV(@"report fail. config: %s, result: %d, log bytes: %d, compressed bytes: %d, request id: %s, error message : %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id, message);
    }
}

- (BOOL) sendDada: (TCData *)tcdata {
    if(nil == _client) {
        return NO;
    }
    
    if(nil == tcdata) {
        return NO;
    }
    
    __block Log *log = [[Log alloc] init];
    [[tcdata toDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [log PutContent:key value:obj];
    }];
    
    [TimeUtils fixTime:log];
    
    return LogProducerOK == [_client AddLog:log];
}

- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    
}

- (void) resetProject: (NSString *)endpoint project:(NSString *)project logstore:(NSString *)logstore {
    
}
@end
