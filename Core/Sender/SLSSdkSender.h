//
//  SLSSdkSender.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSNoOpSender.h"
#if __has_include("AliyunLogOT/SLSSpanProcessorProtocol.h")
#import "AliyunLogOT/SLSSpanProcessorProtocol.h"
#else
#import "SLSSpanProcessorProtocol.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SLSSdkSender : SLSNoOpSender<SLSSpanProcessorProtocol>
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

@end

NS_ASSUME_NONNULL_END
