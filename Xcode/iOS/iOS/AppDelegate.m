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
    
    [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
        configuration.enableCrashReporter = YES;
    }];
    return YES;
}


@end
