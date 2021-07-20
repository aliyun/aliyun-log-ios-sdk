//
//  SLSCrashReporterPlugin.h
//  AliyunLogCrashReporter
//
//  Created by gordon on 2021/5/19.
//

#import <AliyunLogCommon/AliyunLogCommon.h>
#import "AliyunLogProducer/AliyunLogProducer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSCrashReporterPlugin : IPlugin

@property(nonatomic, strong) SLSConfig *config;

- (void) updateConfig:(SLSConfig *)config;

@end

NS_ASSUME_NONNULL_END
