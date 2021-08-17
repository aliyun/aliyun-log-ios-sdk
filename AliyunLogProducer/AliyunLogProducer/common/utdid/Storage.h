//
//  Storage.h
//  AliyunLogCommon
//
//  Created by gordon on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Storage : NSObject
+ (void) setUtdid: (NSString *)utdid;
+ (NSString *) getUtdid;
@end

NS_ASSUME_NONNULL_END
