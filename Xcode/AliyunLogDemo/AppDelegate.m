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
    
    SLSConfig *config = [[SLSConfig alloc] init];
    [config setDebuggable:YES];
    
    [config setEndpoint: [utils endpoint]];
    [config setAccessKeyId: [utils accessKeyId]];
    [config setAccessKeySecret: [utils accessKeySecret]];
    [config setPluginAppId: [utils pluginAppId]];
    [config setPluginLogproject: [utils project]];
    
    [config setUserId:@"test_userid"];
    [config setChannel:@"test_channel"];
    [config addCustomWithKey:@"customKey" andValue:@"testValue"];
    
    SLSAdapter *slsAdapter = [SLSAdapter sharedInstance];
    [slsAdapter addPlugin:[[SLSCrashReporterPlugin alloc]init]];
//    [slsAdapter addPlugin:[[SLSTracePlugin alloc] init]];
    [slsAdapter initWithSLSConfig:config];
    return YES;
}


@end
