//
//  SLSTimeUtils.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSTimeUtils.h"

@implementation SLSTimeUtils

+ (long) now {
    // nanoseconds
    return [[NSDate date] timeIntervalSince1970] * 1000000000;
}

@end
