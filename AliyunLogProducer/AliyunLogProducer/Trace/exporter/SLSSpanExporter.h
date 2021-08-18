//
//  SLSSpanExporter.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/8/17.
//  Copyright © 2021 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AliyunLogProducer/AliyunLogProducer.h"
#import "OpenTelemetrySdk/OpenTelemetrySdk-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSSpanExporter : NSObject<TelemetrySpanExporter>
- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token;
- (void) resetProject: (NSString*)endpoint project: (NSString *)project logstore:(NSString *)logstore;
@end

NS_ASSUME_NONNULL_END
