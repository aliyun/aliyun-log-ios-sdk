//
//  SLSTracer+Internal.h
//  Pods
//
//  Created by gordon on 2022/9/14.
//

#import <AliyunLogProducer/AliyunLogProducer.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSTracer (Internal)
+ (void) setTraceFeature: (SLSTraceFeature *) feature;
+ (void) setSpanProvider: (id<SLSSpanProviderProtocol>) provider;
+ (void) setSpanProcessor: (id<SLSSpanProcessorProtocol>) processor;
@end

NS_ASSUME_NONNULL_END
