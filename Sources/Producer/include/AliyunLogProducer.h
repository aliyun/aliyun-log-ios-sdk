//
//  AliyunLogProducer.h
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for AliyunLogProducer.
FOUNDATION_EXPORT double AliyunLogProducerVersionNumber;

//! Project version string for AliyunLogProducer.
FOUNDATION_EXPORT const unsigned char AliyunLogProducerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AliyunLogProducer/PublicHeader.h>

#import "SLSProducer.h"

// AliyunLogCore
#if __has_include("AliyunLogCore/AliyunLogCore.h")
#import "AliyunLogCore/AliyunLogCore.h"
#elif __has_include("AliyunLogCore.h")
#import "AliyunLogCore.h"
#endif

//// AliyunLogCrashReporter
//#if __has_include("AliyunLogCrashReporter/AliyunLogCrashReporter.h")
//#import "AliyunLogCrashReporter/AliyunLogCrashReporter.h"
//#elif __has_include("AliyunLogCrashReporter.h")
//#import "AliyunLogCrashReporter.h"
//#endif
//
//// AliyunLogNetworkDiagnosis
//#if __has_include("AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.h")
//#import "AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.h"
//#elif __has_include("AliyunLogNetworkDiagnosis.h")
//#import "AliyunLogNetworkDiagnosis.h"
//#endif
//
//// AliyunLogTrace
//#if __has_include("AliyunLogTrace/AliyunLogTrace.h")
//#import "AliyunLogTrace/AliyunLogTrace.h"
//#elif __has_include("AliyunLogTrace.h")
//#import "AliyunLogTrace.h"
//#endif
//
//// Swift
//#if __has_include("AliyunLogProducer-Swift.h")
//#import "AliyunLogProducer-Swift.h"
//#endif
//
//// AliyunLogURLSession
//#if __has_include("AliyunLogURLSession/AliyunLogURLSession-Swift.h")
//#import "AliyunLogURLSession/AliyunLogURLSession-Swift.h"
//#endif
