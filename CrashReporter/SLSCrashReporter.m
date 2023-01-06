//
//  SLSCrashReporter.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSCrashReporter.h"

@interface SLSCrashReporter ()
@property(nonatomic, strong) SLSCrashReporterFeature *feature;

@end

@implementation SLSCrashReporter
+ (instancetype) sharedInstance {
    static SLSCrashReporter * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SLSCrashReporter alloc] init];
    });
    return ins;
}

- (void) setCrashReporterFeature: (SLSCrashReporterFeature *) feature {
    _feature = feature;
}

- (void) setEnabled: (BOOL) enable {
    if (!_feature) {
        return;
    }
    
    [_feature setFeatureEnabled:enable];
}

- (void) reportCustomLog: (nonnull NSString *)log type: (nonnull NSString *)type {
    if (!_feature) {
        return;
    }
    
    [_feature reportCustomLog:log type:type];
}


- (void) reportError: (nonnull NSArray<NSString *> *)stacktraces {
    [self reportError:@"exception" stacktraces: stacktraces];
}

- (void) reportError: (nonnull NSString *) type stacktrace:(nonnull NSString *)stacktrace {
    [self reportError:type message:@"" stacktrace:stacktrace];
}

- (void) reportError: (nonnull NSString *) type stacktraces:(nonnull NSArray<NSString *> *)stacktraces {
    [self reportError:type message:@"" stacktraces:stacktraces];
}

- (void) reportError: (nonnull NSString *) type message:(nonnull NSString *)message stacktrace:(nonnull NSString *)stacktrace {
    [self reportError:type level:LOG_ERROR message:message stacktrace:stacktrace];
}

- (void) reportError: (nonnull NSString *) type message:(nonnull NSString *)message stacktraces:(nonnull NSArray<NSString *> *)stacktraces {
    [self reportError:type level:LOG_ERROR message:message stacktraces:stacktraces];
}

- (void) reportError: (nonnull NSString *) type level: (SLSLogLevel) level message: (nonnull NSString *) message stacktrace: (nonnull NSString *) stacktrace {
    NSArray *stacktraces = @[stacktrace];
    [self reportError:type level:level message:message stacktraces:stacktraces];
}

- (void) reportError: (nonnull NSString *) type level: (SLSLogLevel) level message: (nonnull NSString *) message stacktraces: (nonnull NSArray<NSString *> *) stacktraces {
    if (!_feature) {
        return;
    }
    
    [_feature reportError:type level:level message:message stacktraces:stacktraces];
}

- (void) reportException: (nonnull NSException *)exception {
    [self reportError:@"exception" exception:exception];
}
- (void) reportError: (nonnull NSString *) type exception: (nonnull NSException *)exception {
    [self reportError:type level:LOG_ERROR exception:exception];
}

- (void) reportError: (nonnull NSString *) type level: (SLSLogLevel) level exception: (nonnull NSException *)exception {
    [_feature reportError:type level:level message:exception.reason stacktraces:exception.callStackSymbols];
}
@end
