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
@property(nonatomic, strong) NSString * app_id;
@property(nonatomic, strong) NSString * app_name;
@property(nonatomic, strong) NSString * app_version;
@property(nonatomic, strong) NSString * build_code;
@property(nonatomic, strong) NSString * sdk_version;
@property(nonatomic, strong) NSString * sdk_type;
@property(nonatomic, strong) NSString * channel;
@property(nonatomic, strong) NSString * channel_name;
@property(nonatomic, strong) NSString * user_nick;
@property(nonatomic, strong) NSString * user_id;
@property(nonatomic, strong) NSString * long_login_nick;
@property(nonatomic, strong) NSString * long_login_user_id;
@property(nonatomic, strong) NSString * logon_type;
@property(nonatomic, strong) NSString * utdid;
@property(nonatomic, strong) NSString * imei;
@property(nonatomic, strong) NSString * imsi;
@property(nonatomic, strong) NSString * imeisi;
@property(nonatomic, strong) NSString * idfa;
@property(nonatomic, strong) NSString * brand;
@property(nonatomic, strong) NSString * device_model;
@property(nonatomic, strong) NSString * resolution;
@property(nonatomic, strong) NSString * os;
@property(nonatomic, strong) NSString * os_version;
@property(nonatomic, strong) NSString * carrier;
@property(nonatomic, strong) NSString * access;
@property(nonatomic, strong) NSString * access_subtype;
@property(nonatomic, strong) NSString * network_type;
@property(nonatomic, strong) NSString * school;
@property(nonatomic, strong) NSString * root;
@property(nonatomic, strong) NSString * reserve1;
@property(nonatomic, strong) NSString * reserve2;
@property(nonatomic, strong) NSString * reserve3;
@property(nonatomic, strong) NSString * reserve4;
@property(nonatomic, strong) NSString * reserve5;
@property(nonatomic, strong) NSString * reserve6;
@property(nonatomic, strong) NSString * reserves;
@property(nonatomic, strong) NSString * local_time;
@property(nonatomic, strong) NSString * local_timestamp;
@property(nonatomic, strong) NSString * local_time_fixed;
@property(nonatomic, strong) NSString * local_timestamp_fixed;
@property(nonatomic, strong) NSString * reach_time;
@property(nonatomic, strong) NSString * reach_time_stamp;
@property(nonatomic, strong) NSString * page;
@property(nonatomic, strong) NSString * event_id;
@property(nonatomic, strong) NSString * event_type;
@property(nonatomic, strong) NSString * arg1;
@property(nonatomic, strong) NSString * arg2;
@property(nonatomic, strong) NSString * arg3;
@property(nonatomic, strong) NSString * args;
@property(nonatomic, strong) NSString * is_active;
@property(nonatomic, strong) NSString * start_count;
@property(nonatomic, strong) NSString * run_time;
@property(nonatomic, strong) NSString * active_uvmid;
@property(nonatomic, strong) NSString * active_user_nick;
@property(nonatomic, strong) NSString * page_stay_time;
@property(nonatomic, strong) NSString * client_ip;
@property(nonatomic, strong) NSString * country;
@property(nonatomic, strong) NSString * province;
@property(nonatomic, strong) NSString * city;
@property(nonatomic, strong) NSString * district;
@property(nonatomic, strong) NSMutableDictionary * ext;

+ (TCData *) createDefault;
+ (TCData *) createDefaultWithSLSConfig: (SLSConfig *) config;
+ (NSString *) fillWithDashIfEmpty: (NSString *) content;
- (NSDictionary *) toDictionary;
@end

NS_ASSUME_NONNULL_END
