//
//  SLSEvent.h
//  Pods
//
//  Created by gordon on 2022/10/11.
//

#import <Foundation/Foundation.h>
#import "SLSAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSEvent : NSObject
@property(nonatomic, strong) NSString *name;
@property(atomic, assign) long epochNanos;
@property(atomic, assign) int totalAttributeCount;
@property(nonatomic, strong, readonly) NSArray<SLSAttribute *> *attributes;

+ (instancetype) eventWithName: (NSString *)name;

- (instancetype) addAttribute:(SLSAttribute *)attributes, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addAttributes instead.");
- (instancetype) addAttributes:(NSArray<SLSAttribute *> *)attributes;

@end

NS_ASSUME_NONNULL_END
