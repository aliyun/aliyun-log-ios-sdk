//
//  SLSSdkSender.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSNoOpSender.h"
#import "SLSSpanProcessorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSSdkSender : SLSNoOpSender<SLSSpanProcessorProtocol>
+ (instancetype) sender;

- (NSString *) provideLogFileName: (SLSCredentials *) credentials;
- (NSString *) provideEndpoint: (SLSCredentials *) credentials;
- (NSString *) provideProjectName: (SLSCredentials *) credentials;
- (NSString *) provideLogstoreName: (SLSCredentials *) credentials;
- (NSString *) provideAccessKeyId: (SLSCredentials *) credentials;
- (NSString *) provideAccessKeySecret: (SLSCredentials *) credentials;
- (NSString *) provideSecurityToken: (SLSCredentials *) credentials;

@end

NS_ASSUME_NONNULL_END
