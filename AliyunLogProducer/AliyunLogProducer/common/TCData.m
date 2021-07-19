//
//  TCData.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/19.
//

#import "TCData.h"
#import "SLSDeviceUtils.h"
#import <UIKit/UIKit.h>
#import "utdid/Utdid.h"
#import "TimeUtils.h"

@interface TCData ()
-(void) putIfNotNull:(NSMutableDictionary *)dictionay andKey:(NSString *)key andValue:(NSString *)value;
-(NSString *)returnDashIfNull: (NSString *)value;
-(void) put:(NSMutableDictionary *)dictionay andKey:(NSString *)key andValue:(NSString *)value;
@end


@implementation TCData

#pragma mark - construct
+ (TCData *)createDefault {
    TCData *scheme = [[TCData alloc] init];
    
    NSDate *date = [NSDate date];
    scheme.local_timestamp = [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970] * 1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss:SSS"];
    scheme.local_time = [dateFormatter stringFromDate:date];
    
    date = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%ld%@%@", (long)[TimeUtils getTimeInMilliis], @".",[scheme.local_timestamp substringFromIndex:10]] doubleValue]];
    scheme.local_timestamp_fixed = [NSString stringWithFormat:@"%.0f%@", [date timeIntervalSince1970], [scheme.local_timestamp substringFromIndex:10]];
    scheme.local_time_fixed = [dateFormatter stringFromDate:date];
    

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    scheme.app_name = [scheme returnDashIfNull:[infoDictionary objectForKey:@"CFBundleDisplayName"]];
    if ([scheme.app_name isEqual:@"-"]) {
        scheme.app_name = [scheme returnDashIfNull: [infoDictionary objectForKey:@"CFBundleName"]];
    }
    scheme.app_version = [scheme returnDashIfNull:[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    scheme.build_code = [scheme returnDashIfNull:[infoDictionary objectForKey:@"CFBundleVersion"]];
    
    scheme.utdid = [Utdid getUtdid];
    scheme.imei = @"-";
    scheme.imsi = @"-";
    scheme.brand = [scheme returnDashIfNull: [[UIDevice currentDevice] model]];
    scheme.device_model = [scheme returnDashIfNull:[SLSDeviceUtils getDeviceModel]];
    scheme.os = @"iOS";
    scheme.os_version = [scheme returnDashIfNull:[[UIDevice currentDevice] systemVersion]];
    scheme.carrier = [scheme returnDashIfNull:[SLSDeviceUtils getCarrier]];
    scheme.access = [scheme returnDashIfNull:[SLSDeviceUtils getNetworkTypeName]];
    scheme.access_subtype = [scheme returnDashIfNull:[SLSDeviceUtils getNetworkSubTypeName]];
    NSString *root = [SLSDeviceUtils isJailBreak];
    scheme.root = [scheme returnDashIfNull:root];
    scheme.resolution = [scheme returnDashIfNull:[SLSDeviceUtils getResolution]];
    return scheme;
}

+ (TCData *) createDefaultWithSLSConfig:(SLSConfig *)config {
    TCData *data = [self createDefault];
    
    [data setApp_id:[NSString stringWithFormat:@"%@@iOS", config.pluginAppId]];
    [data setChannel:[data returnDashIfNull:config.channel]];
    [data setChannel_name:[data returnDashIfNull:config.channelName]];
    [data setUser_nick:[data returnDashIfNull:config.userNick]];
    [data setLong_login_nick:[data returnDashIfNull:config.longLoginNick]];
    [data setUser_id:[data returnDashIfNull:config.userId]];
    [data setLong_login_user_id:[data returnDashIfNull:config.longLoginUserId]];
    [data setLogon_type:[data returnDashIfNull:config.loginType]];
    [data setExt:config.ext];
    
    return data;
}

+ (NSString *)fillWithDashIfEmpty:(NSString *)content {
    return nil == content || [@"" isEqual:content] ? @"-" : content;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *fields =  [[NSMutableDictionary alloc] init];
    [self putIfNotNull:fields andKey:@"app_id" andValue: [self app_id]];
    [self putIfNotNull:fields andKey:@"app_name" andValue: [self app_name]];
    [self putIfNotNull:fields andKey:@"app_version" andValue: [self app_version]];
    [self putIfNotNull:fields andKey:@"build_code" andValue: [self build_code]];
    [self putIfNotNull:fields andKey:@"sdk_version" andValue: [self sdk_version]];
    [self putIfNotNull:fields andKey:@"sdk_type" andValue: [self sdk_type]];
    [self putIfNotNull:fields andKey:@"channel" andValue: [self channel]];
    [self putIfNotNull:fields andKey:@"channel_name" andValue: [self channel_name]];
    [self putIfNotNull:fields andKey:@"user_nick" andValue: [self user_nick]];
    [self putIfNotNull:fields andKey:@"long_login_nick" andValue: [self long_login_nick]];
    [self putIfNotNull:fields andKey:@"logon_type" andValue: [self logon_type]];
    [self putIfNotNull:fields andKey:@"user_id" andValue: [self user_id]];
    [self putIfNotNull:fields andKey:@"long_login_user_id" andValue: [self long_login_user_id]];
    [self putIfNotNull:fields andKey:@"utdid" andValue: [self utdid]];
    [self putIfNotNull:fields andKey:@"imei" andValue: [self imei]];
    [self putIfNotNull:fields andKey:@"imsi" andValue: [self imsi]];
    [self putIfNotNull:fields andKey:@"imeisi" andValue: [self imeisi]];
    [self putIfNotNull:fields andKey:@"idfa" andValue: [self idfa]];
    [self putIfNotNull:fields andKey:@"brand" andValue: [self brand]];
    [self putIfNotNull:fields andKey:@"device_model" andValue: [self device_model]];
    [self putIfNotNull:fields andKey:@"resolution" andValue: [self resolution]];
    [self putIfNotNull:fields andKey:@"os" andValue: [self os]];
    [self putIfNotNull:fields andKey:@"os_version" andValue: [self os_version]];
    [self putIfNotNull:fields andKey:@"carrier" andValue: [self carrier]];
    [self putIfNotNull:fields andKey:@"access" andValue: [self access]];
    [self putIfNotNull:fields andKey:@"access_subtype" andValue: [self access_subtype]];
    [self putIfNotNull:fields andKey:@"network_type" andValue: [self network_type]];
    [self putIfNotNull:fields andKey:@"school" andValue: [self school]];
    [self putIfNotNull:fields andKey:@"root" andValue: [self root]];
    [self putIfNotNull:fields andKey:@"reserve1" andValue: [self reserve1]];
    [self putIfNotNull:fields andKey:@"reserve2" andValue: [self reserve2]];
    [self putIfNotNull:fields andKey:@"reserve3" andValue: [self reserve3]];
    [self putIfNotNull:fields andKey:@"reserve4" andValue: [self reserve4]];
    [self putIfNotNull:fields andKey:@"reserve5" andValue: [self reserve5]];
    [self putIfNotNull:fields andKey:@"reserve6" andValue: [self reserve6]];
    [self putIfNotNull:fields andKey:@"reserves" andValue: [self reserves]];
    [self putIfNotNull:fields andKey:@"local_time" andValue: [self local_time]];
    [self putIfNotNull:fields andKey:@"local_timestamp" andValue: [self local_timestamp]];
    [self putIfNotNull:fields andKey:@"local_time_fixed" andValue: [self local_time_fixed]];
    [self putIfNotNull:fields andKey:@"local_timestamp_fixed" andValue: [self local_timestamp_fixed]];
    [self putIfNotNull:fields andKey:@"reach_time" andValue: [self reach_time]];
    [self putIfNotNull:fields andKey:@"reach_time_stamp" andValue: [self reach_time_stamp]];
    [self putIfNotNull:fields andKey:@"page" andValue: [self page]];
    [self putIfNotNull:fields andKey:@"event_id" andValue: [self event_id]];
    [self putIfNotNull:fields andKey:@"event_type" andValue: [self event_type]];
    [self putIfNotNull:fields andKey:@"arg1" andValue: [self arg1]];
    [self putIfNotNull:fields andKey:@"arg2" andValue: [self arg2]];
    [self putIfNotNull:fields andKey:@"arg3" andValue: [self arg3]];
    [self putIfNotNull:fields andKey:@"args" andValue: [self args]];
    [self putIfNotNull:fields andKey:@"is_active" andValue: [self is_active]];
    [self putIfNotNull:fields andKey:@"start_count" andValue: [self start_count]];
    [self putIfNotNull:fields andKey:@"run_time" andValue: [self run_time]];
    [self putIfNotNull:fields andKey:@"active_uvmid" andValue: [self active_uvmid]];
    [self putIfNotNull:fields andKey:@"active_user_nick" andValue: [self active_user_nick]];
    [self putIfNotNull:fields andKey:@"page_stay_time" andValue: [self page_stay_time]];
    [self putIfNotNull:fields andKey:@"client_ip" andValue: [self client_ip]];
    [self putIfNotNull:fields andKey:@"country" andValue: [self country]];
    [self putIfNotNull:fields andKey:@"province" andValue: [self country]];
    [self putIfNotNull:fields andKey:@"city" andValue: [self city]];
    [self putIfNotNull:fields andKey:@"district" andValue: [self district]];
    
    for (NSString *key in _ext) {
        NSString *value =_ext[key];
        [self put:fields andKey:key andValue:value];
    }
    
    return fields;
}

- (void) putIfNotNull:(NSMutableDictionary *)dictionay andKey:(NSString *)key andValue:(NSString *)value {
    if (key && value) {
        [dictionay setValue:value forKey:key];
    }
}

- (NSString *)returnDashIfNull:(NSString *)value {
    if (!value) {
        return @"-";
    }
    
    return value;
}

- (void)put:(NSMutableDictionary *)dictionay andKey:(NSString *)key andValue:(NSString *)value
{
    if (nil == key) {
        key = @"null";
    }
    
    if (nil == value) {
        value = @"null";
    }
    
    [dictionay setValue:value forKey:key];
}

@end
