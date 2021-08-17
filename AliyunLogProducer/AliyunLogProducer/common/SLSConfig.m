//
//  SLSConfig.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/19.
//

#import "SLSConfig.h"

@implementation SLSConfig

- (instancetype)init
{
    if (self = [super init]) {
        _ext = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addCustomWithKey:(nullable NSString *)key andValue:(nullable NSString *)value
{
    if (nil == key) {
        key = @"null";
    }
    
    if (nil == value) {
        value = @"null";
    }
    
    [_ext setValue:value forKey:key];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", @{
            @"appVersion": (_appVersion != nil ? _appVersion : @""),
            @"appName": (_appName != nil ? _appName : @""),
            @"endpoint": (_endpoint != nil ? _endpoint : @""),
            @"accessKeyId": (_accessKeyId != nil ? _accessKeyId : @""),
            @"accessKeySecret": (_accessKeySecret != nil ? _accessKeySecret : @""),
            @"securityToken": (_securityToken != nil ? _securityToken : @""),
            @"pluginAppId": (_pluginAppId != nil ? _pluginAppId : @""),
            @"pluginLogproject": (_pluginLogproject != nil ? _pluginLogproject : @""),

            @"channel": (_channel != nil ? _channel : @""),
            @"channelName": (_channelName != nil ? _channelName : @""),
            @"userNick": (_userNick != nil ? _userNick :@""),
            @"longLoginNick": (_longLoginNick != nil ? _longLoginNick : @""),
            @"userId": (_userId != nil ? _userId : @""),
            @"longLoginUserId": (_longLoginUserId != nil ? _longLoginUserId : @""),
            @"loginType": (_loginType != nil ? _loginType : @""),
            @"ext": (_ext != nil ? _ext : @"")
        }];
}
@end
