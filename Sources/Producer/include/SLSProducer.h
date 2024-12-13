//
//  SLSProducer.h
//  AliyunLogProducer
//
//  Created by gordon on 2023/1/18.
//  Copyright © 2023 com.aysls.ios. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef AliyunlogCommon_h
#define AliyunlogCommon_h

//! Xcode 13 has a new option called "Manage Version and Build Number" which is ticked by default.
//! If left checked, Xcode will automatically set your app's version number which (rather counter-intuitively), will also apply to all included frameworks
//! https://stackoverflow.com/a/31418789/1760982
#define SLS_SDK_VERSION @"3.1.19"

#define SLSLog(fmt, ...) NSLog((@"[SLSiOS] %s " fmt), __FUNCTION__, ##__VA_ARGS__);
#ifdef DEBUG
    #define SLSLogV(fmt, ...) NSLog((@"[SLSiOS] %s:%d: " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define SLSLogV(...);
#endif

#endif /* AliyunlogCommon_h */


#import "LogProducerClient.h"
#import "LogProducerConfig.h"
#import <AliyunLogProducer/Log.h>
#import "NSDateFormatter+SLS.h"
#import "NSDictionary+SLS.h"
#import "NSString+SLS.h"
#import "SLSHttpHeader.h"
#import "SLSSystemCapabilities.h"
#import "SLSUtils.h"
#import "TimeUtils.h"
