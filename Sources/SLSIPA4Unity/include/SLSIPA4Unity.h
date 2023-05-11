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

#pragma mark - Interface for Unity bridge

#ifdef __cplusplus
extern "C"{
#endif
typedef void *UserInfo;
typedef void *Dictionary;
typedef void (*cs_sls_callback)(const char*, const char*);
typedef void (*cs_sls_complete_callback)(const int type, const char * content, const char * context, const char * error);

void _SLS_InitSLS(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken, const char * secretKey, const char * siteId);

void _SLS_RegisterCredentialsCallback(cs_sls_callback callback);

void _SLS_SetLogLevel(int level);

void _SLS_SetCredentials(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken, const char * secretKey, const char * siteId);

void _SLS_SetUserInfo(const char * uid, const char * channel);

void _SLS_SetExtraOfExt(const char * extKey, const char * extValue);

void _SLS_SetExtra(const char * key, const char * value);

void _SLS_RemoveExtra(const char * key);

void _SLS_ClearExtra(void);

void _SLS_Ping(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, cs_sls_complete_callback callback);

void _SLS_TcpPing(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const int port, cs_sls_complete_callback callback);

void _SLS_Dns(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const char * type, const char * nameServer, cs_sls_complete_callback callback);

void _SLS_Mtr(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const int maxTTL, const int maxPaths, cs_sls_complete_callback callback);

void _SLS_Http(const char * domain, const char * context, const int size, const int maxTimes, const int timeout, const char *ip, const bool headerOnly, const int downloadBytesLimit, cs_sls_complete_callback callback);

void _SLS_DisableExNetworkInfo(void);

void _SLS_SetMultiplePortsDetect(const bool enable);

void _SLS_SetPolicyDomain(const char *domain);

void _SLS_RegisterCallback(cs_sls_complete_callback callback);

void _SLS_UpdateExtensions(const char *key, const char *value);


const char* _SLS_HelloFromiOS(void);
    
#ifdef __cplusplus
} // extern "C"
#endif

#pragma mark -
