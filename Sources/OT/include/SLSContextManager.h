//
//  SLSContextManager.h
//  Pods
//
//  Created by gordon on 2022/9/13.
//

#import <Foundation/Foundation.h>
#import "SLSSpan.h"

NS_ASSUME_NONNULL_BEGIN
@interface SLSContext : NSObject

@end

typedef void (^SLSScope)(void);

@class SLSContext;
@interface SLSContextManager : NSObject
+ (SLSContext *) current;
+ (void) update: (nullable SLSSpan *) span;
+ (SLSSpan *) activeSpan;
+ (SLSScope) makeCurrent: (SLSSpan *) span;
+ (void) setGlobalActiveSpan: (SLSSpan *) span;
+ (SLSSpan *) getGlobalActiveSpan;
+ (SLSSpan *) getLastGlobalActiveSpan;
@end

NS_ASSUME_NONNULL_END
