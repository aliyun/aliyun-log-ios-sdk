//
//  Unity4SLSiOS.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/24.
//  Copyright © 2022 com.aysls.ios. All rights reserved.
//

#import "Unity4SLSiOS.h"
#import "SLSCocoa.h"

#pragma mark - Interface for Unity bridge

#ifdef __cplusplus
extern "C"{
#endif
    
    static SLSUserInfo *userInfo;
    
    SLSCredentials* createCredentials(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken) {
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
        return credentials;
    }
    
    void _InitSLS(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken) {
        SLSCredentials *credentials = createCredentials(instanceId, endpoint, project, accesskeyId, accessKeySecret, securityToken);
        
        [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
            configuration.enableCrashReporter = YES;
        }];
    }
    
    void _SetLogLevel(int level) {
        //        [SLSCocoa sharedInstance]
    }
    
    void _SetCredentials(const char * instanceId, const char * endpoint, const char * project, const char * accesskeyId, const char * accessKeySecret, const char * securityToken) {
        SLSCredentials *credentials = createCredentials(instanceId, endpoint, project, accesskeyId, accessKeySecret, securityToken);
        [[SLSCocoa sharedInstance] setCredentials:credentials];
    }
    
    void _SetUserInfo(const char * uid, const char * channel) {
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
    
    void _SetExtraOfExt(const char * extKey, const char * extValue) {
        if (!userInfo) {
            return;
        }
        
        if (!extKey || !extValue) {
            return;
        }
        
        [userInfo addExt:[NSString stringWithUTF8String:extValue] key:[NSString stringWithUTF8String:extKey]];
        [[SLSCocoa sharedInstance] setUserInfo:userInfo];
    }
    
    void _SetExtra(const char * key, const char * value) {
        if (!key || !value) {
            return;
        }
        
        [[SLSCocoa sharedInstance] setExtra:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
    }
    
    void _RemoveExtra(const char * key) {
        if (!key) {
            return;
        }
        
        [[SLSCocoa sharedInstance] removeExtra:[NSString stringWithUTF8String:key]];
    }
    
    void _ClearExtra(void) {
        [[SLSCocoa sharedInstance] clearExtras];
    }
    
#ifdef __cplusplus
} // extern "C"
#endif

#pragma mark -
