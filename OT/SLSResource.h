//
//  SLSResource.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSAttribute.h"
#import "SLSKeyValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSResource : NSObject

@property(nonatomic, strong) NSArray<SLSAttribute*> *attributes;

+ (instancetype) resource;
- (void) add: (NSString *)key value: (NSString *)value;
- (void) add: (NSArray<SLSAttribute *> *)attributes;
- (void) merge: (SLSResource *)resource;

+ (SLSResource*) of: (NSString *)key value: (NSString *)value;
+ (SLSResource*) of: (SLSKeyValue*)keyValue, ...NS_REQUIRES_NIL_TERMINATION;
+ (SLSResource *) ofAttributes: (NSArray<SLSAttribute *> *)attributes;

@end

NS_ASSUME_NONNULL_END
