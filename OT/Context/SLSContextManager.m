//
//  SLSContextManager.m
//  Pods
//
//  Created by gordon on 2022/9/13.
//

#import "SLSContextManager.h"

@interface SLSContext ()
@property(nonatomic, strong) SLSSpan *span;

@end

@implementation SLSContext


@end

@interface SLSContextManager ()

@end

@implementation SLSContextManager

NSLock *lock;
SLSSpan *globalSpan;
NSString *startupTimestamp;
NSUserDefaults *userDefaults;

+ (void)initialize {
    lock = [[NSLock alloc] init];
    
    startupTimestamp = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]];
    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"sls_cached_span"];
}

+ (SLSContext *) current {
    SLSContext *context = [[[NSThread currentThread] threadDictionary] objectForKey:@"sls_thread_context"];
    if (nil == context) {
        context = [[SLSContext alloc] init];
        [[[NSThread currentThread] threadDictionary] setObject:context forKey:@"sls_thread_context"];
    }
    return context;
}

+ (void) update: (nullable SLSSpan *) span {
    SLSContext *context = [self current];
    context.span = span;
}
+ (SLSSpan *) activeSpan {
    return [self current].span;
}
+ (SLSScope) makeCurrent: (SLSSpan *) span {
    SLSContext *current = [[[NSThread currentThread] threadDictionary] objectForKey:span];
    if (nil == current) {
        current = [[SLSContext alloc] init];
        current.span = span;
        [[[NSThread currentThread] threadDictionary] setObject:current forKey:span];
    }
    
    SLSContext *beforeContext = [self current];
    if (beforeContext == current) {
        return ^() {
        };
    }
    
    [[[NSThread currentThread] threadDictionary] setObject:current forKey:@"sls_thread_context"];
    
    return ^() {
        [[[NSThread currentThread] threadDictionary] setObject:beforeContext forKey:@"sls_thread_context"];
        [[[NSThread currentThread] threadDictionary] removeObjectForKey:span];
    };
}

+ (void) setGlobalActiveSpan: (SLSSpan *) span {
    [lock lock];
    globalSpan = span;
    [lock unlock];
    
    NSArray *array = @[
        [NSString stringWithFormat:@"t:%@", span.traceID],
        [NSString stringWithFormat:@"s:%@", span.spanID],
        [NSString stringWithFormat:@"p:%@", span.parentSpanID.length > 0 ? span.parentSpanID : @""]
    ];
    [userDefaults setObject:array forKey:[NSString stringWithFormat:@"sls_%@", startupTimestamp]];
}

+ (SLSSpan *) getGlobalActiveSpan {
    return globalSpan;
}

+ (SLSSpan *) getLastGlobalActiveSpan {
    NSArray *keys = [[userDefaults dictionaryRepresentation] allKeys];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in keys) {
        if ([key hasPrefix:@"sls_"]) {
            [array addObject:key];
        }
    }
    
    if (array.count == 0) {
        return nil;
    }
    
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(NSString *)obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    NSArray *finalValue = nil;
    if (array.count == 1) {
        finalValue = [userDefaults objectForKey:[array objectAtIndex:0]];
    } else if ([array containsObject:[NSString stringWithFormat:@"sls_%@", startupTimestamp]]) {
        long index = [array indexOfObject:[NSString stringWithFormat:@"sls_%@", startupTimestamp]] - 1;
        if (index >= 0) {
            finalValue = [userDefaults objectForKey:[array objectAtIndex:index]];
            [self removeCachedSpan:array toIndex:index];
        } else {
            finalValue = [userDefaults objectForKey:[array objectAtIndex:0]];
        }
    } else {
        finalValue = [userDefaults objectForKey:[array objectAtIndex:array.count - 1]];
        [self removeCachedSpan:array toIndex:array.count -1];
    }
    
    
    SLSSpan *span = [[SLSSpan alloc] init];
    for (NSString *value in finalValue) {
        if ([value hasPrefix:@"t:"]) {
            [span setTraceID:[[value componentsSeparatedByString:@":"] objectAtIndex:1]];
        } else if ([value hasPrefix:@"s:"]) {
            [span setSpanID:[[value componentsSeparatedByString:@":"] objectAtIndex:1]];
        } else if ([value hasPrefix:@"p:"]) {
            NSArray *substrings = [value componentsSeparatedByString:@":"];
            if (substrings.count > 1 && [[substrings objectAtIndex:1] length] > 0) {
                [span setParentSpanID:[substrings objectAtIndex:1]];
            }
        }
    }
    
    return span;
}

+ (void) removeCachedSpan: (NSArray *) keys toIndex: (long) index {
    for (long i = 0; i < index; i ++) {
        [userDefaults removeObjectForKey:[keys objectAtIndex:i]];
    }
    
    [userDefaults synchronize];
}

@end
