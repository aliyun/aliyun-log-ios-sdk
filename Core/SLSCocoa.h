//
//  SLSCocoa.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSCredentials.h"
#import "SLSConfiguration.h"
#import "SLSUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSCocoa : NSObject
+ (instancetype) sharedInstance;
- (BOOL) initialize: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration;
- (void) setCredentials: (SLSCredentials *) credentials;
- (void) setUserInfo: (SLSUserInfo *) userInfo;

@end

@interface SLSSpanProviderDelegate : NSObject<SLSSpanProviderProtocol>

+ (instancetype) provider: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials;

@end

NS_ASSUME_NONNULL_END
