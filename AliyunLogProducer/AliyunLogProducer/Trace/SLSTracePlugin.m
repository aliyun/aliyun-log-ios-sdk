//
//  SLSTracePlugin.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/8/17.
//  Copyright © 2021 lichao. All rights reserved.
//

#import "SLSTracePlugin.h"
#import "OpenTelemetrySdk/OpenTelemetrySdk-Swift.h"

@interface SLSTracePlugin ()
@property(nonatomic, strong) SLSSpanExporter *exporter;

@end

@implementation SLSTracePlugin

- (NSString *)name {
    return @"SLSTracePlugin";
}

- (BOOL)initWithSLSConfig:(SLSConfig *)config {
    _exporter = [[SLSSpanExporter alloc] init];
    [_exporter resetProject:[config endpoint] project:[config pluginLogproject] logstore:[config pluginLogstore]];
    [_exporter resetSecurityToken:[config accessKeyId] secret:[config accessKeySecret] token:[config securityToken]];
    
    TelemetrySDK *sdk = [TelemetrySDK instance];
    [sdk addSpanProcessor:_exporter];
    return YES;
}

- (void)resetProject:(NSString *)endpoint project:(NSString *)project logstore:(NSString *)logstore {
    [_exporter resetProject:endpoint project:project logstore:logstore];
}

- (void)resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    [_exporter resetSecurityToken:accessKeyId secret:accessKeySecret token:token];
}

- (void)updateConfig:(SLSConfig *)config {
    
}

@end
