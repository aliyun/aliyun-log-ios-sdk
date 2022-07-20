//
//  SLSAttribute.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSAttribute.h"

@implementation SLSAttribute
+ (SLSAttribute*) of: (NSString *) key value: (NSString*)value {
    SLSAttribute *attribute = [[SLSAttribute alloc] init];
    attribute.key = key;
    attribute.value = value;
    return  attribute;
}

+ (NSArray<SLSAttribute*> *) of: (SLSKeyValue *) keyValue, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray<SLSAttribute*> * array = [NSMutableArray<SLSAttribute*> array];
    [array addObject:[self of:keyValue.key value:keyValue.value]];
    va_list args;
    SLSKeyValue *arg;
    va_start(args, keyValue);
    while ((arg = va_arg(args, SLSKeyValue*))) {
        [array addObject:[self of:arg.key value:arg.value]];
    }
    va_end(args);
    return  array;
}
@end
