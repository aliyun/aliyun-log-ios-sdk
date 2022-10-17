//
//  SLSSpan.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSSpan.h"
#import "SLSContextManager.h"
#import "NSString+SLS.h"

NSString* const SLSINTERNAL = @"INTERNAL";
NSString* const SLSSERVER = @"SERVER";
NSString* const SLSCLIENT = @"CLIENT";
NSString* const SLSPRODUCER = @"PRODUCER";
NSString* const SLSCONSUMER = @"CONSUMER";

typedef void (^_internal_Scope)(void);

@interface SLSSpan ()
@property(nonatomic, strong, readonly) _internal_Scope scope;
@property(nonatomic, strong) NSLock *lock;
- (void) addEventInternal:(SLSEvent *)event;
@end

@implementation SLSSpan

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attribute = [NSMutableDictionary<NSString*, NSString*> dictionary];
        _evetns = [NSMutableArray<SLSEvent*> array];
        _resource = [[SLSResource alloc] init];
        _kind = SLSCLIENT;
        _isGlobal = YES;
        _lock = [[NSLock alloc] init];
    }

    return self;
}

- (instancetype) setParent: (SLSSpan *) parent {
    if (!parent) {
        return self;
    }
    
    [_lock lock];
    _parentSpanID = parent.spanID;
    _traceID = parent.traceID;
    [_lock unlock];
    return self;
}

