//
//  NetworkDiagnosisController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/27.
//

#import "NetworkDiagnosisController.h"
#import "SLSNetworkDiagnosisPlugin.h"
#import "SLSNetworkDiagnosis.h"
#import "NetworkDiagnosisPolicyController.h"

@interface NetworkDiagnosisController ()
@property(nonatomic, strong) UITextView *statusTextView;
@property (strong,nonatomic)NSTimer *timer;
@property (strong, nonatomic) NSMutableArray<NSString*> *endpoints;
@end

@implementation NetworkDiagnosisController

static NetworkDiagnosisController *selfClzz;

- (instancetype)init {
    self = [super init];
    if (self) {
        _endpoints = [[NSMutableArray alloc] init];
        [_endpoints addObject:@"cn-hangzhou.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-hangzhou-finance.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shanghai.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shanghai-finance-1.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-qingdao.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-beijing.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-north-2-gov-1.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-zhangjiakou.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-huhehaote.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-wulanchabu.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shenzhen.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shenzhen-finance.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-heyuan.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-guangzhou.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-chengdu.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-hongkong.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-northeast-1.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-1.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-2.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-3.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-6.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-5.log.aliyuncs.com"];
        [_endpoints addObject:@"me-east-1.log.aliyuncs.com"];
        [_endpoints addObject:@"us-west-1.log.aliyuncs.com"];
        [_endpoints addObject:@"eu-central-1.log.aliyuncs.com"];
        [_endpoints addObject:@"us-east-1.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-south-1.log.aliyuncs.com"];
        [_endpoints addObject:@"eu-west-1.log.aliyuncs.com"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selfClzz = self;
    self.title = @"网络监控";
    [self initViews];
    [self initNetworkDiagnosis];
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
    
    CGFloat lx = ((SLScreenW - SLPadding * 2) / 4 - SLCellWidth / 2);
    CGFloat rx = ((SLScreenW - SLPadding * 2) / 4 * 3 - SLCellWidth / 2);

    [self createButton:@"PING" andAction:@selector(ping) andX:lx andY:SLCellHeight * 11];
    [self createButton:@"TCPPING" andAction:@selector(tcpPing) andX:rx andY:SLCellHeight * 11];
    
    [self createButton:@"HTTPPING" andAction:@selector(httpPing) andX:lx andY:SLCellHeight * 12 + SLPadding];
    [self createButton:@"MTR" andAction:@selector(mtr) andX:rx andY:SLCellHeight * 12 + SLPadding];
    
    [self createButton:@"AUTO" andAction:@selector(ato) andX:lx andY:SLCellHeight * 13 + SLPadding * 2 andWidth:SLScreenW - (lx * 2 + SLPadding * 2) andHeight:SLCellHeight];

    [self createButton:@"动态更新配置" andAction:@selector(updateConfig) andX:lx andY:SLCellHeight * 14 + SLPadding * 3 andWidth:SLScreenW - (lx * 2 + SLPadding * 2) andHeight:SLCellHeight];

    [self createButton:@"配置探测策略" andAction:@selector(navToPolicy) andX:lx andY:SLCellHeight * 15 + SLPadding * 4 andWidth:SLScreenW - (lx * 2 + SLPadding * 2) andHeight:SLCellHeight];
}

- (void) updateStatus: (NSString *)append {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status = [NSString stringWithFormat:@"%@\n> %@", self.statusTextView.text, append];
        [self.statusTextView setText:status];
        [self.statusTextView scrollRangeToVisible:NSMakeRange(self->_statusTextView.text.length, 1)];
    });
}

- (void) ping {
    [self updateStatus:@"start ping..."];
    [[SLSNetworkDiagnosis sharedInstance] ping:@"www.aliyun.com" callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        [self updateStatus:[NSString stringWithFormat:@"ping result, success: %d, data: %@", result.success, result.data]];
    }];
}

- (void) tcpPing {
    [self updateStatus:@"start tcpPing..."];
    [[SLSNetworkDiagnosis sharedInstance] tcpPing:@"www.aliyun.com" port:80 callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        [self updateStatus:[NSString stringWithFormat:@"tcpPing result, success: %d, data: %@", result.success, result.data]];
    }];
}

- (void) httpPing {
    [self updateStatus:@"start httpPing..."];
    [[SLSNetworkDiagnosis sharedInstance] httpPing:@"https://www.aliyun.com" callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        [self updateStatus:[NSString stringWithFormat:@"httpPing result, success: %d, data: %@", result.success, result.data]];
    }];
}

- (void) mtr {
    [self updateStatus:@"start mtr..."];
    [[SLSNetworkDiagnosis sharedInstance] mtr:@"www.aliyun.com" callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        [self updateStatus:[NSString stringWithFormat:@"mtr result, success: %d, data: %@", result.success, result.data]];
    }];
}

- (void) navToPolicy {
    [self.navigationController pushViewController:[[NetworkDiagnosisPolicyController alloc]init] animated:YES];
}

- (void) ato {
    [self updateStatus:@"start mtr..."];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(atoMethods) userInfo:nil repeats:YES];
}

- (void) atoMethods {
    [self ping];
    [self tcpPing];
    [self httpPing];
    [self mtr];
}

- (void) updateConfig {
    SLSAdapter *adapter = [SLSAdapter sharedInstance];
    SLSConfig *config = [[SLSConfig alloc] init];
    [config setUserId:@"test_userid_updated"];
    [config setUserNick:@"test_usernick_updated"];
    [config setLongLoginNick:@"test_long_usernick_updated"];
    [config addCustomWithKey:@"updated_key" andValue:@"updated_value"];
    [adapter updateConfig:config];
}

- (void) initNetworkDiagnosis {
    DemoUtils *utils = [DemoUtils sharedInstance];
    SLSConfig *config = [[SLSConfig alloc] init];
    // 正式发布时建议关闭
    [config setDebuggable:YES];
    
    [config setEndpoint: [utils endpoint]];
    [config setAccessKeyId: [utils accessKeyId]];
    [config setAccessKeySecret: [utils accessKeySecret]];
    [config setPluginAppId: [utils pluginAppId]];
    [config setPluginLogproject: [utils project]];
    
    [config setUserId:@"test_userid"];
    [config setUserNick:@"user_nick"];
    [config setChannel:@"test_channel"];
    [config setLongLoginNick:@"test_long_nick"];
    [config addCustomWithKey:@"customKey" andValue:@"testValue"];
    
    [config setSiteId:@"cn"];
    
    SLSAdapter *slsAdapter = [SLSAdapter sharedInstance];
//    [slsAdapter addPlugin:[[SLSCrashReporterPlugin alloc]init]];
    [slsAdapter addPlugin:[[SLSNetworkDiagnosisPlugin alloc] init]];
    [slsAdapter initWithSLSConfig:config];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
}

@end
