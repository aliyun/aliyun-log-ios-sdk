//
//  IdGenerator.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSIdGenerator : NSObject

+ (NSString *) generateTraceId;
+ (NSString *) generateSpanId;

@end

NS_ASSUME_NONNULL_END
