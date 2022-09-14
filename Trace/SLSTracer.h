//
//  SLSTracer.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/9/13.
//

#import <Foundation/Foundation.h>
#import "SLSTraceFeature.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SLSURLSessionInstrumentationDelegate <NSObject>
- (BOOL) shouldInstrument: (NSURLRequest *) request;
- (NSDictionary<NSString *, NSString *> *) injectCustomeHeaders;
@end

@interface SLSTracer : NSObject
+ (SLSSpanBuilder *) spanBuilder: (NSString *) spanName;
+ (SLSSpan *) startSpan: (NSString *) spanName;
+ (void) withinSpan:(NSString *)spanName block:(void (^)(void))block;
+ (void) withinSpan:(NSString *)spanName active:(BOOL)active block:(void (^)(void))block;
+ (void) withinSpan: (NSString *) spanName active: (BOOL) active parent: (nullable SLSSpan *) parent block: (void (^)(void)) block;

+ (void) registerURLSessionInstrumentationDelegate: (id<SLSURLSessionInstrumentationDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
