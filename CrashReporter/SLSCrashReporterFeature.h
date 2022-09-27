//
//  SLSCrashReporterFeature.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#if __has_include("AliyunLogCore/SLSSdkFeature.h")
#import "AliyunLogCore/SLSSdkFeature.h"
#else
#import "SLSSdkFeature.h"
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SLSLogLevel) {
    LOG_VERBOSE = 0,
    LOG_DEBUG = 1,
    LOG_INFO = 2,
    LOG_WARNING = 3,
    LOG_ASSERT = 4,
    LOG_ERROR = 5,
    LOG_EXCEPTION = 6
};


@interface SLSCrashReporterFeature : SLSSdkFeature
- (void) reportError: (NSString *) type level: (SLSLogLevel) level message: (NSString *) message stacktraces: (NSArray<NSString *> *) stacktraces;
@end

NS_ASSUME_NONNULL_END
