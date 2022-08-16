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

#import "SLSCocoa.h"
#import "SLSCrashReporter.h"
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
    } else {
        [utils setEndpoint:@""];
        [utils setProject:@""];
        [utils setLogstore:@""];
        [utils setPluginAppId:@""];
        [utils setAccessKeyId:@""];
        [utils setAccessKeySecret:@""];
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
    credentials.accessKeyId = utils.accessKeyId;
    credentials.accessKeySecret = utils.accessKeySecret;
    credentials.instanceId = @"yuanbo-ios";
    
    SLSNetworkDiagnosisCredentials *networkDiagnosisCredentials = [credentials createNetworkDiagnosisCredentials];
    networkDiagnosisCredentials.secretKey = @"eyJhbGl5dW5fdWlkIjoiMTI0NTA0Nzg0OTYwMTY2MCIsImlwYV9hcHBfaWQiOiI5em9FclVNTHB4RjRTSGNKclBNNW5SIiwic2VjX2tleSI6ImZlZjAyZjM0ZTRlMDA0NWU5NDc4Mzg1MjY1MDM2YjhjMWIyOGEzZGJhZTM1N2M5NzA4M2QyOTVlMWE5MjlmZDJhZjk2NThlMDc4ZDFlN2FhN2UxYzE0NmRiMmI1YThkYWFkZWM4ZjRjZDkxMzY2YWY0ZTc5ZjEwOTEyMzBmNjkxIiwic2lnbiI6Ijc4MGFlMzYwMjMzNzA1N2UyY2Q5YTYyMzIwMjE3NDViZGNkNzZkNDAyOWY4YTIyYzA0ZjY2ODIwOGY5NmQ5NTI0Njk5MmI4ZjdlYmE5YTA4NGI0MzJjZDEzMWI5NmRlYmEwMDNhZThjNTc1NDA2Y2VjNGE4ZDBhMWNmNmE1YTBkIn0=";
    networkDiagnosisCredentials.siteId = @"cn";
    [networkDiagnosisCredentials putExtension:@"value" forKey:@"key"];
    networkDiagnosisCredentials.endpoint = @"https://cn-hangzhou.log.aliyuncs.com";
    networkDiagnosisCredentials.project = @"yuanbo-network-diagnosis-test-1";
    networkDiagnosisCredentials.logstore = @"yuanbo-test-1-network-diagnosis";
    networkDiagnosisCredentials.accessKeyId = @"";
    networkDiagnosisCredentials.accessKeySecret = @"";
    
    
    [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
        configuration.enableCrashReporter = YES;
//        configuration.enableNetworkDiagnosis = YES;
    }];
    return YES;
}


@end
