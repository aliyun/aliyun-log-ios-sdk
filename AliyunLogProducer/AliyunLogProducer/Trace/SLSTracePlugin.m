//
//  SLSTracePlugin.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/8/17.
//  Copyright © 2021 lichao. All rights reserved.
//

#import <mach-o/arch.h>
#import "SLSTracePlugin.h"
#import "OpenTelemetrySdk/OpenTelemetrySdk-Swift.h"
#import "Utdid.h"
#import "SLSDeviceUtils.h"
#import "HttpConfigProxy.h"

@interface SLSTracePlugin ()
@property(nonatomic, strong) SLSSpanExporter *exporter;

@end

@implementation SLSTracePlugin

- (NSString *)name {
    return @"trace";
}

- (BOOL)initWithSLSConfig:(SLSConfig *)config {
    _exporter = [[SLSSpanExporter alloc] init];
    [_exporter resetProject:[config endpoint] project:[config pluginLogproject] logstore:[config pluginLogstore]];
    [_exporter resetSecurityToken:[config accessKeyId] secret:[config accessKeySecret] token:[config securityToken]];
    
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    TelemetrySDK *sdk = [TelemetrySDK instance];
    TelemetryResource *resouce = [[TelemetryResource alloc] initWithAttributes:@{
        @"telemetry.sdk.language": [[TelemetryAttributeValue alloc] initWithStringValue:@"Swift"],
        @"service.name": [[TelemetryAttributeValue alloc] initWithStringValue:@"iOS"],
        
        @"device.id": [[TelemetryAttributeValue alloc] initWithStringValue:[Utdid getUtdid]],
        @"device.model.identifier": [[TelemetryAttributeValue alloc] initWithStringValue:[SLSDeviceUtils getDeviceModelIdentifier]],
        @"device.model.name": [[TelemetryAttributeValue alloc] initWithStringValue:[SLSDeviceUtils getDeviceModel]],
        
        @"os.type": [[TelemetryAttributeValue alloc] initWithStringValue:@"darwin"],
        @"os.description": [[TelemetryAttributeValue alloc] initWithStringValue:[NSString stringWithFormat:@"%@ %@", systemName, systemVersion]],
        @"os.version": [[TelemetryAttributeValue alloc] initWithStringValue:systemVersion],
//        @"os.sdk": [[TelemetryAttributeValue alloc] initWithStringValue:@"iOS"],
        
        @"host.name": [[TelemetryAttributeValue alloc] initWithStringValue:@"iOS"],
        @"host.id": [[TelemetryAttributeValue alloc] initWithStringValue:[Utdid getUtdid]],
        @"host.type": [[TelemetryAttributeValue alloc] initWithStringValue:systemName],
        @"host.arch": [[TelemetryAttributeValue alloc] initWithStringValue:[SLSDeviceUtils getCPUArch]],
        
        @"sls.sdk.language": [[TelemetryAttributeValue alloc] initWithStringValue:@"Objective-C"],
        @"sls.sdk.name": [[TelemetryAttributeValue alloc] initWithStringValue:@"tracesdk"],
        @"sls.sdk.version": [[TelemetryAttributeValue alloc] initWithStringValue:[[HttpConfigProxy sharedInstance] getVersion]],
    }];
    [sdk updateActiveResource:[[sdk activeResource] mergingWithOther:resouce]];
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
