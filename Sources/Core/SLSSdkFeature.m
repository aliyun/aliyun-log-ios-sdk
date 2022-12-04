//
//  SLSSdkFeature.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSSystemCapabilities.h"
#import "SLSSdkFeature.h"
#import "SLSUtils.h"
@import AliyunLogProducer;

@interface SLSSdkFeature ()

@property(atomic, assign) bool hasInitialize;

@end

@implementation SLSSdkFeature

- (NSString *)name {
    return @"";
}

- (NSString *)version {
    return [SLSUtils getSdkVersion];
}

- (SLSSpanBuilder *) newSpanBuilder: (NSString *)spanName provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor {
    return [[SLSSpanBuilder builder] initWithName:spanName provider:provider processor:processor];
}

- (SLSSpanBuilder *) newSpanBuilder: (NSString *) spanName {
    SLSSpanBuilder *builder = [self newSpanBuilder:spanName provider:_configuration.spanProvider processor:_configuration.spanProcessor];

#if SLS_HOST_MAC
    [builder setService:@"macOS"];
#elif SLS_HOST_TV
    [builder setService:@"tvOS"];
#else
    [builder setService:@"iOS"];
#endif
    
    return builder;
}

- (void) initialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    if (_hasInitialize) {
        return;
    }
    
    _configuration = configuration;
    
    [self onInitializeSender:credentials configuration:configuration];
    [self onInitialize:credentials configuration:configuration];
    _hasInitialize = YES;
    [self onPostInitialize];
    
}

- (void)stop {
    if (_hasInitialize) {
        
        [self onStop];
        _hasInitialize = NO;
        [self onPostStop];
    }
}

- (void) onInitializeSender: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    
}
- (void) onInitialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    
}
- (void) onPostInitialize {
    
}

- (void) onStop {
    
}
- (void) onPostStop {
    
}

- (void)setCallback:(CredentialsCallback)callback {
    _callback = callback;
}

@end
