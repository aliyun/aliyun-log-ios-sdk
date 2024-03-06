//
//  Utdid.h
//  AliyunLogCommon
//
//  Created by gordon on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSUtdid : NSObject

+ (NSString *) getUtdid;

+ (void) setUtdid: (NSString *) utdid;

@end

NS_ASSUME_NONNULL_END
