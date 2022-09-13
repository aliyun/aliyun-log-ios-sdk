//
//  SLSTracer.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/9/13.
//

#import "SLSTracer.h"
#if __has_include("AliyunLogOT/AliyunLogOT.h")
#import "AliyunLogOT/AliyunLogOT.h"
#else
#import "AliyunLogOT.h"
#endif

@interface SLSTracer ()
@property(nonatomic, strong) SLSTraceFeature *feature;
@property(nonatomic, strong) id<SLSSpanProviderProtocol> provider;
@property(nonatomic, strong) id<SLSSpanProcessorProtocol> processor;
@end

@implementation SLSTracer
+ (instancetype) sharedInstance {
    static SLSTracer *tracer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tracer = [[SLSTracer alloc] init];
    });
    return tracer;
}
- (void) setTraceFeature: (SLSTraceFeature *) feature {
    _feature = feature;
}
- (void) setSpanProvider: (id<SLSSpanProviderProtocol>) provider {
    _provider = provider;
}
- (void) setSpanProcessor: (id<SLSSpanProcessorProtocol>) processor {
    _processor = processor;
}

- (SLSSpanBuilder *) spanBuilder: (NSString *) spanName {
    return [[SLSSpanBuilder builder] initWithName:spanName provider:_provider processor:_processor];
}

- (SLSSpan *) startSpan: (NSString *) spanName {
    return [[self spanBuilder:spanName] build];
}

- (void) withinSpan:(NSString *)spanName block:(void (^)(void))block {
    [self withinSpan:spanName active:YES block:block];
}

- (void) withinSpan:(NSString *)spanName active:(BOOL)active block:(void (^)(void))block {
    [self withinSpan:spanName active:active parent:nil block:block];
}

- (void) withinSpan: (NSString *) spanName active: (BOOL) active parent: (nullable SLSSpan *) parent block: (void (^)(void)) block {
    SLSSpan *span = [[[self spanBuilder:spanName] setParent:parent] build];
    if (active) {
        SLSScope scope = [SLSContextManager makeCurrent:span];
        block();
        scope();
        [span end];
    } else {
        block();
        [span end];
    }
}
@end
