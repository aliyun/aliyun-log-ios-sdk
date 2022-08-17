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

@interface SLSCrashReporterFeature : SLSSdkFeature

@end

NS_ASSUME_NONNULL_END
