//
//  SLSTraceFeature.h
//  Pods
//
//  Created by gordon on 2022/9/13.
//

#if __has_include("AliyunLogCore/SLSSdkFeature.h")
#import "AliyunLogCore/SLSSdkFeature.h"
#else
#import "SLSSdkFeature.h"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface SLSTraceFeature : SLSSdkFeature

- (BOOL) addLog: (Log *) log;

@end

NS_ASSUME_NONNULL_END
