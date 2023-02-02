//
//  SLSScope.m
//  
//
//  Created by gordon on 2023/2/2.
//

#import "SLSScope.h"

@implementation SLSScope
+ (SLSScope *) getDefault {
    return [[SLSScope alloc] init];
}
- (NSDictionary *) toJson {
    return @{
        @"name": _name,
        @"version": [NSString stringWithFormat:@"%lu", _version],
        @"attributes": [SLSAttribute toArray:_attributes]
    };
}
@end
