//
//  SLSConfig.h
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSConfig : NSObject
@property(nonatomic, assign, getter=debuggable) BOOL debuggable;
@property(nonatomic, strong) NSString *appVersion;
@property(nonatomic, strong) NSString *appName;

@property(nonatomic, strong) NSString * endpoint;
@property(nonatomic, strong) NSString * accessKeyId;
@property(nonatomic, strong) NSString * accessKeySecret;
@property(nonatomic, strong) NSString * securityToken;

@property(nonatomic, strong) NSString * pluginAppId;
@property(nonatomic, strong) NSString * pluginLogproject;

@property(nonatomic, strong) NSString * channel;
@property(nonatomic, strong) NSString * channelName;
@property(nonatomic, strong) NSString * userNick;
@property(nonatomic, strong) NSString * longLoginNick;
@property(nonatomic, strong) NSString * userId;
@property(nonatomic, strong) NSString * longLoginUserId;
@property(nonatomic, strong) NSString * loginType;
@property(nonatomic, strong, readonly) NSMutableDictionary * ext;

- (void) addCustomWithKey: (nullable NSString *)key andValue: (nullable NSString *)value;
@end

NS_ASSUME_NONNULL_END
