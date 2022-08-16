//
//  SLSResource.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//
#import "SLSResource.h"
#import "SLSKeyValue.h"

@interface SLSResource()

@end

@implementation SLSResource

+ (instancetype) resource {
    return [[SLSResource alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        _attributes = [NSMutableArray array];
    }
    return self;
}

- (void) add: (NSString *)key value: (NSString *)value {
    NSMutableArray<SLSAttribute*> *array = (NSMutableArray<SLSAttribute*>*) _attributes;
    [array addObject:[SLSAttribute of:key value:value]];
}

- (void) add: (NSArray<SLSAttribute *> *)attributes {
    NSMutableArray<SLSAttribute*> *array = (NSMutableArray<SLSAttribute*>*) _attributes;
    [array addObjectsFromArray:attributes];
}

- (void) merge: (SLSResource *)resource {
    if (!resource || !resource.attributes) {
        return;
    }
    
    NSMutableArray<SLSAttribute*> *array = (NSMutableArray<SLSAttribute*>*) _attributes;
    [array addObjectsFromArray:resource.attributes];
}

+ (SLSResource*) of: (NSString *)key value: (NSString *)value {
    SLSResource *resource = [[SLSResource alloc] init];
    [resource add:key value:value];
    return resource;
}

+ (SLSResource*) of: (SLSKeyValue*)keyValue, ...NS_REQUIRES_NIL_TERMINATION {
    SLSResource *resource = [[SLSResource alloc] init];
    [resource add:keyValue.key value:keyValue.value];
    
    va_list args;
    SLSKeyValue *arg;
    va_start(args, keyValue);
    while ((arg = va_arg(args, SLSKeyValue*))) {
        [resource add:arg.key value:arg.value];
    }
    va_end(args);
    
    return resource;
}
+ (SLSResource *) ofAttributes: (NSArray<SLSAttribute *> *)attributes {
    SLSResource *resource = [SLSResource resource];
    NSMutableArray<SLSAttribute *> *attrs = (NSMutableArray<SLSAttribute *> *) resource.attributes;
    [attrs addObjectsFromArray:attributes];
    return resource;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SLSResource *r = [SLSResource resource];
    r.attributes = [NSMutableArray arrayWithArray:self.attributes];
    return r;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    SLSResource *r = [SLSResource resource];
    r.attributes = [NSMutableArray arrayWithArray:self.attributes];
    return r;
}

@end
