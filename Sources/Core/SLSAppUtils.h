//
//  SLSAppUtils.h
//  AliyunLogCore
//
//  Created by gordon on 2022/4/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSAppUtils : NSObject
@property(atomic, assign) long bootTime;
@property(atomic, assign) BOOL coldStart;
@property(atomic, assign) BOOL foreground;

+ (instancetype) sharedInstance;


@end

NS_ASSUME_NONNULL_END
