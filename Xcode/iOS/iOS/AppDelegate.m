//
//  AppDelegate.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/17.
//

#import "AppDelegate.h"
#import "DemoUtils.h"
#import "MainViewController.h"

#import <AliyunLogProducer/AliyunLogProducer.h>


@interface SpanProvider : NSObject<SLSSpanProviderProtocol>
+ (instancetype) provider;
@end

@implementation SpanProvider
+ (instancetype) provider {
    return [[SpanProvider alloc] init];
}

- (nonnull NSArray<SLSAttribute *> *)provideAttribute {
    NSMutableArray<SLSAttribute *> *array = [NSMutableArray array];
    [array addObject:[SLSAttribute of:@"attr_key11111" value:@"attr_value"]];
    return array;
}

- (nonnull SLSResource *)provideResource {
    return [SLSResource of:@"res_key111111" value:@"res_value"];
}
@end

@interface NSURLInstrumentation : NSObject<SLSURLSessionInstrumentationDelegate>

@end

@implementation NSURLInstrumentation

- (BOOL) shouldInstrument: (NSURLRequest *) request {
    NSString *host = request.URL.host;
    return ![host containsString:@"er.ns.aliyuncs.com"] &&
           ![host containsString:@"www.aliyun.com"] &&
           ![host containsString:@"applog.uc.cn"] &&
           ![host containsString:@"woodpecker.uc.cn"];
}
- (NSDictionary<NSString *, NSString *> *) injectCustomeHeaders {
    return @{};
}

@end

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    MainViewController *viewController = [[MainViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController.navigationBar setBarTintColor:[UIColor blueColor]];
    navigationController.view.tintColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];


    DemoUtils *utils = [DemoUtils sharedInstance];
    
    NSDictionary<NSString*, NSString*> *environment = [[NSProcessInfo processInfo] environment];
    if ([environment valueForKey:@"PCONFIG_ENABLE"]) {
        [utils setEndpoint:[environment valueForKey:@"PEND_POINT"]];
        [utils setProject:[environment valueForKey:@"PLOG_PROJECT"]];
        [utils setLogstore:[environment valueForKey:@"PLOG_STORE"]];
        [utils setPluginAppId:[environment valueForKey:@"PPLUGIN_APPID"]];
        [utils setAccessKeyId:[environment valueForKey:@"PACCESS_KEYID"]];
        [utils setAccessKeySecret:[environment valueForKey:@"PACCESS_KEY_SECRET"]];
        [utils setSecKey:[environment valueForKey:@"PNETWORK_SECKEY"]];
    } else {
        [utils setEndpoint:@""];
        [utils setProject:@""];
        [utils setLogstore:@""];
        [utils setPluginAppId:@""];
        [utils setAccessKeyId:@""];
        [utils setAccessKeySecret:@""];
        [utils setSecKey:@""];
    }
    
    SLSLogV(@"endpoint: %@", [utils endpoint]);
    SLSLogV(@"project: %@", [utils project]);
    SLSLogV(@"logstore: %@", [utils logstore]);
    SLSLogV(@"pluginAppId: %@", [utils pluginAppId]);
    SLSLogV(@"accessKeyId: %@", [utils accessKeyId]);
    SLSLogV(@"accessKeySecret: %@", [utils accessKeySecret]);
    
    SLSCredentials *credentials = [SLSCredentials credentials];
    credentials.endpoint = @"https://cn-hangzhou.log.aliyuncs.com";
    credentials.project = @"yuanbo-test-1";
//    credentials.accessKeyId = utils.accessKeyId;
//    credentials.accessKeySecret = utils.accessKeySecret;
    credentials.instanceId = @"ios-dev-ea64";
    
    // 网络质量分析
    SLSNetworkDiagnosisCredentials *networkDiagnosisCredentials = [credentials createNetworkDiagnosisCredentials];
    networkDiagnosisCredentials.secretKey = [utils secKey];
    networkDiagnosisCredentials.siteId = @"cn";
    [networkDiagnosisCredentials putExtension:@"value" forKey:@"key"];
    networkDiagnosisCredentials.endpoint = @"https://cn-hangzhou.log.aliyuncs.com";
    networkDiagnosisCredentials.project = @"zaiyun-test5";

    // Trace
    SLSTraceCredentials *tracerCredentials = [credentials createTraceCredentials];
    tracerCredentials.instanceId = @"sls-mall";
    tracerCredentials.endpoint = @"https://cn-beijing.log.aliyuncs.com";
    tracerCredentials.project = @"qs-demos";
    
    [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
        configuration.spanProvider = [SpanProvider provider];
        configuration.debuggable = YES;
//        configuration.enableCrashReporter = YES;
//        configuration.enableBlockDetection = YES;
        configuration.enableNetworkDiagnosis = YES;
        configuration.enableTrace = YES;
        configuration.enableInstrumentNSURLSession = YES;
    }];
    
    [[SLSCocoa sharedInstance] setExtra:@"key_e1" value:@"value_e1"];
    [[SLSCocoa sharedInstance] setExtra:@"key_e2" dictValue:@{
        @"e2_k1": @"e2_va1"
    }];
    [[SLSCocoa sharedInstance] registerCredentialsCallback:^(NSString * _Nonnull feature, NSString * result) {
        SLSLog(@"creditials callback called: feature=%@, result: %@", feature, result);
        if ([@"LogProducerSendUnauthorized" isEqualToString:result] || [@"LogProducerParametersInvalid" isEqualToString:result]) {
            // 处理token过期，AK失效等鉴权类型问题
            // 获取到新的token后，调用如下代码更新token
            // SLSCredentials *credentials = [SLSCredentials credentials];
            // credentials.accessKeyId = @"";
            // credentials.accessKeySecret = @"";
            // credentials.securityToken = @""; // 可选，sts 方式获取的token必须要填
            // [[SLSCocoa sharedInstance] setCredentials:credentials];
            
             SLSCredentials *credentials = [SLSCredentials credentials];
             credentials.accessKeyId = [utils accessKeyId];
             credentials.accessKeySecret = [utils accessKeySecret];
             [[SLSCocoa sharedInstance] setCredentials:credentials];
        }
    }];

    // 更新AK和token
//    SLSCredentials *credentials = [SLSCredentials credentials];
//    credentials.accessKeyId = @"";
//    credentials.accessKeySecret = @"";
//    credentials.securityToken = @""; // 可选，sts 方式获取的token必须要填
//    [[SLSCocoa sharedInstance] setCredentials:credentials];
    
    // 配置用户信息
    SLSUserInfo *userinfo = [SLSUserInfo userInfo];
    // 用户uid
    userinfo.uid = @"test";
    // 用户渠道
    userinfo.channel = @"pub";
    // 扩展信息
    [userinfo addExt:@"ext_value" key:@"ext_key"];
    // 更新用户信息
    [[SLSCocoa sharedInstance] setUserInfo:userinfo];
    [SLSTracer registerURLSessionInstrumentationDelegate:[[NSURLInstrumentation alloc]init]];
    
    // logstore 中对应的字段
    // uid: attribute.user.uid
    // channel: attribute.user.uid
    // 扩展信息: attribute.user.xxx
    
    return YES;
}


@end
