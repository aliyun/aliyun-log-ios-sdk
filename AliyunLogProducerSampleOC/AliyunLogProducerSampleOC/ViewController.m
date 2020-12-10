//
//  ViewController.m
//  AliyunLogProducerSampleOC
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#import "ViewController.h"
#import "AliyunLogProducer/AliyunLogProducer.h"


@interface ViewController ()

@end

@implementation ViewController

LogProducerClient* client = nil;
// endpoint前需要加 https://
NSString* endpoint = @"https://cn-hangzhou.log.aliyuncs.com";
NSString* project = @"k8s-log-c783b4a12f29b44efa31f655a586bb243";
NSString* logstore = @"666";
NSString* accesskeyid = @"";
NSString* accesskeysecret = @"";

int x = 0;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *Path = [[paths lastObject] stringByAppendingString:@"/log.dat"];
    
    LogProducerConfig* config = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:accesskeyid accessKeySecret:accesskeysecret];
    // 指定sts token 创建config，过期之前调用ResetSecurityToken重置token
//    LogProducerConfig* config = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:accesskeyid accessKeySecret:accesskeysecret securityToken:securityToken];
    [config SetTopic:@"test_topic"];
    [config AddTag:@"test" value:@"test_tag"];
    [config SetPacketLogBytes:1024*1024];
    [config SetPacketLogCount:1024];
    [config SetPacketTimeout:3000];
    [config SetMaxBufferLimit:64*1024*1024];
    [config SetSendThreadCount:1];
    
    [config SetPersistent:1];
    [config SetPersistentFilePath:Path];
    [config SetPersistentForceFlush:1];
    [config SetPersistentMaxFileCount:10];
    [config SetPersistentMaxFileSize:1024*1024];
    [config SetPersistentMaxLogCount:65536];
    
    [config SetConnectTimeoutSec:10];
    [config SetSendTimeoutSec:10];
    [config SetDestroyFlusherWaitSec:1];
    [config SetDestroySenderWaitSec:1];
    [config SetCompressType:1];
    [config SetNtpTimeOffset:1];
    [config SetMaxLogDelayTime:7*24*3600];
    [config SetDropDelayLog:1];

    client = [[LogProducerClient alloc] initWithLogProducerConfig:config callback:on_log_send_done];
}

void on_log_send_done(const char * config_name, log_producer_result result, size_t log_bytes, size_t compressed_bytes, const char * req_id, const char * message, const unsigned char * raw_buffer, void * userparams) {
//    if (result == LOG_PRODUCER_OK) {
//        printf("send success, config : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s \n", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id);
//    } else {
//        printf("send fail   , config : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s \n, error message : %s\n", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id, message);
//    }
}

- (IBAction)send:(id)sender {
//    [self sendOneLog];
    [self sendMulLog:2048];
}

-(void)sendOneLog {
    Log* log = [self getOneLog];
    [log PutContent:@"index" value:[@(x) stringValue]];
    x = x + 1;
    LogProducerResult res = [client AddLog:log];

    NSLog(@"%ld", res);
}

-(void)sendMulLog:(int) num {
    while(true) {
       double time1 = [[NSDate date] timeIntervalSince1970];
       for( int i = 0; i < num; i++) {
           Log* log = [self getOneLog];
           [log PutContent:@"index" value:[@(x) stringValue]];
           x = x + 1;
           LogProducerResult res = [client AddLog:log];
//           NSLog(@"%ld", res);
       }
       double time2 = [[NSDate date] timeIntervalSince1970];
       if(time2-time1<1) {
           [NSThread sleepForTimeInterval:1-(time2-time1)];
       }
    }
}

-(Log*)getOneLog {
    Log* log = [[Log alloc] init];
    [log PutContent:@"content_key_1" value:@"1abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+"];
    [log PutContent:@"content_key_2" value:@"2abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_3" value:@"3abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_4" value:@"4abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_5" value:@"5abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_6" value:@"6abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_7" value:@"7abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_8" value:@"8abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_9" value:@"9abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content" value:@"中文"];
    return log;
}

@end