- (SLSSpan *) addAttribute:(SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION {
    [_lock lock];
    NSMutableDictionary<NSString*, NSString*> *dict = (NSMutableDictionary<NSString*, NSString*> *) _attribute;
    [dict setObject:attribute.value forKey:attribute.key];
    va_list args;
    SLSAttribute *arg;
    va_start(args, attribute);
    while ((arg = va_arg(args, SLSAttribute*))) {
        [dict setObject:arg.value forKey:arg.key];
    }
    va_end(args);
    [_lock unlock];
    return self;
}

- (SLSSpan *) addAttributes:(NSArray<SLSAttribute*> *)attributes {
    [_lock lock];
    NSMutableDictionary<NSString*, NSString*> *dict = (NSMutableDictionary<NSString*, NSString*> *) _attribute;
    
    for (SLSAttribute *attr in attributes) {
        [dict setObject:attr.value forKey:attr.key];
    }
    [_lock unlock];
    return self;
}
- (SLSSpan *) addResource: (SLSResource *) resource {
    if (resource) {
        [_lock lock];
        [_resource merge:resource];
        [_lock unlock];
    }
    
    return self;
}
- (SLSSpan *) addEvent:(NSString *)name {
    [self addEventInternal:[SLSEvent eventWithName:name]];
    return self;
}
- (SLSSpan *) addEvent:(NSString *)name attribute: (SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION {
    SLSEvent *event = [SLSEvent eventWithName:name];
    [event addAttribute:attribute, nil];

    va_list args;
    SLSAttribute *arg;
    va_start(args, attribute);
    while ((arg = va_arg(args, SLSAttribute*))) {
        [event addAttribute:arg, nil];
    }
    va_end(args);

    [self addEventInternal:event];
    return self;
}
- (SLSSpan *) addEvent:(NSString *)name attributes:(NSArray<SLSAttribute *> *)attributes {
    [self addEventInternal:
         [[SLSEvent eventWithName:name] addAttributes:attributes]
    ];
    return self;
}

- (SLSSpan *) recordException:(NSException *)exception {
    return [self recordException:exception attributes:[NSArray array]];
}
- (SLSSpan *) recordException:(NSException *)exception attribute: (SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray<SLSAttribute *> *attr = [NSMutableArray array];
    if (nil != attribute) {
        [attr addObject:attribute];
    }

    va_list args;
    SLSAttribute *arg;
    va_start(args, attribute);
    while ((arg = va_arg(args, SLSAttribute*))) {
        [attr addObject:arg];
    }
    va_end(args);

    return [self recordException:exception attributes:attr];
}
- (SLSSpan *) recordException:(NSException *)exception attributes:(NSArray<SLSAttribute *> *)attribute {
    SLSEvent *event = [[SLSEvent eventWithName:@"exception"] addAttribute:
                           [SLSAttribute of:@"exception.type" value:exception.name],
                           [SLSAttribute of:@"exception.message" value:exception.reason],
                           [SLSAttribute of:@"exception.stacktrace" value:(exception.callStackSymbols ? [[exception.callStackSymbols valueForKey:@"description"] componentsJoinedByString:@"\n"] : @"")],
                           nil
    ];

    [event addAttributes:attribute];

    [self addEventInternal:event];
    return self;
}

- (void) addEventInternal:(SLSEvent *)event {
    [_lock lock];
    [((NSMutableArray<SLSEvent*> *) _evetns) addObject:event];
    [_lock unlock];
}

- (BOOL) end {
    [_lock lock];
    if (_isEnd) {
        return NO;
    }
    _isEnd = YES;
    
    _duration = (_end - _start) / 1000;
    if (nil != _scope) {
        _scope();
    }
    [_lock unlock];
    return YES;
}

- (NSDictionary<NSString*, NSString*> *) toDict {
    [_lock lock];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:_name forKey:@"name"];
    [dict setObject:_kind forKey:@"kind"];
    [dict setObject:_traceID forKey:@"traceID"];
    [dict setObject:_spanID forKey:@"spanID"];
    [dict setObject:_parentSpanID ? _parentSpanID : @"" forKey:@"parentSpanID"];
    [dict setObject:_sessionId ? _sessionId : @"" forKey:@"sid"];
    [dict setObject:_transactionId ? _transactionId : @"" forKey:@"pid"];
    [dict setObject:[NSString stringWithFormat:@"%ld", _start] forKey:@"start"];
    [dict setObject:[NSString stringWithFormat:@"%ld", _duration] forKey:@"duration"];
    [dict setObject:[NSString stringWithFormat:@"%ld", _end] forKey:@"end"];
    [dict setObject:_statusCode == UNSET ? @"UNSET" : (_statusCode == OK ? @"OK" : @"ERROR" ) forKey:@"statusCode"];
    [dict setObject:_statusMessage.length > 0 ? _statusMessage : @"" forKey:@"statusMessage"];
    [dict setObject:_host ? _host : @"" forKey:@"host"];
    // service name default: iOS
    [dict setObject:_service.length > 0 ? _service : @"iOS" forKey:@"service"];
    
    NSMutableDictionary<NSString*, NSString*> *attributeDict = [NSMutableDictionary<NSString*, NSString*> dictionary];
    for (NSString* key in [_attribute allKeys]) {
        [attributeDict setObject:[_attribute valueForKey:key] forKey:key];
    }
    
    [dict setObject:[NSString stringWithDictionary:attributeDict] forKey:@"attribute"];
    
    if (_resource.attributes) {
        NSMutableDictionary<NSString*, NSString*> *resourceDict = [NSMutableDictionary<NSString*, NSString*> dictionary];
        for (SLSAttribute *attr in _resource.attributes) {
            [resourceDict setObject:attr.value forKey:attr.key];
        }

        [dict setObject:[NSString stringWithDictionary: resourceDict] forKey:@"resource"];
    }
    
    if (_evetns && [_evetns count] > 0) {
        NSMutableArray *logs = [NSMutableArray array];
        for (SLSEvent *event in _evetns) {
            NSMutableDictionary *object = [NSMutableDictionary dictionary];
            [object setObject:(event.name.length > 0 ? event.name : @"") forKey:@"name"];
            [object setObject:[[NSNumber numberWithLong:event.epochNanos] stringValue] forKey:@"epochNanos"];
            [object setObject:[[NSNumber numberWithInt:event.totalAttributeCount] stringValue] forKey:@"totalAttributeCount"];
            
            NSArray<SLSAttribute *> *attributes = event.attributes;
            NSMutableDictionary<NSString*, NSString*> *attrObject = [NSMutableDictionary dictionary];
            for (SLSAttribute *attr in attributes) {
                [attrObject setObject:attr.value forKey:attr.key];
            }
            [object setObject:attrObject forKey:@"attributes"];
            
            [logs addObject:object];
        }

        [dict setObject:logs forKey:@"logs"];
    }
    [_lock unlock];
    return dict;
}

- (SLSSpan *) setGlobal: (BOOL) global {
    [_lock lock];
    _isGlobal = global;
    [_lock unlock];
    return self;
}

- (SLSSpan *) setScope: (void (^)(void)) scope {
    [_lock lock];
    _scope = scope;
    [_lock unlock];
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SLSSpan *span = [[SLSSpan alloc] init];

    [_lock lock];
    span.name = _name;
    span.traceID = _traceID;
    span.spanID = _spanID;
    span.parentSpanID = _parentSpanID;
    span.start = _start;
    span.end = _end;
    span.duration = _duration;
    span.attribute = _attribute;
    span.statusCode = _statusCode;
    span.statusMessage = _statusMessage;
    span.host = _host;
    span.resource = [_resource copy];
    span.service = _service;
    span.sessionId = _sessionId;
    span.transactionId = _transactionId;
    span->_isEnd = _isEnd;
    [_lock unlock];
    return span;
}

@end
