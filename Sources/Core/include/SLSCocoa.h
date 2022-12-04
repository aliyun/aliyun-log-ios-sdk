//
//  SLSCocoa.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSCredentials.h"
#import "SLSConfiguration.h"
#import "SLSUserInfo.h"

NS_ASSUME_NONNULL_BEGIN
@class SLSExtraProvider;
@interface SLSCocoa : NSObject
+ (instancetype) sharedInstance;
- (BOOL) initialize: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration;
- (void) setCredentials: (SLSCredentials *) credentials;
- (void) setUserInfo: (SLSUserInfo *) userInfo;
- (void) registerCredentialsCallback: (nullable CredentialsCallback) callback;
- (void) setExtra: (NSString *)key value: (NSString *)value;
- (void) setExtra: (NSString *)key dictValue: (NSDictionary<NSString *, NSString *> *)value;
- (void) removeExtra: (NSString *)key;
- (void) clearExtras;

@end

@interface SLSSpanProviderDelegate : NSObject<SLSSpanProviderProtocol>

+ (instancetype) provider: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials extraProvider: (SLSExtraProvider *)extraProvider;

@end

@interface SLSExtraProvider : NSObject
- (void) setExtra: (NSString *)key value: (NSString *)value;
- (void) setExtra: (NSString *)key dictValue: (NSDictionary<NSString *, NSString *> *)value;
- (void) removeExtra: (NSString *)key;
- (void) clearExtras;
- (NSDictionary<NSString *, NSString *> *) getExtras;
@end

NS_ASSUME_NONNULL_END
