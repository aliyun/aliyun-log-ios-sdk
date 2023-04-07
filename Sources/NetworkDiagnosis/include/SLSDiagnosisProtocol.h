//
// Copyright 2023 aliyun-sls Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
	

#import <Foundation/Foundation.h>

#import "AliNetworkDiagnosis/AliDns.h"
#import "AliNetworkDiagnosis/AliHttpPing.h"
#import "AliNetworkDiagnosis/AliMTR.h"
#import "AliNetworkDiagnosis/AliPing.h"
#import "AliNetworkDiagnosis/AliTcpPing.h"
#import "AliNetworkDiagnosis/AliNetworkDiagnosis.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SLSDiagnosisProtocol <NSObject>
- (void)registerDelegate:(id<AliNetworkDiagnosisDelegate>)delegate;
- (void)init:(NSString*)secretKey deviceId:(NSString*)deviceId siteId:(NSString*)siteId extension:(NSDictionary*)extension;
- (void)setPolicyDomain:(NSString*)domain;
- (void)refreshSecretKey:(NSString*)secretKey;
- (void)executeOncePolicy:(NSString*)policy;
- (void)disableExNetInfo;
- (void)enableDebug:(BOOL)debug;
- (void)updateExtension:(NSDictionary*)extension;
- (void)registerHttpCredentialDelegate:(id<AliHttpCredentialDelegate>)delegate;

- (void) dns: (AliDnsConfig *)config;
- (void) http: (AliHttpPingConfig *)config;
- (void) mtr: (AliMTRConfig *)config;
- (void) ping: (AliPingConfig *)config;
- (void) tcpPing: (AliTcpPingConfig *)config;
@end

NS_ASSUME_NONNULL_END
