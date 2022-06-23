//
//  SLSAdapter.h
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/19.
//

#import <Foundation/Foundation.h>
#import "SLSConfig.h"
#import "AliyunLogProducer.h"
#import "IPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSAdapter : NSObject
{
    @private
    NSString * _channel;
    NSString * _channelName;
    NSString * _userNick;
    NSString * _longLoginNick;
    NSString * _loginType;
    NSMutableArray * _plugins;
}

+ (instancetype) sharedInstance;
- (void) setChannel: (NSString *)channel;
- (void) setChannelName: (NSString *)channelName;
- (void) setUserNick: (NSString *)userNick;
- (void) setLongLoginNick: (NSString *)longLoginNick;
- (void) setLoginType: (NSString *)loginType;

- (BOOL) initWithSLSConfig: (SLSConfig *) config;
- (BOOL) addPlugin: (IPlugin *) plugin;
- (void) removePlugin: (IPlugin *) plugin;
- (void) resetSecurityToken: (nullable NSString *)accessKeyId secret: (nullable NSString *)accessKeySecret token: (nullable NSString *) token;
- (void) resetProject: (nullable NSString *)endpoint project: (nullable NSString *)project logstore: (nullable NSString *)logstore;
- (void) updateConfig: (SLSConfig *)config;
- (void) reportCustomEvent: (NSString *) eventId properties:(nonnull NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
