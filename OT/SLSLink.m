//
//  SLSLink.m
//  Pods
//
//  Created by gordon on 2022/10/18.
//

#import "SLSLink.h"

@interface SLSLink ()
@property(nonatomic, strong) NSLock *lock;
@end

@implementation SLSLink
- (instancetype)init
{
    self = [super init];
    if (self) {
        _attributes = [NSMutableArray<SLSAttribute *> array];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

+ (instancetype) linkWithTraceId: (NSString *)traceId spanId:(NSString *)spanId {
    SLSLink *link = [[SLSLink alloc] init];
    link.traceId = traceId;
    link.spanId = spanId;
    return  link;
}
- (instancetype) addAttribute:(SLSAttribute *) attribute, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addAttributes instead.") {
    if (nil == attribute) {
        return self;
    }
    
    NSMutableArray<SLSAttribute*> *attrs = (NSMutableArray<SLSAttribute*>  *) _attributes;
    [_lock lock];
    [attrs addObject:attribute];
    
    va_list args;
    SLSAttribute *arg;
    va_start(args, attribute);
    while ((arg = va_arg(args, SLSAttribute*))) {
        [attrs addObject:arg];
    }
    va_end(args);
    [_lock unlock];
    return self;
}

- (instancetype) addAttributes:(NSArray<SLSAttribute *> *)attributes {
    if (nil == attributes || attributes.count == 0) {
        return self;
    }
    
    [_lock lock];
    [((NSMutableArray<SLSAttribute*>  *) _attributes) addObjectsFromArray:attributes];
    [_lock unlock];
    return self;
}

@end
