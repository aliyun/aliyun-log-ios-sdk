//
//  SLSNetworkDiagnosisPlugin.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/27.
//

#import "SLSNetworkDiagnosisPlugin.h"
#import "SLSNetworkDataSender.h"
#import "SLSNetworkDiagnosis.h"

@implementation SLSNetworkDiagnosisPlugin


- (NSString *) name {
    return @"network_diagnosis";
}

- (BOOL) initWithSLSConfig: (SLSConfig *) config {
    SLSNetworkDataSender *sender = [[SLSNetworkDataSender alloc] init];
    [sender initWithSLSConfig:config];
    
    [[SLSNetworkDiagnosis sharedInstance] initWithConfig:config sender:sender];
    return YES;
}

- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    
}

- (void) resetProject: (NSString*)endpoint project: (NSString *)project logstore:(NSString *)logstore {
    
}

- (void) updateConfig: (SLSConfig *)config {
    
}

@end
