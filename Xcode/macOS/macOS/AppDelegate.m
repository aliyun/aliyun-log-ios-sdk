//
//  AppDelegate.m
//  macOS
//
//  Created by gordon on 2022/3/9.
//

#import "AppDelegate.h"
#import "DemoUtils.h"
#import <AliyunLogProducer/AliyunLogProducer.h>
#import <AliyunLogProducer/SLSCocoa.h>
#import "SLSCrashReporter.h"
@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
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
        configuration.enableNetworkDiagnosis = YES;
    }];
    
    [[SLSCocoa sharedInstance] setExtra:@"key_e1" value:@"value_e1"];
    [[SLSCocoa sharedInstance] setExtra:@"key_e2" dictValue:@{
        @"e2_k1": @"e2_va1"
    }];
    
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"NSApplicationCrashOnExceptions": @YES }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
