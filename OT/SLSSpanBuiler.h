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
@class SLSSpanBuiler;

@interface SLSSpanBuiler : NSObject
+ (SLSSpanBuiler *) builder;
- (SLSSpanBuiler *) initWithName: (NSString *)name provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor;
- (SLSSpanBuiler *) setParent: (SLSSpan *)parent;
- (SLSSpanBuiler *) addAttribute: (SLSAttribute *) attribute, ... NS_REQUIRES_NIL_TERMINATION;
- (SLSSpanBuiler *) addAttributes: (NSArray<SLSAttribute *> *) attributes;
- (SLSSpanBuiler *) setStart: (long) start;
- (SLSSpanBuiler *) setResource: (SLSResource *) resource;
- (SLSSpan *) build;
@end

NS_ASSUME_NONNULL_END
