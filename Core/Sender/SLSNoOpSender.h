//
//  SLSNoOpSender.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSSenderProtocol.h"
#import "SLSSpanProcessorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSNoOpSender : NSObject<SLSSenderProtocol, SLSSpanProcessorProtocol>

@end

NS_ASSUME_NONNULL_END
