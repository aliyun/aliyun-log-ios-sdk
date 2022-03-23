//
//  NetworkDiagnosisPolicyController.m
//  iOS
//
//  Created by gordon on 2022/3/22.
//

#import "NetworkDiagnosisPolicyController.h"
#import "SLSNetworkDiagnosisPlugin.h"
#import "SLSNetworkDiagnosis.h"

@interface NetworkDiagnosisPolicyController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *rootView;
@property(nonatomic, strong) UITextView *statusTextView;
@property (strong,nonatomic)NSTimer *timer;
@property (nonatomic, assign) CGFloat lx;
@property (strong, nonatomic) NSMutableArray<NSString*> *endpoints;

@property (nonatomic, strong) UITextField *enableField;
@property (nonatomic, strong) UITextField *typeField;
@property (nonatomic, strong) UITextField *versionField;
@property (nonatomic, strong) UITextField *periodicityField;
@property (nonatomic, strong) UITextField *intervalField;
@property (nonatomic, strong) UITextField *expirationField;
@property (nonatomic, strong) UITextField *ratioField;
@property (nonatomic, strong) UITextField *whitelistField;
@property (nonatomic, strong) UITextField *methodsField;
@property (nonatomic, strong) UITextField *ipsField;
@property (nonatomic, strong) UITextField *urlsField;
@end

@implementation NetworkDiagnosisPolicyController

static NetworkDiagnosisPolicyController *selfClzz;

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
    _lx = ((SLScreenW - SLPadding * 2) / 4 - SLCellWidth / 2);
    
    [self initViews];
    [self initNetworkDiagnosis];
}

- (UITextField *) createCol: (NSString *) labelName hit: (NSString *) hit andY: (CGFloat)y andKeyBoard: (UIKeyboardType) keyboard{
    UIView *v = [self createLabel:labelName andX:0 andY:y];
    [v removeFromSuperview];
    [_rootView addSubview:v];
    
    UITextField *field =  [self createTextField:hit andX:SLCellWidth andY:y andWidth:SLScreenW - SLCellWidth - _lx andHeight:SLCellHeight andKeyBoard:keyboard];
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    [field removeFromSuperview];
    [_rootView addSubview:field];
    return field;
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _rootView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
//    [_rootView setContentMode:UIViewContentModeScaleToFill];
    
    [_scrollView addSubview:_rootView];
    [self.view addSubview:_scrollView];
    
    
    UIView *v = [self createLabel:@"参数: " andX:0 andY:0];
    [v removeFromSuperview];
    [_rootView addSubview:v];

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
    [label removeFromSuperview];
    [_rootView addSubview:label];
    
    v = [self createLabel:@"状态: " andX:0 andY:SLCellHeight * 5];
    [v removeFromSuperview];
    [_rootView addSubview:v];
    
    self.statusTextView = [self createTextView:@"" andX:0 andY:SLCellHeight * 6 andWidth:(SLScreenW - SLPadding * 2) andHeight:(SLCellHeight * 4)];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    self.statusTextView.layoutManager.allowsNonContiguousLayout = NO;
    [self.statusTextView setEditable:NO];
    [self.statusTextView setContentOffset:CGPointMake(0, 0)];
    [_statusTextView removeFromSuperview];
    [_rootView addSubview:_statusTextView];
    
    _enableField = [self createCol:@"enable:" hit:@"策略开启或关闭，true/false" andY:SLCellHeight * 11 andKeyBoard:UIKeyboardTypeAlphabet];
    _typeField = [self createCol:@"type:" hit:@"业务类型，可不填" andY:SLCellHeight * 12 + SLPadding andKeyBoard:UIKeyboardTypeDefault];
    _versionField = [self createCol:@"version:" hit:@"业务类型，可不填" andY:SLCellHeight * 13 + SLPadding * 2 andKeyBoard:UIKeyboardTypeNumberPad];
    _periodicityField = [self createCol:@"periodicity:" hit:@"是否为周期性探测策略。true为是" andY:SLCellHeight * 14 + SLPadding * 3 andKeyBoard:UIKeyboardTypeAlphabet];
    _intervalField = [self createCol:@"interval:" hit:@"探测间隔，单位秒。如：600" andY:SLCellHeight * 15 + SLPadding * 4 andKeyBoard:UIKeyboardTypeNumberPad];
    _expirationField = [self createCol:@"expiration:" hit:@"策略有效期，单位秒。如：1735660800" andY:SLCellHeight * 16 + SLPadding * 5 andKeyBoard:UIKeyboardTypeNumberPad];
    _ratioField = [self createCol:@"ratio:" hit:@"灰度比例，千分制。如：10，表示千分之10" andY:SLCellHeight * 17 + SLPadding * 6 andKeyBoard:UIKeyboardTypeNumberPad];
    _whitelistField = [self createCol:@"whitelist:" hit:@"白名单，','分隔。如：NDBiZTA5MDhkNTU1NGQzZQ==" andY:SLCellHeight * 18 + SLPadding * 7 andKeyBoard:UIKeyboardTypeAlphabet];
    _methodsField = [self createCol:@"methods:" hit:@"启用的探测方式。仅支持mtr,ping,http。支持同时启用多个，','分隔。" andY:SLCellHeight * 19 + SLPadding * 8 andKeyBoard:UIKeyboardTypeAlphabet];
    _ipsField = [self createCol:@"ips:" hit:@"目标ip。支持多个，','分隔。也可以填域名" andY:SLCellHeight * 20 + SLPadding * 9 andKeyBoard:UIKeyboardTypeURL];
    _urlsField = [self createCol:@"urls:" hit:@"目标url。支持多个，','分隔。仅http探测生效。" andY:SLCellHeight * 21 + SLPadding * 10 andKeyBoard:UIKeyboardTypeURL];
    
    v = [self createButton:@"配置" andAction:@selector(setup) andX:_lx andY:SLCellHeight * 22 + SLPadding * 11 andWidth:SLScreenW - (_lx * 2 + SLPadding * 2) andHeight:SLCellHeight];
    [v removeFromSuperview];
    [_rootView addSubview:v];
    
    
    CGRect frame = CGRectMake(0, 0, SLScreenW, SLCellHeight * 23 + SLPadding * 11 + SLNavBarAndStatusBarHeight + SLPadding * 2 + SLCellHeight);
    _rootView.frame = frame;
    _scrollView.contentSize = frame.size;
}

