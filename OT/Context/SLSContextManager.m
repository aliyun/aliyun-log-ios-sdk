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
@property(nonatomic, strong) NSDictionary *threadDictionary;
@property(nonatomic, strong) NSDictionary *cachedContextDictionary;
@end

@implementation SLSContextManager

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


@end
