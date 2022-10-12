//
//  SLSEvent.m
//  Pods
//
//  Created by gordon on 2022/10/11.
//

#import "SLSEvent.h"
#import "SLSTimeUtils.h"

@interface SLSEvent ()
@property(nonatomic, strong) NSLock *lock;

@end
@implementation SLSEvent

+ (instancetype) eventWithName:(NSString *)name {
    SLSEvent *event = [[SLSEvent alloc] init];
    event.name = name;
    return event;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attributes = [NSMutableArray array];
        _epochNanos = [SLSTimeUtils now];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (instancetype) addAttribute:(SLSAttribute *) attribute, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addAttributes instead.") {
    if (nil == attribute) {
        return self;
    }
    
    NSMutableArray<SLSAttribute*> *attrs = (NSMutableArray<SLSAttribute*>  *) _attributes;
    [_lock lock];
    [attrs addObject:attribute];
    _totalAttributeCount += 1;
    
    va_list args;
    SLSAttribute *arg;
    va_start(args, attribute);
    while ((arg = va_arg(args, SLSAttribute*))) {
        [attrs addObject:arg];
        _totalAttributeCount += 1;
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
    _totalAttributeCount += attributes.count;
    [_lock unlock];
    return self;
}
@end
