//
//  SLSSpanBuiler.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSSpan.h"
#import "SLSAttribute.h"
#import "SLSResource.h"
#import "SLSSpanProviderProtocol.h"
#import "SLSSpanProcessorProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class SLSSpanBuilder;

@interface SLSSpanBuilder : NSObject
+ (SLSSpanBuilder *) builder;
- (SLSSpanBuilder *) initWithName: (NSString *)name provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor;
- (SLSSpanBuilder *) setParent: (SLSSpan *)parent;
- (SLSSpanBuilder *) addAttribute: (SLSAttribute *) attribute, ... NS_REQUIRES_NIL_TERMINATION;
- (SLSSpanBuilder *) addAttributes: (NSArray<SLSAttribute *> *) attributes;
- (SLSSpanBuilder *) setStart: (long) start;
- (SLSSpanBuilder *) setResource: (SLSResource *) resource;
- (SLSSpanBuilder *) setServiceName: (NSString *)service;

- (SLSSpan *) build;
@end

NS_ASSUME_NONNULL_END
