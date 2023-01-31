//
//  SLSCredentials.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CredentialsCallback)(NSString *feature, NSString *result);

@class SLSNetworkDiagnosisCredentials;
@class SLSTraceCredentials;

@interface SLSCredentials : NSObject
@property(nonatomic, strong) NSString *instanceId;
@property(nonatomic, strong) NSString *endpoint;
@property(nonatomic, strong) NSString *project;

@property(nonatomic, strong) NSString *accessKeyId;
@property(nonatomic, strong) NSString *accessKeySecret;
@property(nonatomic, strong) NSString *securityToken;

@property(nonatomic, strong) SLSNetworkDiagnosisCredentials *networkDiagnosisCredentials;
@property(nonatomic, strong) SLSTraceCredentials *traceCredentials;

+ (instancetype) credentials;

- (SLSNetworkDiagnosisCredentials *) createNetworkDiagnosisCredentials;
- (SLSTraceCredentials *) createTraceCredentials;

@end

@interface SLSLogstoreCredentials : SLSCredentials
@property(nonatomic, strong) NSString *logstore;

- (instancetype) initWithCredentials: (SLSCredentials *) credentials;
+ (instancetype) credentials: (SLSCredentials *) credentials;

@end

@interface SLSNetworkDiagnosisCredentials : SLSLogstoreCredentials

@property(nonatomic, strong) NSString *secretKey;
@property(nonatomic, strong) NSString *siteId;
@property(nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSString *> *extension;

- (instancetype) initWithCredentials: (SLSCredentials *) credentials;
+ (instancetype) credentials: (SLSCredentials *) credentials;

- (void) putExtension: (NSString *) value forKey: (NSString *) key;

@end

@interface SLSTraceCredentials : SLSLogstoreCredentials

@end

NS_ASSUME_NONNULL_END
