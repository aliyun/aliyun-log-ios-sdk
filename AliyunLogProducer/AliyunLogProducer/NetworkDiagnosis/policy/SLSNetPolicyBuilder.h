//
//  SLSNetPolicyBuilder.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/3/22.
//

#import <Foundation/Foundation.h>
#import "SLSNetPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@class SLSNetPolicyBuilder;

@interface SLSNetPolicyBuilder : NSObject

/// 策略是否开启，默认开启
/// @param enable true/false，true为开启
- (SLSNetPolicyBuilder *) setEnable: (BOOL) enable;

/// 设置业务类型，可不配置
/// @param type 业务名称
- (SLSNetPolicyBuilder *) setType: (NSString *) type;

/// 设置策略版本。注意：策略只要有更新，这个字段的值必须要变大。
/// @param version 版本号
- (SLSNetPolicyBuilder *) setVersion: (int) version;

/// 是否为周期性策略。false代表一次性策略，此时忽略灰度和白名单，下发到客户端都会执行
/// @param periodicity true/false，true为周期性策略，默认为true。
- (SLSNetPolicyBuilder *) setPeriodicity: (BOOL) periodicity;

/// 设置探测周期
/// @param internal 两次探测之间的时间间隔，单位为秒，默认为3分钟。
- (SLSNetPolicyBuilder *) setInternal: (int) internal;

/// 设置有效期
/// @param expiration 策略的有效期，unix时间戳表示法。默认为7天。
- (SLSNetPolicyBuilder *) setExpiration: (long) expiration;

/// 设置灰度比例
/// @param ratio 取值范围[0, 1000]。0表示全部不生效，1000表示全部生效。
- (SLSNetPolicyBuilder *) setRatio: (int) ratio;

/// 设置白名单，白名单的值需要通过 [Utdid getUtdid]方法获取。
/// @param whitelist 白名单列表
- (SLSNetPolicyBuilder *) setWhiteList: (NSArray<NSString*> *) whitelist;

/// 增加一组白名单
/// @param whitelist 白名单列表
- (SLSNetPolicyBuilder *) addWhiteList: (NSArray<NSString*> *) whitelist;

/// 设置生效的探测方式，探测方式当前支持：mtr、ping、tcpping、http。
/// @param methods 探测方式列表
- (SLSNetPolicyBuilder *) setMethods: (NSArray<NSString*> *) methods;

/// 启用MTR方式探测
- (SLSNetPolicyBuilder *) setEnableMtrMethod;

/// 启用PING方式探测
- (SLSNetPolicyBuilder *) setEnablePingMethod;

/// 启用TcpPing方式探测
- (SLSNetPolicyBuilder *) setEnableTcpPingMethod;

/// 启用Http方式探测
- (SLSNetPolicyBuilder *) setEnableHttpMethod;

/// 设置目的地信息
/// @param destination 目的地列表
- (SLSNetPolicyBuilder *) setDestination: (NSArray<SLSDestination*> *) destination;

/// 增加目的地信息
/// @param ips IP地址列表，可以为域名。如：10.10.0.2:443/80/8080，表示tcp探测时会同时探测443/80/8080这三个端口。
/// @param urls Url地址列表，仅当探测方式为http时生效
- (SLSNetPolicyBuilder *) addDestination: (NSArray<NSString*> *) ips urls: (NSArray<NSString*> *) urls;

/// 构建
- (SLSNetPolicy *) create;
@end

NS_ASSUME_NONNULL_END
