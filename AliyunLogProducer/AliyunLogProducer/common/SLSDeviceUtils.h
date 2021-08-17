//
//  SLSDeviceUtils.h
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSDeviceUtils : NSObject

+ (NSString *) getDeviceModel;
+ (NSString *) isJailBreak;
+ (NSString *) getResolution;
+ (NSString *) getCarrier;
+ (NSString *) getNetworkTypeName;
+ (NSString *) getNetworkSubTypeName;
@end

NS_ASSUME_NONNULL_END
