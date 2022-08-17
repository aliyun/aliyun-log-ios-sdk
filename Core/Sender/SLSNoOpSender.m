//
//  SLSNoOpSender.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSNoOpSender.h"

@implementation SLSNoOpSender

- (void) initialize: (SLSCredentials *) credentials {
    
}
- (BOOL) send: (Log *) log {
    return NO;
}
- (void) setCredentials: (SLSCredentials *) credentials {
    
}

@end
