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
- (void) initialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    
}
- (BOOL) isInitialize {
    return NO;
}
- (void) stop {
    
}
- (void) setCredentials: (SLSCredentials *) credentials {
    
}
- (void) addCustom: (NSString *) eventId properties: (NSDictionary<NSString *, NSString *> *) proterties {
    
}

@end
