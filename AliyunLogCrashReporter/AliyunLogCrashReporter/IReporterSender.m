//
//  IReporterSender.m
//  AliyunLogCrashReporter
//
//  Created by gordon on 2021/5/19.
//

#import "IReporterSender.h"

@implementation IReporterSender
- (void) initWithSLSConfig: (SLSConfig *)config{
    
}
- (BOOL) sendDada: (TCData *)tcdata{
    NSLog(@"subclass must implement this method");
    return NO;
}
@end
