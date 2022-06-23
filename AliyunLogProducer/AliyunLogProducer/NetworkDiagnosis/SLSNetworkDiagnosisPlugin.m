//
//  SLSNetworkDiagnosisPlugin.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/27.
//

#import "SLSNetworkDiagnosisPlugin.h"
#import "SLSNetworkDataSender.h"
#import "SLSNetworkDiagnosis.h"

@interface SLSNetworkDiagnosisPlugin ()
@property(nonatomic, strong) ISender *sender;
@property(nonatomic, strong) SLSNetworkDiagnosis *networkDiagnosis;

@end

@implementation SLSNetworkDiagnosisPlugin


- (NSString *) name {
    return @"network_diagnosis";
}

- (BOOL) initWithSLSConfig: (SLSConfig *) config {
    _sender = [[SLSNetworkDataSender alloc] init];
    [_sender initWithSLSConfig:config];
    
    _networkDiagnosis = [SLSNetworkDiagnosis sharedInstance];
    [_networkDiagnosis initWithConfig:config sender:_sender];
    return YES;
}

- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    // ignore, network idagnosis use webtracking
}

- (void) resetProject: (NSString*)endpoint project: (NSString *)project logstore:(NSString *)logstore {
    // ignore, network idagnosis hardcode project info
}

- (void) updateConfig: (SLSConfig *)config {
    [_networkDiagnosis updateConfig:config];
}

@end
