//
//  SLSCredentials.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSCredentials : NSObject
@property(nonatomic, strong) NSString *instanceId;
@property(nonatomic, strong) NSString *endpoint;
@property(nonatomic, strong) NSString *project;

@property(nonatomic, strong) NSString *accessKeyId;
@property(nonatomic, strong) NSString *accessKeySecret;
@property(nonatomic, strong) NSString *securityToken;

@end

NS_ASSUME_NONNULL_END
