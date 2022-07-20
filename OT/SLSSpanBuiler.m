//
//  SLSSpanBuiler.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSSpanBuiler.h"
#import "SLSRecordableSpan.h"
#import "SLSIdGenerator.h"
#import "SLSTimeUtils.h"

@interface SLSSpanBuiler ()
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) id<SLSSpanProcessorProtocol> spanProcessor;
@property(nonatomic, strong) id<SLSSpanProviderProtocol> spanProvider;
@property(nonatomic, strong, readonly) SLSSpan *parent;
@property(nonatomic, strong) NSMutableArray<SLSAttribute*> *attributes;
@property(nonatomic, strong, readonly) SLSResource *resource;
@property(nonatomic, assign, readonly) long start;
@end

@implementation SLSSpanBuiler

+ (SLSSpanBuiler *) builder {
    return [[SLSSpanBuiler alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attributes = [NSMutableArray<SLSAttribute*> array];
        _start = 0L;
    }
    return self;
}
- (SLSSpanBuiler *) initWithName: (NSString *)name provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor {
    self = [self init];
    if (self) {
        _name = name;
        _spanProcessor = processor;
        _spanProvider = provider;
    }
    return self;
}

- (SLSSpanBuiler *) setParent: (SLSSpan *)parent {
    _parent = parent;
    return self;
}
- (SLSSpanBuiler *) addAttribute: (SLSAttribute *) attribute, ... NS_REQUIRES_NIL_TERMINATION {
    [_attributes addObject:attribute];
    
    va_list args;
    SLSAttribute *arg;
    va_start(args, attribute);
    while ((arg = va_arg(args, SLSAttribute*))) {
        [_attributes addObject:arg];
    }
    va_end(args);
    
    return self;
}

- (SLSSpanBuiler *) addAttributes: (NSArray<SLSAttribute *> *) attributes {
    [_attributes addObjectsFromArray:attributes];
    return self;
}

- (SLSSpanBuiler *) setStart: (long) start {
    _start = start;
    return self;
}
- (SLSSpanBuiler *) setResource: (SLSResource *) resource {
    _resource = resource;
    return self;
}
- (SLSSpan *) build {
    SLSRecordableSpan *span = [[SLSRecordableSpan alloc] initWithSpanProcessor:_spanProcessor];
    span.name = _name;
    span.spanID = SLSIdGenerator.generateSpanId;
    
    SLSSpan *parentSpan = nil;
    if (nil != _parent) {
        parentSpan = _parent;
    }
    
    if (nil != parentSpan) {
        span.traceID = parentSpan.traceID;
        span.parentSpanID = parentSpan.spanID;
    } else {
        span.traceID = SLSIdGenerator.generateTraceId;
    }
    
    if (nil != _spanProvider) {
        [_attributes addObjectsFromArray:[_spanProvider provideAttribute]];
    }
    NSMutableDictionary<NSString *, NSString *> *dict = (NSMutableDictionary<NSString *, NSString *> *) span.attribute;
    for (SLSAttribute *attr in _attributes) {
        [dict setObject:attr.value forKey:attr.key];
    }
    
    SLSResource *r = SLSResource.getDefault;
    if (nil != _spanProvider) {
        [r merge:[_spanProvider provideResource]];
    }
    if (nil != _resource) {
        [r merge:_resource];
    }
    span.resource = r;
    
    if (_start != 0L) {
        span.start = _start;
    } else {
        span.start = SLSTimeUtils.now;
    }
    
    return span;
}

@end
