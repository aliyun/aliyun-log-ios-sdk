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
@end

NS_ASSUME_NONNULL_END
