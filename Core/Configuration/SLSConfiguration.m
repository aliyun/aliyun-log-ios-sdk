//
//  SLSConfiguration.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSConfiguration.h"

@implementation SLSConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enableCrashReporter = NO;
        _enableBlockDetection = NO;
        _enableNetworkDiagnosis = NO;
        _debuggable = NO;
    }
    return self;
}

- (instancetype) initWithProcessor: (id<SLSSpanProcessorProtocol>) processor {
    self = [self init];
    if (self) {
        _spanProcessor = processor;
    }

    return self;
}

@end
