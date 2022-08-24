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

void _InitSLS(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken);

void _SetLogLevel(int level);

void _SetCredentials(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken);

void _SetUserInfo(const char * uid, const char * channel);

void _SetExtraOfExt(const char * extKey, const char * extValue);

void _SetExtra(const char * key, const char * value);

void _RemoveExtra(const char * key);

void _ClearExtra(void);
    
#ifdef __cplusplus
} // extern "C"
#endif

#pragma mark -
