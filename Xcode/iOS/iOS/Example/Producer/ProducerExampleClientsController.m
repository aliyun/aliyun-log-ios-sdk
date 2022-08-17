//
//  ProducerExampleClientsController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/21.
//

#import "ProducerExampleClientsController.h"

@interface ProducerExampleClientsController ()

@property(nonatomic, strong) UITextView *statusTextView;
@property(nonatomic, strong) LogProducerConfig *config;
@property(nonatomic, strong) LogProducerClient *client;

@property(nonatomic, strong) LogProducerConfig *config2;
@property(nonatomic, strong) LogProducerClient *client2;

@end

@implementation ProducerExampleClientsController

static ProducerExampleClientsController *selfClzz;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selfClzz = self;
    self.title = @"多个实例";
    [self initViews];
    [self initLogProducer];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLabel:@"参数: " andX:0 andY:0];

    DemoUtils *utils = [DemoUtils sharedInstance];
    NSString *parameters = [NSString stringWithFormat:@"endpoint: %@\nproject: %@\nlogstore: %@\nlogstore2: %@\naccessKeyId: %@\naccesskeySecret: %@\n",
                            utils.endpoint,
                            utils.project,
                            utils.logstore,
                            @"test2",
                            utils.accessKeyId,
                            utils.accessKeySecret];
    
    UILabel *label = [self createLabel:parameters andX:0 andY:SLCellHeight andWidth:SLScreenW - SLPadding * 2 andHeight:SLCellHeight * 5];
    label.numberOfLines = 0;
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentLeft;
    
    [self createLabel:@"状态: " andX:0 andY:SLCellHeight * 5];
    
    self.statusTextView = [self createTextView:@"" andX:0 andY:SLCellHeight * 6 andWidth:(SLScreenW - SLPadding * 2) andHeight:(SLCellHeight * 4)];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    self.statusTextView.layoutManager.allowsNonContiguousLayout = NO;
    [self.statusTextView setEditable:NO];
    [self.statusTextView setContentOffset:CGPointMake(0, 0)];
    
    [self createButton:@"Send" andAction:@selector(send) andX:((SLScreenW - SLPadding * 2 - SLCellWidth) / 2) andY:SLCellHeight * 11];
}

- (void) updateStatus: (NSString *)append {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status = [NSString stringWithFormat:@"%@\n> %@", self.statusTextView.text, append];
        [self.statusTextView setText:status];
        [self.statusTextView scrollRangeToVisible:NSMakeRange(self->_statusTextView.text.length, 1)];
    });
}

- (void) send {
    LogProducerResult result = [_client AddLog:[self oneLog]];
    SLSLogV(@"addlog result: %ld", result);
    [self updateStatus:[NSString stringWithFormat:@"addlog result: %ld", result]];
    
    result = [_client2 AddLog:[self oneLog]];
    SLSLogV(@"addlog result: %ld", result);
    [self updateStatus:[NSString stringWithFormat:@"addlog result2: %ld", result]];
}

static void _on_log_send_done(const char * config_name, log_producer_result result, size_t log_bytes, size_t compressed_bytes, const char * req_id, const char * message, const unsigned char * raw_buffer, void * userparams) {
    if (result == LOG_PRODUCER_OK) {
        NSString *success = [NSString stringWithFormat:@"send success, config : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id];
        SLSLogV("%@", success);
        
        [selfClzz updateStatus:success];
    } else {
        NSString *fail = [NSString stringWithFormat:@"send fail   , config : %s, result : %d, log bytes : %d, compressed bytes : %d, request id : %s, error message : %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id, message];
        SLSLogV("%@", fail);
        
        [selfClzz updateStatus:fail];
    }
}

- (void) initLogProducer {
    DemoUtils *utils = [DemoUtils sharedInstance];

    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // 需要保证目录已经存在
    NSString *path = [[paths lastObject] stringByAppendingString:@"/log_test.dat"];
    NSString *path2 = [[paths lastObject] stringByAppendingString:@"/log_test2.dat"];

    
    _config = [self createLogProducerConfig:path andLogstore:[utils logstore]];
    _client = [[LogProducerClient alloc] initWithLogProducerConfig:_config callback:_on_log_send_done];
    
    _config2 = [self createLogProducerConfig:path2 andLogstore:@"test2"];
    _client2 = [[LogProducerClient alloc] initWithLogProducerConfig:_config2 callback:_on_log_send_done];
    
}

- (LogProducerConfig *) createLogProducerConfig: (NSString *) path andLogstore: (NSString *)logstore {
    DemoUtils *utils = [DemoUtils sharedInstance];
    LogProducerConfig *config = [[LogProducerConfig alloc] initWithEndpoint:[utils endpoint] project:[utils project] logstore:logstore accessKeyID:[utils accessKeyId] accessKeySecret:[utils accessKeySecret]];
    [config SetTopic:@"test_topic"];
    [config AddTag:@"test" value:@"test_tag"];
    [config SetPacketLogBytes:1024*1024];
    [config SetPacketLogCount:1024];
    [config SetPacketTimeout:3000];
    [config SetMaxBufferLimit:64*1024*1024];
    [config SetSendThreadCount:1];


    [config SetPersistent:1];
    // 不同的 LogProducerClient 实例必须要配置不同的 path，否则数据必串
    [config SetPersistentFilePath:path];
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
    [config SetDropUnauthorizedLog:0];

    return config;
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
