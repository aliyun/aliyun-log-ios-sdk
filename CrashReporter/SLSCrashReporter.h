//
//  SLSCrashReporter.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSCrashReporterFeature.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSCrashReporter : NSObject

+ (instancetype) sharedInstance;
- (void) setCrashReporterFeature: (SLSCrashReporterFeature *) feature;
- (void) setEnabled: (BOOL) enable;

- (void) reportException: (nonnull NSException *)exception;
- (void) reportError: (nonnull NSString *)type exception: (nonnull NSException *)exception;
- (void) reportError: (nonnull NSString *)type level: (SLSLogLevel) level exception: (nonnull NSException *)exception;

- (void) reportError: (nonnull NSArray<NSString *> *)stacktraces;
- (void) reportError: (nonnull NSString *)type stacktrace:(nonnull NSString *)stacktrace;
- (void) reportError: (nonnull NSString *)type stacktraces:(nonnull NSArray<NSString *> *)stacktraces;
- (void) reportError: (nonnull NSString *)type message:(nonnull NSString *)message stacktrace:(nonnull NSString *)stacktrace;
- (void) reportError: (nonnull NSString *)type message:(nonnull NSString *)message stacktraces:(nonnull NSArray<NSString *> *)stacktraces;
- (void) reportError: (nonnull NSString *)type level: (SLSLogLevel)level message: (nonnull NSString *)message stacktrace: (nonnull NSString *)stacktrace;
- (void) reportError: (nonnull NSString *)type level: (SLSLogLevel)level message: (nonnull NSString *)message stacktraces: (nonnull NSArray<NSString *> *)stacktraces;

@end

NS_ASSUME_NONNULL_END
