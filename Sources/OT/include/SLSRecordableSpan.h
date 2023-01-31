//
//  SLSRecordableSpan.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSSpan.h"
#import "SLSSpanProcessorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSRecordableSpan : SLSSpan

- (instancetype) initWithSpanProcessor: (id<SLSSpanProcessorProtocol>) processor;

@end

NS_ASSUME_NONNULL_END