- (void) setup {
    [[SLSNetworkDiagnosis sharedInstance] registerCallback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        [self updateStatus:[NSString stringWithFormat:@"policy exec result, success: %d, data: %@", result.success, result.data]];
    }];

    SLSNetPolicyBuilder *builder = [[SLSNetPolicyBuilder alloc] init];
    if (_enableField.text) {
        [builder setEnable:[self getBoolFromField:_enableField.text def:YES]];
    }
    if (_typeField.text) {
        [builder setType:_typeField.text];
    }
    if (_versionField.text) {
        [builder setVersion:[self getIntFromField:_versionField.text def:1]];
    }
    if (_periodicityField.text) {
        [builder setPeriodicity:[self getBoolFromField:_periodicityField.text def:YES]];
    }
    if (_intervalField.text) {
        [builder setInternal:[self getIntFromField:_intervalField.text def:30]];
    }
    if (_expirationField.text) {
        [builder setExpiration:[self getLongFromField:_expirationField.text def:[[NSDate date] timeIntervalSince1970] + 5 * 60]];
    }
    if (_ratioField.text) {
        [builder setRatio:[self getIntFromField:_ratioField.text def:1000]];
    }
    if (![_whitelistField.text isEqualToString:@""]) {
        [builder setWhiteList:[_whitelistField.text componentsSeparatedByString:@","]];
    }
    if (![_methodsField.text isEqualToString:@""]) {
        [builder setMethods:[_methodsField.text componentsSeparatedByString:@","]];
    } else {
        [builder setMethods:[@"mtr,ping,tcpping,http" componentsSeparatedByString:@","]];
//        [builder setEnableMtrMethod];
//        [builder setEnableTcpPingMethod];
//        [builder setEnablePingMethod];
//        [builder setEnableHttpMethod];
    }
    
    if (![_ipsField.text isEqualToString:@""]) {
        [builder addDestination:[_ipsField.text componentsSeparatedByString:@","] urls:[_urlsField.text componentsSeparatedByString:@","]];
    } else {
        [builder addDestination:_endpoints urls:_endpoints];
    }
    
    [[SLSNetworkDiagnosis sharedInstance] registerPolicyWithBuilder:builder];
}

- (void) updateStatus: (NSString *)append {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status = [NSString stringWithFormat:@"%@\n> %@", self.statusTextView.text, append];
        [self.statusTextView setText:status];
        [self.statusTextView scrollRangeToVisible:NSMakeRange(self->_statusTextView.text.length, 1)];
    });
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

- (BOOL) getBoolFromField: (NSString*)field def: (BOOL) def {
    if (!field || [field isEqualToString:@""]) {
        return def;
    }
    
    return [field isEqualToString:@"true"] ? YES : NO;
}


- (int) getIntFromField: (NSString*)field def: (int) def {
    if (!field || [field isEqualToString:@""]) {
        return def;
    }

    return field.intValue;
}

- (long) getLongFromField: (NSString*) field def: (long) def {
    if (!field || [field isEqualToString:@""]) {
        return def;
    }
    return field.longLongValue;
}
@end
