//
//  SLSConfiguration.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSUserInfo.h"
#if __has_include("AliyunLogOT/AliyunLogOT.h")
#import "AliyunLogOT/AliyunLogOT.h"
#else
#import "AliyunLogOT.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SLSConfiguration : NSObject
@property(atomic, assign) BOOL enableCrashReporter;
@property(atomic, assign) BOOL enableBlockDetection;
@property(atomic, assign) BOOL enableNetworkDiagnosis;
@property(atomic, assign) BOOL enableTrace;
@property(atomic, assign) BOOL enableInstrumentNSURLSession;

@property(atomic, assign) BOOL debuggable;

@property(nonatomic, copy) NSString *env;

@property(nonatomic, strong, readonly) id<SLSSpanProcessorProtocol> spanProcessor;
@property(nonatomic, strong) id<SLSSpanProviderProtocol> spanProvider;

@property(nonatomic, copy) SLSUserInfo *userInfo;

- (instancetype) initWithProcessor: (id<SLSSpanProcessorProtocol>) processor;

@end

NS_ASSUME_NONNULL_END
