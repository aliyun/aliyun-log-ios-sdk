//
//  SLSSdkFeature.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSNoOpFeature.h"
#import "SLSSpanBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSSdkFeature : SLSNoOpFeature

- (SLSSpanBuilder *) newSpanBuilder: (NSString *) spanName;

- (void) onInitializeSender: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration;
- (void) onInitialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration;
- (void) onPostInitialize;

- (void) onStop;
- (void) onPostStop;


@end

NS_ASSUME_NONNULL_END
