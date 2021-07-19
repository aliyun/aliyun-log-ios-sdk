//
//  IPlugin.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/19.
//

#import "IPlugin.h"

@implementation IPlugin
- (NSString *)name {
    return @"IPlugin";
}
- (BOOL) initWithSLSConfig: (SLSConfig *) config {
    NSLog(@"plugin: %@ initWithSLSConfig", self.name);
    return YES;
}
- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    
}

- (void) updateConfig:(SLSConfig *)config {
    
}
@end
