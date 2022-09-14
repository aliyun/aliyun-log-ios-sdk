//
//  SLSURLSessionInstrumentation.m
//  Pods
//
//  Created by gordon on 2022/9/13.
//

#import "SLSURLSessionInstrumentation.h"
#import "SLSSwizzle.h"
#import <objc/runtime.h>
#import "SLSTracer.h"

static id<SLSURLSessionInstrumentationDelegate> _delegate;

@implementation SLSURLSessionInstrumentation
+ (void) inject {
    Class clazz = NSURLSession.class;
    [self injectDataTaskWithRequest: clazz];
    [self injectDataTaskWithURL: clazz];
}

+ (void) registerInstrumentationDelegate: (id<SLSURLSessionInstrumentationDelegate>) delegate {
    _delegate = delegate;
}

+ (void) injectHttpTraceHeader: (Class) clazz sel: (SEL) sel {
    Method method = class_getInstanceMethod(clazz, sel);
    if (nil == method) {
        return;
    }
    
    SLSSwizzleInstanceMethod(clazz,
                             sel,
                             SLSSWReturnType(NSURLSessionTask *),
                             SLSSWArguments(NSURLRequest *request, SLSCompletionHandler completionHandler),
                             SLSSWReplacement({
        
        NSURLRequest *newRequest = [SLSURLSessionInstrumentation injectHttpTraceHeaderToRequest:request completionHandler:completionHandler];
        
        return SLSSWCallOriginal(newRequest, completionHandler);
    }), SLSSwizzleModeOncePerClassAndSuperclasses, (void *) sel);
    
}

+ (void) injectDataTaskWithRequest: (Class) clazz {
    SEL sel = NSSelectorFromString(@"dataTaskWithRequest:completionHandler:");
    Method method = class_getInstanceMethod(clazz, sel);
    if (method) {
        SLSSwizzleInstanceMethod(clazz,
                                 sel,
                                 SLSSWReturnType(NSURLSessionTask *),
                                 SLSSWArguments(NSURLRequest *request, SLSCompletionHandler completionHandler),
                                 SLSSWReplacement({
            
            NSURLRequest *newRequest = [SLSURLSessionInstrumentation injectHttpTraceHeaderToRequest:request completionHandler:completionHandler];
            
            return SLSSWCallOriginal(newRequest, completionHandler);
        }), SLSSwizzleModeOncePerClassAndSuperclasses, (void *) sel);
    }
    
    sel = NSSelectorFromString(@"dataTaskWithRequest:");
    method = class_getInstanceMethod(clazz, sel);
    if (method) {
        SLSSwizzleInstanceMethod(clazz,
                                 sel,
                                 SLSSWReturnType(NSURLSessionTask *),
                                 SLSSWArguments(NSURLRequest *request),
                                 SLSSWReplacement({
            
            NSURLRequest *newRequest = [SLSURLSessionInstrumentation injectHttpTraceHeaderToRequest:request completionHandler:nil];
            
            return SLSSWCallOriginal(newRequest);
        }), SLSSwizzleModeOncePerClassAndSuperclasses, (void *) sel);
    }
}

+ (void) injectDataTaskWithURL: (Class) clazz {
    SEL sel = NSSelectorFromString(@"dataTaskWithURL:completionHandler:");
    Method method = class_getInstanceMethod(clazz, sel);
    if (method) {
        SLSSwizzleInstanceMethod(clazz,
                                 sel,
                                 SLSSWReturnType(NSURLSessionTask *),
                                 SLSSWArguments(NSURL *url, SLSCompletionHandler completionHandler),
                                 SLSSWReplacement({
            return [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:completionHandler];
        }), SLSSwizzleModeOncePerClassAndSuperclasses, (void *) sel);
    }
    
    sel = NSSelectorFromString(@"dataTaskWithURL:");
    method = class_getInstanceMethod(clazz, sel);
    if (method) {
        SLSSwizzleInstanceMethod(clazz,
                                 sel,
                                 SLSSWReturnType(NSURLSessionTask *),
                                 SLSSWArguments(NSURL *url),
                                 SLSSWReplacement({
            return [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:url]];
        }), SLSSwizzleModeOncePerClassAndSuperclasses, (void *) sel);
    }
}

+ (NSURLRequest *) injectHttpTraceHeaderToRequest: (NSURLRequest *) request completionHandler: (SLSCompletionHandler) completionHandler {
    if ([request.URL.host containsString:@"log.aliyuncs.com"]) {
        return request;
    }
    
    if (_delegate && ![_delegate shouldInstrument:request]) {
        return request;
    }
    
    SLSSpanBuilder *builder = [SLSTracer spanBuilder:[NSString stringWithFormat:@"HTTP %@", request.HTTPMethod]];
    
    SLSSpan *span = [builder build];
    
    NSString *traceparent = [NSString stringWithFormat:@"00-%@-%@-01", span.traceID, span.spanID];
    NSLog(@"DEBUGGGG, traceID: %@, spanID: %@, traceparent: %@", span.traceID, span.spanID, traceparent);
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setValue:traceparent forHTTPHeaderField:@"traceparent"];
    
    NSDictionary<NSString *, NSString *> *customHeaders = [_delegate injectCustomeHeaders];
    if (customHeaders) {
        for (NSString *key in customHeaders) {
            if (key.length > 0 && [customHeaders objectForKey:key].length > 0) {
                [mutableRequest setValue:[customHeaders objectForKey:key] forKey:key];
            }
        }
    }
    
    [span end];
    
    return mutableRequest;
}
@end
