//
//  TCData.h
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/19.
//

#import <Foundation/Foundation.h>
#import "SLSConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCData : NSObject
@property(atomic, strong) NSString * app_id;
@property(atomic, strong) NSString * app_name;
@property(atomic, strong) NSString * app_version;
@property(atomic, strong) NSString * build_code;
@property(atomic, strong) NSString * sdk_version;
@property(atomic, strong) NSString * sdk_type;
@property(atomic, strong) NSString * channel;
@property(atomic, strong) NSString * channel_name;
@property(atomic, strong) NSString * user_nick;
@property(atomic, strong) NSString * user_id;
@property(atomic, strong) NSString * long_login_nick;
@property(atomic, strong) NSString * long_login_user_id;
@property(atomic, strong) NSString * logon_type;
@property(atomic, strong) NSString * utdid;
@property(atomic, strong) NSString * imei;
@property(atomic, strong) NSString * imsi;
@property(atomic, strong) NSString * imeisi;
@property(atomic, strong) NSString * idfa;
@property(atomic, strong) NSString * brand;
@property(atomic, strong) NSString * device_model;
@property(atomic, strong) NSString * resolution;
@property(atomic, strong) NSString * os;
@property(atomic, strong) NSString * os_version;
@property(atomic, strong) NSString * carrier;
@property(atomic, strong) NSString * access;
@property(atomic, strong) NSString * access_subtype;
@property(atomic, strong) NSString * network_type;
@property(atomic, strong) NSString * school;
@property(atomic, strong) NSString * root;
@property(atomic, strong) NSString * reserve1;
@property(atomic, strong) NSString * reserve2;
@property(atomic, strong) NSString * reserve3;
@property(atomic, strong) NSString * reserve4;
@property(atomic, strong) NSString * reserve5;
@property(atomic, strong) NSString * reserve6;
@property(atomic, strong) NSString * reserves;
@property(atomic, strong) NSString * local_time;
@property(atomic, strong) NSString * local_timestamp;
@property(atomic, strong) NSString * local_time_fixed;
@property(atomic, strong) NSString * local_timestamp_fixed;
@property(atomic, strong) NSString * reach_time;
@property(atomic, strong) NSString * reach_time_stamp;
@property(atomic, strong) NSString * page;
@property(atomic, strong) NSString * event_id;
@property(atomic, strong) NSString * event_type;
@property(atomic, strong) NSString * arg1;
@property(atomic, strong) NSString * arg2;
@property(atomic, strong) NSString * arg3;
@property(atomic, strong) NSString * args;
@property(atomic, strong) NSString * is_active;
@property(atomic, strong) NSString * start_count;
@property(atomic, strong) NSString * run_time;
@property(atomic, strong) NSString * active_uvmid;
@property(atomic, strong) NSString * active_user_nick;
@property(atomic, strong) NSString * page_stay_time;
@property(atomic, strong) NSString * client_ip;
@property(atomic, strong) NSString * country;
@property(atomic, strong) NSString * province;
@property(atomic, strong) NSString * city;
@property(atomic, strong) NSString * district;
@property(atomic, strong) NSMutableDictionary * ext;

+ (TCData *) createDefault;
+ (TCData *) createDefaultWithSLSConfig: (SLSConfig *) config;
+ (NSString *) fillWithDashIfEmpty: (NSString *) content;
- (NSDictionary *) toDictionary;
- (NSDictionary *) toDictionaryWithIgnoreExt: (BOOL) ignore;
@end

NS_ASSUME_NONNULL_END
