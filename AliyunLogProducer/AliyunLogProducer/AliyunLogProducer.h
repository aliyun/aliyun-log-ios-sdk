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
#import "TimeUtils.h"

#if __has_include("LogProducerClient+Bricks.h")
#import "LogProducerClient+Bricks.h"
#import "SLSAdapter.h"
#import "SLSConfig.h"
#import "TCData.h"
#import "IPlugin.h"
#endif

#if __has_include(<AliyunLogProducer/SLSCrashReporterPlugin.h>)
#import "SLSCrashReporterPlugin.h"
#import "IReporterSender.h"
#import "IFileParser.h"
#endif

#if __has_include(<AliyunLogProducer/SLSTracePlugin.h>)
#import "SLSTracePlugin.h"
#endif

