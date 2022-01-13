//
//  SLSSpanExporter.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/8/17.
//  Copyright © 2021 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenTelemetrySdk/OpenTelemetrySdk-Swift.h"
#import "ISender.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSSpanExporter : ISender<TelemetrySpanExporter>

@end

NS_ASSUME_NONNULL_END
