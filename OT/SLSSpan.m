//
//  SLSSpan.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSSpan.h"

@interface SLSSpan ()

@end

@implementation SLSSpan

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attribute = [NSMutableDictionary<NSString*, NSString*> dictionary];
        _resource = [[SLSResource alloc] init];
        _kind = @"CLIENT";
    }

    return self;
}

- (void) addAttribute:(SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableDictionary<NSString*, NSString*> *dict = (NSMutableDictionary<NSString*, NSString*> *) _attribute;
    [dict setObject:attribute.value forKey:attribute.key];
    va_list args;
    SLSAttribute *arg;
    va_start(args, attribute);
    while ((arg = va_arg(args, SLSAttribute*))) {
        [dict setObject:arg.value forKey:arg.key];
    }
    va_end(args);
}

- (void) addAttributes:(NSArray<SLSAttribute*> *)attributes {
    NSMutableDictionary<NSString*, NSString*> *dict = (NSMutableDictionary<NSString*, NSString*> *) _attribute;
    
    for (SLSAttribute *attr in attributes) {
        [dict setObject:attr.value forKey:attr.key];
    }
}


- (BOOL) end {
    if (_finished) {
        return NO;
    }
    _finished = YES;
    
    _duration = (_end - _start) / 1000;
    return YES;
}

- (NSDictionary<NSString*, NSString*> *) toDict {
    NSMutableDictionary<NSString*, NSString*> *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:_name forKey:@"name"];
    [dict setObject:@"CLIENT" forKey:@"kind"];
    [dict setObject:_traceID forKey:@"traceID"];
    [dict setObject:_spanID forKey:@"spanID"];
    [dict setObject:_parentSpanID ? _parentSpanID : @"" forKey:@"parentSpanID"];
    [dict setObject:_sessionId ? _sessionId : @"" forKey:@"sid"];
    [dict setObject:_transactionId ? _transactionId : @"" forKey:@"pid"];
    [dict setObject:[NSString stringWithFormat:@"%ld", _start] forKey:@"start"];
    [dict setObject:[NSString stringWithFormat:@"%ld", _duration] forKey:@"duration"];
    [dict setObject:[NSString stringWithFormat:@"%ld", _end] forKey:@"end"];
    [dict setObject:_statusCode == UNSET ? @"UNSET" : (_statusCode == OK ? @"OK" : @"ERROR" ) forKey:@"statusCode"];
    [dict setObject:_statusMessage ? _statusMessage : @"" forKey:@"statusMessage"];
    [dict setObject:_host ? _host : @"" forKey:@"host"];
    [dict setObject:@"iOS" forKey:@"service"];
    
    NSMutableDictionary<NSString*, NSString*> *attributeDict = [NSMutableDictionary<NSString*, NSString*> dictionary];
    for (NSString* key in [_attribute allKeys]) {
        [attributeDict setObject:[_attribute valueForKey:key] forKey:key];
    }
    
    [dict setObject:[[NSString alloc]
                     initWithData:[NSJSONSerialization
                                   dataWithJSONObject:attributeDict
                                   options:kNilOptions
                                   error:nil]
                     encoding:NSUTF8StringEncoding]
             forKey:@"attribute"
    ];
    
    if (_resource.attributes) {
        NSMutableDictionary<NSString*, NSString*> *resourceDict = [NSMutableDictionary<NSString*, NSString*> dictionary];
        for (SLSAttribute *attr in _resource.attributes) {
            [resourceDict setObject:attr.value forKey:attr.key];
        }

        [dict setObject:[[NSString alloc]
                         initWithData:[NSJSONSerialization
                                       dataWithJSONObject:resourceDict
                                       options:kNilOptions
                                       error:nil]
                         encoding:NSUTF8StringEncoding]
                 forKey:@"resource"
        ];
    }
    
    
    return dict;
}

@end
