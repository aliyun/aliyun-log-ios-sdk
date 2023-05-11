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
	

#import "SLSIPA4Unity.h"
#import "SLSCocoa.h"
#import "SLSNetworkDiagnosis.h"

#pragma mark - Interface for Unity bridge

#ifdef __cplusplus
extern "C"{
#endif
    
    static SLSUserInfo *userInfo;
    
    SLSCredentials* createCredentials(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken, const char * secretKey, const char * siteId) {
        SLSCredentials *credentials = [SLSCredentials credentials];
        if (instanceId) {
            credentials.instanceId = [NSString stringWithUTF8String:instanceId];
        }
        if (endpoint) {
            credentials.endpoint = [NSString stringWithUTF8String:endpoint];
        }
        if (project) {
            credentials.project = [NSString stringWithUTF8String:project];
        }
        if (accesskeyId) {
            credentials.accessKeyId = [NSString stringWithUTF8String:accesskeyId];
        }
        if (accessKeySecret) {
            credentials.accessKeySecret = [NSString stringWithUTF8String:accessKeySecret];
        }
        if (securityToken) {
            credentials.securityToken = [NSString stringWithUTF8String:securityToken];
        }
        
        SLSNetworkDiagnosisCredentials *networkCredentials = [credentials createNetworkDiagnosisCredentials];
        if (secretKey) {
            networkCredentials.secretKey = [NSString stringWithUTF8String:secretKey];
        }
        if (siteId) {
            networkCredentials.siteId = [NSString stringWithUTF8String:siteId];
        }
        
        return credentials;
    }
    
    void _SLS_InitSLS(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken, const char * secretKey, const char * siteId) {
        SLSCredentials *credentials = createCredentials(instanceId, endpoint, project, accesskeyId, accessKeySecret, securityToken, secretKey, siteId);
        
        [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
            configuration.enableNetworkDiagnosis = YES;
        }];
    }
    
    void _SLS_RegisterCredentialsCallback(cs_sls_callback callback) {
        [[SLSCocoa sharedInstance] registerCredentialsCallback:^(NSString * _Nonnull feature, NSString * _Nonnull result) {
            if (callback) {
                callback(feature.UTF8String, result.UTF8String);
            }
        }];
    }
    
    void _SLS_SetLogLevel(int level) {
        //        [SLSCocoa sharedInstance]
    }
    
    void _SLS_SetCredentials(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken, const char * secretKey, const char * siteId) {
        SLSCredentials *credentials = createCredentials(instanceId, endpoint, project, accesskeyId, accessKeySecret, securityToken, secretKey, siteId);
        [[SLSCocoa sharedInstance] setCredentials:credentials];
    }
    
    void _SLS_SetUserInfo(const char * uid, const char * channel) {
        if (!userInfo) {
            userInfo = [[SLSUserInfo alloc] init];
        }
        if (uid) {
            userInfo.uid = [NSString stringWithUTF8String:uid];
        }
        if (channel) {
            userInfo.channel = [NSString stringWithUTF8String:channel];
        }
        
        [[SLSCocoa sharedInstance] setUserInfo: userInfo];
    }
    
    void _SLS_SetExtraOfExt(const char * extKey, const char * extValue) {
        if (!userInfo) {
            return;
        }
        
        if (!extKey || !extValue) {
            return;
        }
        
        [userInfo addExt:[NSString stringWithUTF8String:extValue] key:[NSString stringWithUTF8String:extKey]];
        [[SLSCocoa sharedInstance] setUserInfo:userInfo];
    }
    
    void _SLS_SetExtra(const char * key, const char * value) {
        if (!key || !value) {
            return;
        }
        
        [[SLSCocoa sharedInstance] setExtra:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
    }
    
    void _SLS_RemoveExtra(const char * key) {
        if (!key) {
            return;
        }
        
        [[SLSCocoa sharedInstance] removeExtra:[NSString stringWithUTF8String:key]];
    }
    
    void _SLS_ClearExtra(void) {
        [[SLSCocoa sharedInstance] clearExtras];
    }
    
    void call_response_callback(cs_sls_complete_callback callback, SLSResponse *response) {
        if (nil == response || nil == callback) {
            return;
        }
        
        const char * content = strdup(response.content.length > 0 ? response.content.UTF8String : "");
        const char * context = strdup(nil != response.context ? ((NSString *)response.context).length > 0 ? ((NSString *)response.context).UTF8String : "": "");
        const char * error = strdup(response.error.length > 0 ? response.error.UTF8String : "");
        
        int type = 0;
        if ([@"http" isEqualToString:response.type]) {
            type = 0;
        } else if ([@"ping" isEqualToString:response.type]) {
            type = 1;
        } else if ([@"tcpping" isEqualToString:response.type]) {
            type = 2;
        } else if ([@"mtr" isEqualToString:response.type]) {
            type = 3;
        } else if ([@"dns" isEqualToString:response.type]) {
            type = 4;
        }
        
        callback(type, content, context, error);
    }
    
    void _SLS_Ping(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, cs_sls_complete_callback callback) {
        SLSHttpRequest *request = [[SLSHttpRequest alloc] init];
        request.domain = [NSString stringWithUTF8String:domain];
        request.context = [NSString stringWithUTF8String:context];
        request.size = size;
        request.maxTimes = maxTimes;
        request.timeout = timeout;
        
        [[SLSNetworkDiagnosis sharedInstance] ping2:request callback:^(SLSResponse * _Nonnull response) {
            call_response_callback(callback, response);
        }];
    }

    void _SLS_TcpPing(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const int port, cs_sls_complete_callback callback) {
        SLSTcpPingRequest *request = [[SLSTcpPingRequest alloc] init];
        request.domain = [NSString stringWithUTF8String:domain];
        request.context = [NSString stringWithUTF8String:context];
        request.size = size;
        request.maxTimes = maxTimes;
        request.timeout = timeout;
        request.port = port;
        
        [[SLSNetworkDiagnosis sharedInstance] tcpPing2:request callback:^(SLSResponse * _Nonnull response) {
            call_response_callback(callback, response);
        }];
    }

    void _SLS_Dns(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const char * type, const char * nameServer, cs_sls_complete_callback callback) {
        SLSDnsRequest *request = [[SLSDnsRequest alloc] init];
        request.domain = [NSString stringWithUTF8String:domain];
        request.context = [NSString stringWithUTF8String:context];
        request.size = size;
        request.maxTimes = maxTimes;
        request.timeout = timeout;
        request.type = [NSString stringWithUTF8String:type];
        if (nil != nameServer) {
            request.nameServer = [NSString stringWithUTF8String:nameServer];
        }
        
        [[SLSNetworkDiagnosis sharedInstance] dns2:request callback:^(SLSResponse * _Nonnull response) {
            call_response_callback(callback, response);
        }];
    }

    void _SLS_Mtr(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const int maxTTL, const int maxPaths, cs_sls_complete_callback callback) {
        SLSMtrRequest *request = [[SLSMtrRequest alloc] init];
        request.domain = [NSString stringWithUTF8String:domain];
        request.context = [NSString stringWithUTF8String:context];
        request.size = size;
        request.maxTimes = maxTimes;
        request.timeout = timeout;
        request.maxTTL = maxTTL;
        request.maxPaths = maxPaths;
        
        [[SLSNetworkDiagnosis sharedInstance] mtr2:request callback:^(SLSResponse * _Nonnull response) {
            call_response_callback(callback, response);
        }];
    }

    void _SLS_Http(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const char *ip, const bool headerOnly, const int downloadBytesLimit, cs_sls_complete_callback callback) {
        SLSHttpRequest *request = [[SLSHttpRequest alloc] init];
        request.domain = [NSString stringWithUTF8String:domain];
        request.context = [NSString stringWithUTF8String:context];
        request.size = size;
        request.maxTimes = maxTimes;
        request.timeout = timeout;
        if (nil != ip) {
            request.ip = [NSString stringWithUTF8String:ip];
        }
        request.headerOnly = headerOnly;
        request.downloadBytesLimit = downloadBytesLimit;
        
        [[SLSNetworkDiagnosis sharedInstance] http2:request callback:^(SLSResponse * _Nonnull response) {
            call_response_callback(callback, response);
        }];
    }
    
    
    void _SLS_DisableExNetworkInfo(void) {
        [[SLSNetworkDiagnosis sharedInstance] disableExNetworkInfo];
    }

    void _SLS_SetMultiplePortsDetect(const bool enable) {
        [[SLSNetworkDiagnosis sharedInstance] setMultiplePortsDetect:enable];
    }

    void _SLS_SetPolicyDomain(const char *domain) {
        [[SLSNetworkDiagnosis sharedInstance] setPolicyDomain:(nil != domain ? ([NSString stringWithUTF8String:domain]) : @"")];
    }

    void _SLS_RegisterCallback(cs_sls_complete_callback callback) {
        [[SLSNetworkDiagnosis sharedInstance] registerCallback2:^(SLSResponse * _Nonnull response) {
            call_response_callback(callback, response);
        }];
    }

    void _SLS_UpdateExtensions(const char *key, const char *value) {
        if (nil == key || nil == value) {
            return;
        }
        
        [[SLSNetworkDiagnosis sharedInstance] updateExtensions:@{[NSString stringWithUTF8String:key]: [NSString stringWithUTF8String:value]}];
    }

    const char* _SLS_HelloFromiOS(void) {
        return @"hello from iOS.".UTF8String;
    }
    
#ifdef __cplusplus
} // extern "C"
#endif

#pragma mark -
