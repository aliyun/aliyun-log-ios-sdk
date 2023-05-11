//
//  SLSSdkFeature.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSSdkFeature.h"
#import "SLSUtils.h"
#import "AliyunLogProducer.h"

@interface SLSSdkFeature ()

@property(atomic, assign) bool hasPreInit;
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

- (void) preInit: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    if (_hasPreInit) {
        return;
    }
    
    _configuration = configuration;
    [self onInitializeSender:credentials configuration:configuration];
    [self onPreInit:credentials configuration:configuration];
    
    _hasPreInit = YES;
}

- (void) initialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    // should pre-init first
    [self preInit: credentials configuration: configuration];
    
    if (_hasInitialize) {
        return;
    }
    
    [self onInitialize:credentials configuration:configuration];
    _hasInitialize = YES;
    [self onPostInitialize];
    
}

- (void)stop {
    if (_hasPreInit) {
        _hasPreInit = NO;
    }
    
    if (_hasInitialize) {
        
        [self onStop];
        _hasInitialize = NO;
        [self onPostStop];
    }
}

- (void) onInitializeSender: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    
}

- (void) onPreInit: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    
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
