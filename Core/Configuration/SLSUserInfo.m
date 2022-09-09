//
//  SLSUserInfo.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSUserInfo.h"

@interface SLSUserInfo ()

@end

@implementation SLSUserInfo

+ (instancetype) userInfo {
    return [[SLSUserInfo alloc] init];
}

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

- (id)copyWithZone:(nullable NSZone *)zone {
    SLSUserInfo *info = [[SLSUserInfo alloc] init];
    info.uid = [self.uid copy];
    info.channel = [self.channel copy];
    info->_ext = [self.ext copy];
    return info;
}

@end
