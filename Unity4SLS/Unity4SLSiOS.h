//
//  Unity4SLSiOS.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/24.
//  Copyright © 2022 com.aysls.ios. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Interface for Unity bridge

#ifdef __cplusplus
extern "C"{
#endif
typedef void *UserInfo;
typedef void *Dictionary;
typedef void (*cs_sls_callback)(const char*, const char*);

void _SLS_InitSLS(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken);

void _SLS_RegisterCredentialsCallback(cs_sls_callback callback);

void _SLS_SetLogLevel(int level);

void _SLS_SetCredentials(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken);

void _SLS_SetUserInfo(const char * uid, const char * channel);

void _SLS_SetExtraOfExt(const char * extKey, const char * extValue);

void _SLS_SetExtra(const char * key, const char * value);

void _SLS_RemoveExtra(const char * key);

void _SLS_ClearExtra(void);

void _SLS_ReportError(const char * type, const char * message, const char * stacktrace);

void _SLS_ReportLuaError(const char * message, const char * stacktrace);

void _SLS_ReportCSharpError(const char * message, const char * stacktrace);

const char* _SLS_HelloFromiOS(void);
    
#ifdef __cplusplus
} // extern "C"
#endif

#pragma mark -
