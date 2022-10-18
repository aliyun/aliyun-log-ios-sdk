//
//  SLSLink.h
//  Pods
//
//  Created by gordon on 2022/10/18.
//

#import <Foundation/Foundation.h>
#import "SLSAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSLink : NSObject
@property(nonatomic, strong) NSString *traceId;
@property(nonatomic, strong) NSString *spanId;
@property(nonatomic, strong, readonly) NSArray<SLSAttribute *> *attributes;

+ (instancetype) linkWithTraceId: (NSString *)traceId spanId:(NSString *)spanId;
- (instancetype) addAttribute:(SLSAttribute *)attributes, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addAttributes instead.");
- (instancetype) addAttributes:(NSArray<SLSAttribute *> *)attributes;

@end

NS_ASSUME_NONNULL_END
