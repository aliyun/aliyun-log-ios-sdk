//
//  SLSUserInfo.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSUserInfo.h"

@interface SLSUserInfo ()
@property(nonatomic, strong) NSMutableDictionary *ext;
@end

@implementation SLSUserInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ext = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) addExt: (NSString *) value key: (NSString *) key {
    if (key && value) {
        [_ext setObject:value forKey:key];
    }
}

@end
