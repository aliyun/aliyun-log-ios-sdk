//
//  SlSKeyValue.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSKeyValue.h"

@implementation SLSKeyValue

+ (SLSKeyValue *) create: (NSString*) key value: (NSString*) value {
    SLSKeyValue *kv = [[SLSKeyValue alloc] init];
    kv.key = key;
    kv.value = value;
    return kv;
}
@end
