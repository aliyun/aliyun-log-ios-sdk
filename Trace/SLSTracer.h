//
//  SLSTracer.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/9/13.
//

#import <Foundation/Foundation.h>
#import "SLSTraceFeature.h"
NS_ASSUME_NONNULL_BEGIN

@interface SLSTracer : NSObject
+ (instancetype) sharedInstance;
- (void) setTraceFeature: (SLSTraceFeature *) feature;
- (void) setSpanProvider: (id<SLSSpanProviderProtocol>) provider;
- (void) setSpanProcessor: (id<SLSSpanProcessorProtocol>) processor;

- (SLSSpanBuilder *) spanBuilder: (NSString *) spanName;
- (SLSSpan *) startSpan: (NSString *) spanName;
- (void) withinSpan:(NSString *)spanName block:(void (^)(void))block;
- (void) withinSpan:(NSString *)spanName active:(BOOL)active block:(void (^)(void))block;
- (void) withinSpan: (NSString *) spanName active: (BOOL) active parent: (nullable SLSSpan *) parent block: (void (^)(void)) block;
@end

NS_ASSUME_NONNULL_END
