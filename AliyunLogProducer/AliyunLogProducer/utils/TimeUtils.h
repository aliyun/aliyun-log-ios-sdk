//
//  TimeUtils.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/6/8.
//  Copyright © 2021 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLSLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeUtils : NSObject
+(void) startUpdateServerTime: (NSString *)endpoint project: (NSString *)project;
+(void) updateServerTime: (NSInteger) timeInMillis;
+(NSInteger) getTimeInMilliis;
+(void) fixTime: (SLSLog *)log;
@end

NS_ASSUME_NONNULL_END
