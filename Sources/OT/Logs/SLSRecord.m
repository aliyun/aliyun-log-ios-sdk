//
//  SLSRecord.m
//  
//
//  Created by gordon on 2023/2/2.
//

#import "SLSRecord.h"

@implementation SLSRecord

+ (SLSRecord *) record {
    return [[SLSRecord alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _body = [[SLSBody alloc] init];
        _attributes = [NSMutableArray array];
    }
    return self;
}

- (NSDictionary *) toJson {
    return @{
        @"timeUnixNano": [NSString stringWithFormat:@"%lu", _timeUnixNano / 1000],
        @"severityNumber": @"",
        @"severityText":_severityText,
        @"body": @{
            @"stringValue": _body.stringValue
        },
        @"attributes": [SLSAttribute toArray:_attributes],
        @"traceId": _traceId,
        @"spanId": _spanId
    };
}
+ (NSArray *) toArray: (NSArray<SLSRecord *> *) records {
    NSMutableArray *array = [NSMutableArray array];
    for (SLSRecord *record in records) {
        [array addObject:[record toJson]];
    }
    return array;
}

@end

@implementation SLSBody


@end
