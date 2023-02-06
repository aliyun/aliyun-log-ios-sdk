//
//  SLSCredentials.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSCredentials.h"

#pragma mark - SLSCredentials
@implementation SLSCredentials
+ (instancetype) credentials {
    return [[SLSCredentials alloc] init];
}

- (SLSNetworkDiagnosisCredentials *) createNetworkDiagnosisCredentials {
    _networkDiagnosisCredentials = [SLSNetworkDiagnosisCredentials credentials:self];
    return _networkDiagnosisCredentials;
}
- (SLSTraceCredentials *) createTraceCredentials {
    _traceCredentials = [SLSTraceCredentials credentials:self];
    return _traceCredentials;
}
@end

#pragma mark - SLSLogstoreCredentials
@implementation SLSLogstoreCredentials

- (instancetype) initWithCredentials: (SLSCredentials *) credentials {
    if (self = [super init]) {
        self.instanceId = credentials.instanceId;
        self.endpoint = credentials.endpoint;
        self.project = credentials.project;
        
        self.accessKeyId = credentials.accessKeyId;
        self.accessKeySecret = credentials.accessKeySecret;
        self.securityToken = credentials.securityToken;
    }
    return self;
}

+ (instancetype) credentials:(SLSCredentials *)credentials {
    return [[SLSLogstoreCredentials alloc] initWithCredentials:credentials];
}

@end

#pragma mark - SLSNetworkDiagnosisCredentials

@implementation SLSNetworkDiagnosisCredentials

- (instancetype) initWithCredentials: (SLSCredentials *) credentials {
    if (self = [super initWithCredentials:credentials]) {
        _extension = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype) credentials: (SLSCredentials *) credentials{
    return [[SLSNetworkDiagnosisCredentials alloc] initWithCredentials: credentials];
}

- (void) putExtension: (NSString *) value forKey: (NSString *) key {
    if (key && value) {
        [self.extension setObject:value forKey:key];
    }
}
@end

#pragma mark - SLS Trace Credentials
@implementation SLSTraceCredentials
//- (instancetype)initWithCredentials:(SLSCredentials *)credentials {
//    if (self = [super initWithCredentials:credentials]) {
//        
//    }
//    return self;
//}

+ (instancetype)credentials:(SLSCredentials *)credentials {
    return [[SLSTraceCredentials alloc] initWithCredentials:credentials];
}

- (SLSLogsCredentials *) createLogsCredentials {
    _logsCredentials = [SLSLogsCredentials credentials:self];
    return _logsCredentials;
}
@end

#pragma mark - SLS Trace Logs Credetials
@implementation SLSLogsCredentials

+ (instancetype)credentials:(SLSCredentials *)credentials {
    return [[SLSLogsCredentials alloc] initWithCredentials:credentials];
}
@end
