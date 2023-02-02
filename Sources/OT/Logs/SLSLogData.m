//
//  SLSLogData.m
//  
//
//  Created by gordon on 2023/2/2.
//

#import "SLSLogData.h"
#import "../SLSTimeUtils.h"

@implementation SLSLogData
+ (SLSLogDataBuilder *) builder {
    return [SLSLogDataBuilder builder];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scope = [SLSScope getDefault];
        _logRecords = [NSMutableArray array];
    }
    return self;
}

- (NSDictionary *) toJson {
    return @{
        @"resource": nil != _resource ? [_resource toDictionary] : @{},
        @"scopeLogs": @[
            @{
                @"scope": [_scope toJson],
                @"logRecords": [SLSRecord toArray:_logRecords]
            }
        ]
    };
}
@end

@implementation SLSLogDataBuilder

+ (SLSLogDataBuilder *) builder {
    return [[SLSLogDataBuilder alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _epochNanos = -1;
    }
    return self;
}

- (SLSLogDataBuilder *) setResource: (SLSResource *) resource {
    _resource = resource;
    return self;
}
- (SLSLogDataBuilder *) setSeverityText: (NSString *) severityText {
    _severityText = severityText;
    return self;
}
- (SLSLogDataBuilder *) setScope: (SLSScope *) scope {
    _scope = scope;
    return self;
}
- (SLSLogDataBuilder *) setEpochNanos: (NSInteger *) epochNanos {
    _epochNanos = epochNanos;
    return self;
}
- (SLSLogDataBuilder *) setTraceId: (NSString *) traceId {
    _traceId = traceId;
    return self;
}
- (SLSLogDataBuilder *) setSpanId: (NSString *) spanId {
    _spanId = spanId;
    return self;
}
- (SLSLogDataBuilder *) setLogContent: (NSString *) content {
    _logContent = content;
    return self;
}
- (SLSLogDataBuilder *) setAttribute: (NSArray<SLSAttribute *> *) attributes {
    _attributes = attributes;
    return self;
}

- (SLSLogData *) build {
    SLSLogData *data = [[SLSLogData alloc] init];
    data.resource = _resource;
    data.scope = nil != _scope ? _scope : [SLSScope getDefault];
    
    SLSRecord *record = [SLSRecord record];
    record.timeUnixNano = -1 != _epochNanos ? _epochNanos : [SLSTimeUtils now];
    
    record.severityText = _severityText.length > 0 ? _severityText : @"";
    record.body.stringValue = _logContent;
    
    return data;
}

@end
