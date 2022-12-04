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
#pragma mark - instance
+ (SLSSpanBuilder *) builder;
- (SLSSpanBuilder *) initWithName: (NSString *)name provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor;

#pragma mark - setter
- (SLSSpanBuilder *) setParent: (SLSSpan *)parent;
- (SLSSpanBuilder *) setActive: (BOOL) active;
- (SLSSpanBuilder *) setKind: (SLSKind) kind;
- (SLSSpanBuilder *) addAttribute: (SLSAttribute *) attribute, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addAttributes instead.");
- (SLSSpanBuilder *) addAttributes: (NSArray<SLSAttribute *> *) attributes NS_SWIFT_NAME(addAttributes(_:));
- (SLSSpanBuilder *) setStart: (long) start;
- (SLSSpanBuilder *) addResource: (SLSResource *) resource NS_SWIFT_NAME(addResource(_:));
- (SLSSpanBuilder *) setService: (NSString *)service;
- (SLSSpanBuilder *) setGlobal: (BOOL) global;
#pragma mark - build
- (SLSSpan *) build;
@end

NS_ASSUME_NONNULL_END
