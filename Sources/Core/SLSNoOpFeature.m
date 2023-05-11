//
//  SLSNoOpFeature.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSNoOpFeature.h"

@implementation SLSNoOpFeature

- (NSString *) name {
    return @"";
}
- (NSString *) version {
    return @"";
}

- (void)preInit:(SLSCredentials *)credentials configuration:(SLSConfiguration *)configuration {
    
}

- (void) initialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    
}
- (BOOL) isInitialize {
    return NO;
}
- (void) stop {
    
}
- (void) setCredentials: (SLSCredentials *) credentials {
    
}
- (void)setCallback:(nullable CredentialsCallback) callback {
    
}
- (void) setFeatureEnabled: (BOOL) enable {
    
}
- (BOOL) isFeatureEnabled {
    return YES;
}

@end
