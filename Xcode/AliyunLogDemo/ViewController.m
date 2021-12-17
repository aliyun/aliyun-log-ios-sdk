//
//  ViewController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/17.
//

#import "ViewController.h"
#import "DemoUtils.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initLogProducer];
}

void _on_log_send_done(const char * config_name, log_producer_result result, size_t log_bytes, size_t compressed_bytes, const char * req_id, const char * message, const unsigned char * raw_buffer, void * userparams) {
    if (result == LOG_PRODUCER_OK) {
        SLSLogV("send success, config : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s \n", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id);
    } else {
        SLSLogV("send fail   , config : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s \n, error message : %s\n", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id, message);
    }
}

- (void) initLogProducer {
    DemoUtils *utils = [DemoUtils sharedInstance];

    _config = [[LogProducerConfig alloc] initWithEndpoint:[utils endpoint] project:[utils project] logstore:[utils logstore] accessKeyID:[utils accessKeyId] accessKeySecret:[utils accessKeySecret]];
    [_config SetTopic:@"test_topic"];
    [_config AddTag:@"test" value:@"test_tag"];
    [_config SetPacketLogBytes:1024*1024];
    [_config SetPacketLogCount:1024];
    [_config SetPacketTimeout:3000];
    [_config SetMaxBufferLimit:64*1024*1024];
    [_config SetSendThreadCount:1];

    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *Path = [[paths lastObject] stringByAppendingString:@"/log.dat"];

    [_config SetPersistent:1];
    [_config SetPersistentFilePath:Path];
    [_config SetPersistentForceFlush:1];
    [_config SetPersistentMaxFileCount:10];
    [_config SetPersistentMaxFileSize:1024*1024];
    [_config SetPersistentMaxLogCount:65536];
    
    [_config SetConnectTimeoutSec:10];
    [_config SetSendTimeoutSec:10];
    [_config SetDestroyFlusherWaitSec:1];
    [_config SetDestroySenderWaitSec:1];
    [_config SetCompressType:1];
    [_config SetNtpTimeOffset:1];
    [_config SetMaxLogDelayTime:7*24*3600];
    [_config SetDropDelayLog:1];
    [_config SetDropUnauthorizedLog:0];

    _client = [[LogProducerClient alloc] initWithLogProducerConfig:_config callback:_on_log_send_done];
}

- (IBAction)sendLog:(id)sender {
    LogProducerResult result = [_client AddLog:[self oneLog]];
    SLSLogV(@"addlog result: %ld", result);
}

- (IBAction)mockCrash:(id)sender {
    [self performSelector:@selector(die_die)];
}


- (Log *) oneLog {
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
