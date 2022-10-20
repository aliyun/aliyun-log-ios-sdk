//
//  SLSSdkSender.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSNoOpSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSSdkSender : SLSNoOpSender
{
@protected CredentialsCallback _callback;
}
+ (instancetype) sender;

- (NSString *) provideFeatureName;
- (NSString *) provideLogFileName: (SLSCredentials *) credentials;
- (NSString *) provideEndpoint: (SLSCredentials *) credentials;
- (NSString *) provideProjectName: (SLSCredentials *) credentials;
- (NSString *) provideLogstoreName: (SLSCredentials *) credentials;
- (NSString *) provideAccessKeyId: (SLSCredentials *) credentials;
- (NSString *) provideAccessKeySecret: (SLSCredentials *) credentials;
- (NSString *) provideSecurityToken: (SLSCredentials *) credentials;
- (void) provideLogProducerConfig: (id) config;

@end

NS_ASSUME_NONNULL_END
