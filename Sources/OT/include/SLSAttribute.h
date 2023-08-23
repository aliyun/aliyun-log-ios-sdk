//
//  SLSAttribute.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSKeyValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSAttribute : NSObject
@property(nonatomic, strong) NSString* key;
@property(nonatomic, strong) id value;

+ (SLSAttribute*) of: (NSString *) key value: (NSString*)value;
+ (SLSAttribute*) of: (NSString *) key dictValue: (NSDictionary*)value;
+ (SLSAttribute*) of: (NSString *) key arrayValue: (NSArray*)value;

+ (NSArray<SLSAttribute*> *) of: (SLSKeyValue *) keyValue, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSArray *) toArray: (NSArray<SLSAttribute *> *) attributes;

@end

NS_ASSUME_NONNULL_END
