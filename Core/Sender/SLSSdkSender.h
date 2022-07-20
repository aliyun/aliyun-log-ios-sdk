//
//  SLSSdkSender.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSNoOpSender.h"
#import "SLSSpanProcessorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSSdkSender : SLSNoOpSender<SLSSpanProcessorProtocol>
+ (instancetype) sender;
@end

NS_ASSUME_NONNULL_END
