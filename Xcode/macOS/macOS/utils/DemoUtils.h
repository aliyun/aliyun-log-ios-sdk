//
//  DemoUtils.h
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoUtils : NSObject

@property(nonatomic, strong) NSString *endpoint;
@property(nonatomic, strong) NSString *project;
@property(nonatomic, strong) NSString *logstore;
@property(nonatomic, strong) NSString *accessKeyId;
@property(nonatomic, strong) NSString *accessKeySecret;
@property(nonatomic, strong) NSString *pluginAppId;

+ (instancetype) sharedInstance;


@end

NS_ASSUME_NONNULL_END
