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
#import "Log.h"

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

#pragma mark - Logs
+ (BOOL) log: (NSString *) logContent level: (SLSLogsLevel) level {
    return [self log: logContent level: level attributes: [NSArray array]];
}

+ (BOOL) log: (NSString *) logContent level: (SLSLogsLevel) level attributes: (NSArray<SLSAttribute *> *) attributes {
    SLSLogDataBuilder * builder = [SLSLogData builder];
    [builder setLogContent:logContent];
    [builder setLogsLevel:level];
    [builder setAttribute:attributes];
    
    return [self log: [builder build]];
}

+ (BOOL) log: (SLSLogData *) logData {
    if (nil == logData) {
        return false;
    }
    
    SLSSpan *activeSpan = [SLSContextManager activeSpan];
    if (nil == activeSpan) {
        activeSpan = [[self spanBuilder:@"logs"] build];
    }
    
    SLSResource *r = logData.resource;
    if (nil == r) {
        r = [SLSResource resource];
    }
    [r merge:activeSpan.resource];
    [logData setResource:r];
    
    NSMutableArray<SLSAttribute *> *attributes = [NSMutableArray array];
    for (NSString *key in activeSpan.attribute) {
        [attributes addObject:[SLSAttribute of:key value:activeSpan.attribute[key]]];
    }
    for (SLSRecord *record in logData.logRecords) {
        [record addAttribute:attributes];
        if (record.traceId.length == 0) {
            [record setTraceId:activeSpan.traceID];
        }
        
        if (record.spanId.length == 0) {
            [record setSpanId:activeSpan.spanID];
        }
    }
    
    Log *log = [Log log];
    [log putContents:[logData toJson]];
    return [_feature addLog:log];
}

@end

