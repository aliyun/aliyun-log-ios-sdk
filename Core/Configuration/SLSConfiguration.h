//
//  SLSConfiguration.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSUserInfo.h"
#import "SLSSpanProcessorProtocol.h"
#import "SLSSpanProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSConfiguration : NSObject
@property(atomic, assign) bool enableCrashReporter;
@property(atomic, assign) bool enableBlockDetection;

@property(nonatomic, copy) NSString *env;

@property(nonatomic, strong, readonly) id<SLSSpanProcessorProtocol> spanProcessor;
@property(nonatomic, strong) id<SLSSpanProviderProtocol> spanProvider;

@property(nonatomic, copy) SLSUserInfo *userInfo;

- (instancetype) initWithProcessor: (id<SLSSpanProcessorProtocol>) processor;

@end

NS_ASSUME_NONNULL_END
