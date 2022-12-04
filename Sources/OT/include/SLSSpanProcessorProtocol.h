//
//  SLSSpanProcessorProtocol.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSSpan.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SLSSpanProcessorProtocol <NSObject>
- (BOOL) onEnd: (SLSSpan *)span;
@end

NS_ASSUME_NONNULL_END
