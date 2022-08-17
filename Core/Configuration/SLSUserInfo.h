//
//  SLSUserInfo.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSUserInfo : NSObject
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *channel;

- (void) addExt: (NSString *) value key: (NSString *) key;

@end

NS_ASSUME_NONNULL_END
