//
//  AppDelegate.m
//  tvOS
//
//  Created by gordon on 2022/3/14.
//

#import "AppDelegate.h"
#import "DemoUtils.h"
#import <AliyunLogProducer/AliyunLogProducer.h>

#import "SLSCocoa.h"
#import "SLSCrashReporter.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
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
    
    [[SLSCocoa sharedInstance] setExtra:@"key_e1" value:@"value_e1"];
    [[SLSCocoa sharedInstance] setExtra:@"key_e2" dictValue:@{
        @"e2_k1": @"e2_va1"
    }];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


@end
