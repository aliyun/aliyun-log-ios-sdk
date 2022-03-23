//
//  SLSNetworkDiagnosis.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/27.
//

#import <Foundation/Foundation.h>
#import "SLSConfig.h"
#import "SLSNetworkDiagnosisResult.h"
#import "ISender.h"

#import <AliyunLogProducer/AliyunLogProducer.h>
#import "SLSNetworkDiagnosisResult.h"
#import "SLSNetPolicyBuilder.h"
#import <AliNetworkDiagnosis/AliPing.h>
#import <AliNetworkDiagnosis/AliHttpPing.h>
#import <AliNetworkDiagnosis/AliMTR.h>
#import <AliNetworkDiagnosis/AliTcpPing.h>
#import <AliNetworkDiagnosis/AliNetworkDiagnosis.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SLSNetworkDiagnosisCallBack)(SLSNetworkDiagnosisResult *result);
typedef void (^SLSNetworkDiagnosisCallBack2)(SLSNetworkDiagnosisResult *result);

@interface SLSNetworkDiagnosis : NSObject<AliNetworkDiagnosisDelegate>

+ (instancetype) sharedInstance;

- (void) initWithConfig: (SLSConfig *)config sender: (ISender *)sender;

- (void) updateConfig: (SLSConfig *)confg;

- (void) registerPolicy: (NSString *)policy;

- (void) registerPolicyWithBuilder: (SLSNetPolicyBuilder *) builder;

- (void) registerCallback: (SLSNetworkDiagnosisCallBack2) callback;

- (void) removeCallback: (SLSNetworkDiagnosisCallBack2) callback;

- (void) clearCallback;

- (void) ping: (NSString *) domain;

- (void) ping: (NSString *) domain callback: (SLSNetworkDiagnosisCallBack) callback;

- (void) ping: (NSString *) domain size:(int) size callback: (SLSNetworkDiagnosisCallBack) callback;

- (void) tcpPing: (NSString *) host port: (int) port;

- (void) tcpPing: (NSString *) host port: (int) port callback: (SLSNetworkDiagnosisCallBack) callback;

- (void) tcpPing: (NSString *) host port: (int) port count: (int) count callback: (SLSNetworkDiagnosisCallBack) callback;

- (void) mtr: (NSString *) host;

- (void) mtr: (NSString *) host callback: (SLSNetworkDiagnosisCallBack) callback;

- (void) mtr: (NSString *) host maxTtl: (int) ttl callback: (SLSNetworkDiagnosisCallBack) callback;

- (void) httpPing: (NSString *)domain;

- (void) httpPing: (NSString *)domain callback: (SLSNetworkDiagnosisCallBack) callback;

@end

NS_ASSUME_NONNULL_END
