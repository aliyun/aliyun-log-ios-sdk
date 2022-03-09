//
//  ProducerExampleDestroyController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/22.
//

#import "ProducerExampleDestroyController.h"

@interface ProducerExampleDestroyController ()
@property(nonatomic, strong) UITextView *statusTextView;
@property(nonatomic, strong) LogProducerConfig *config;
@property(nonatomic, strong) LogProducerClient *client;

@end

@implementation ProducerExampleDestroyController

static ProducerExampleDestroyController *selfClzz;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selfClzz = self;
    self.title = @"基础配置";
    [self initViews];
    [self initLogProducer];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLabel:@"参数: " andX:0 andY:0];

    DemoUtils *utils = [DemoUtils sharedInstance];
    NSString *parameters = [NSString stringWithFormat:@"endpoint: %@\nproject: %@\nlogstore:%@\naccessKeyId: %@\naccesskeySecret: %@\n",
                            utils.endpoint,
                            utils.project,
                            utils.logstore,
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
    
    [self createButton:@"Destroy" andAction:@selector(destroy) andX:((SLScreenW - SLPadding * 2) / 4 - SLCellWidth / 2) andY:SLCellHeight * 11];
    [self createButton:@"Send" andAction:@selector(send) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - SLCellWidth / 2) andY:SLCellHeight * 11];
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
}

- (void) destroy {
    [_client DestroyLogProducer];
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
    [_client setEnableTrack:YES];
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
