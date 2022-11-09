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

#ifndef AliyunlogCommon_h
#define AliyunlogCommon_h

//! Xcode 13 has a new option called "Manage Version and Build Number" which is ticked by default.
//! If left checked, Xcode will automatically set your app's version number which (rather counter-intuitively), will also apply to all included frameworks
//! https://stackoverflow.com/a/31418789/1760982
#define SLS_SDK_VERSION @"3.1.3"

#define SLSLog(fmt, ...) NSLog((@"[SLSiOS] %s " fmt), __FUNCTION__, ##__VA_ARGS__);
#ifdef DEBUG
    #define SLSLogV(fmt, ...) NSLog((@"[SLSiOS] %s:%d: " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define SLSLogV(...);
#endif

#endif /* AliyunlogCommon_h */

// In this header, you should import all the public headers of your framework using statements like #import <AliyunLogProducer/PublicHeader.h>

#import "LogProducerClient.h"
#import "LogProducerConfig.h"
#import "Log.h"

// AliyunLogCore
#if __has_include("AliyunLogCore/AliyunLogCore.h")
#import "AliyunLogCore/AliyunLogCore.h"
#elif __has_include("AliyunLogCore.h")
#import "AliyunLogCore.h"
#endif

// AliyunLogCrashReporter
#if __has_include("AliyunLogCrashReporter/AliyunLogCrashReporter.h")
#import "AliyunLogCrashReporter/AliyunLogCrashReporter.h"
#elif __has_include("AliyunLogCrashReporter.h")
#import "AliyunLogCrashReporter.h"
#endif

// AliyunLogNetworkDiagnosis
#if __has_include("AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.h")
#import "AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.h"
#elif __has_include("AliyunLogNetworkDiagnosis.h")
#import "AliyunLogNetworkDiagnosis.h"
#endif

// AliyunLogTrace
#if __has_include("AliyunLogTrace/AliyunLogTrace.h")
#import "AliyunLogTrace/AliyunLogTrace.h"
#elif __has_include("AliyunLogTrace.h")
#import "AliyunLogTrace.h"
#endif
