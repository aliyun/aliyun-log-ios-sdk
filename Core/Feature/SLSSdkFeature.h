//
//  SLSSdkFeature.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSNoOpFeature.h"
#if __has_include("AliyunLogOT/SLSSpanBuilder.h")
#import "AliyunLogOT/SLSSpanBuilder.h"
#else
#import "SLSSpanBuilder.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SLSSdkFeature : SLSNoOpFeature
{
    @protected CredentialsCallback _callback;
}
@property(nonatomic, strong, readonly) SLSConfiguration *configuration;

- (SLSSpanBuilder *) newSpanBuilder: (NSString *)spanName;
- (SLSSpanBuilder *) newSpanBuilder: (NSString *)spanName provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor;

- (void) onInitializeSender: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration;
- (void) onInitialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration;
- (void) onPostInitialize;

- (void) onStop;
- (void) onPostStop;


@end

NS_ASSUME_NONNULL_END
