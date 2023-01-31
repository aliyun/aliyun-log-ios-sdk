//
//  SLSTracer.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/9/13.
//

#import "SLSTracer.h"
#import "SLSTracer+Internal.h"
#if __has_include("AliyunLogOT/AliyunLogOT.h")
#import "AliyunLogOT/AliyunLogOT.h"
#else
#import "AliyunLogOT.h"
#endif
#import "SLSURLSessionInstrumentation.h"

static SLSTraceFeature *_feature;
static id<SLSSpanProviderProtocol> _provider;
static id<SLSSpanProcessorProtocol> _processor;

@implementation SLSTracer
#pragma mark - internal setter
+ (void) setTraceFeature: (SLSTraceFeature *) feature {
    _feature = feature;
}
+ (void) setSpanProvider: (id<SLSSpanProviderProtocol>) provider {
    _provider = provider;
}
+ (void) setSpanProcessor: (id<SLSSpanProcessorProtocol>) processor {
    _processor = processor;
}

#pragma mark - span & builder
+ (SLSSpanBuilder *) spanBuilder: (NSString *) spanName {
    return [[SLSSpanBuilder builder] initWithName:spanName provider:_provider processor:_processor];
}

+ (SLSSpan *) startSpan: (NSString *) spanName {
    return [self startSpan:spanName active:NO];
}

+ (SLSSpan *) startSpan: (NSString *) spanName active: (BOOL) active {
    return [[[self spanBuilder:spanName] setActive:active] build];
}

#pragma mark - function block
+ (void) withinSpan:(NSString *)spanName block:(void (^)(void))block {
    [self withinSpan:spanName active:YES block:block];
}

+ (void) withinSpan:(NSString *)spanName active:(BOOL)active block:(void (^)(void))block {
    [self withinSpan:spanName active:active parent:nil block:block];
}

+ (void) withinSpan: (NSString *) spanName active: (BOOL) active parent: (nullable SLSSpan *) parent block: (void (^)(void)) block {
    SLSSpan *span = [[[self spanBuilder:spanName] setParent:parent] build];
    @try {
        if (active) {
            SLSScope scope = [SLSContextManager makeCurrent:span];
            block();
            scope();
        } else {
            block();
        }
    } @catch (NSException *exception) {
        [span setStatusCode:ERROR];
        [span setStatusMessage: [NSString stringWithFormat:@"exception: {name: %@, reason: %@}", exception.name, exception.reason]];
//        @throw exception;
    } @finally {
        [span end];
    }
}

#pragma mark - public setter
+ (void) registerURLSessionInstrumentationDelegate: (id<SLSURLSessionInstrumentationDelegate>) delegate {
    [SLSURLSessionInstrumentation registerInstrumentationDelegate:delegate];
}
@end

