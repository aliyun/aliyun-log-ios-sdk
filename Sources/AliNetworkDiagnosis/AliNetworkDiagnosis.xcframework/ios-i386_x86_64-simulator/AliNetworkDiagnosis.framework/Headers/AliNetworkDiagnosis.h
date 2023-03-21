//
//  AliNetworkDiagnosis.h
//  AliNetworkDiagnosis
//
//  Created by colin on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <AliNetworkDiagnosis/AliProtocols.h>
#import <AliNetworkDiagnosis/AliDns.h>
#import <AliNetworkDiagnosis/AliMTR.h>
#import <AliNetworkDiagnosis/AliPing.h>
#import <AliNetworkDiagnosis/AliTcpPing.h>
#import <AliNetworkDiagnosis/AliHttpPing.h>

typedef NS_ENUM(NSUInteger, AliNetDiagLogLevel){
    AliNetDiagLogLevelUpload = 10, // 上报SLS+写文件
    AliNetDiagLogLevelFile   = 11, // 写文件
    AliNetDiagLogLevelError  = 12, // 写文件+打印控制台
    AliNetDiagLogLevelWarn   = 13, // 业务侧选择性打印到控制台
    AliNetDiagLogLevelInfo   = 14, // 业务侧选择性打印到控制台
    AliNetDiagLogLevelDebug  = 15  // 业务侧选择性打印到控制台

};


@protocol AliNetworkDiagnosisDelegate <NSObject>

- (void)report:(NSString*)content level:(AliNetDiagLogLevel)level context:(id)context;

- (void)log:(NSString*)content level:(AliNetDiagLogLevel)level context:(id)context;

@end

@interface AliNetworkDiagnosis : NSObject
// objectType: 52001
+(void)handlePushMessage:(NSString*)message type:(NSString*)type context:(id)context;

+(void)registerDelegate:(id<AliNetworkDiagnosisDelegate>)delegate;

//+(void)init:(NSString*)appKey;
//+(void)init:(NSString*)appKey deviceId:(NSString*)deviceId withSiteId:(NSString*)siteId;

+(void)init:(NSString*)secretKey deviceId:(NSString*)deviceId siteId:(NSString*)siteId extension:(NSDictionary*)extension;
+(void)setPolicyDomain:(NSString*)domain;
+(void)refreshSecretKey:(NSString*)secretKey;
+(void)executeOncePolicy:(NSString*)policy;
+(void)disableExNetInfo;
+(void)enableDebug:(BOOL)debug;
+(void)updateExtension:(NSDictionary*)extension;
+(void)registerHttpCredentialDelegate:(id<AliHttpCredentialDelegate>)delegate;
@end

