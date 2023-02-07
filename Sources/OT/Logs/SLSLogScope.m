//
//  SLSLogScope.m
//  
//
//  Created by gordon on 2023/2/2.
//

#import "SLSLogScope.h"

@interface SLSLogScope ()
- (instancetype) init: (NSString *) name version: (NSInteger) version attributes: (NSArray<SLSAttribute *> *) attributes;
@end

@implementation SLSLogScope
+ (SLSLogScope *) getDefault {
    return [self scope:@"log" version:1 attributes:[NSArray array]];
}

+ (SLSLogScope *) scope: (NSString *) name version: (NSInteger) version attributes: (NSArray<SLSAttribute *> *) attributes {
    return [[SLSLogScope alloc] init:name version:version attributes:attributes];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _attributes = [NSMutableArray array];
    }
    return self;
}

- (instancetype) init: (NSString *) name version: (NSInteger) version attributes: (NSArray<SLSAttribute *> *) attributes {
    self = [self init];
    if (self) {
        _name = name;
        _version = version;
        [((NSMutableArray *) _attributes) addObjectsFromArray:attributes];
    }
    return self;
}

- (NSDictionary *) toJson {
    return @{
        @"name": _name.length > 0 ? _name : @"",
        @"version": [NSString stringWithFormat:@"%lu", _version],
        @"attributes": [SLSAttribute toArray:_attributes]
    };
}
@end
