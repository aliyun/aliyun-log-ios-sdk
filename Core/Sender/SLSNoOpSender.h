//
//  SLSNoOpSender.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSSenderProtocol.h"
#if __has_include("AliyunLogOT/SLSSpanProcessorProtocol.h")
#import "AliyunLogOT/SLSSpanProcessorProtocol.h"
#else
#import "SLSSpanProcessorProtocol.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SLSNoOpSender : NSObject<SLSSenderProtocol, SLSSpanProcessorProtocol>

@end

NS_ASSUME_NONNULL_END
