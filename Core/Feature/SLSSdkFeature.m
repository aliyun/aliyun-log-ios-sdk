//
//  SLSSdkFeature.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSSdkFeature.h"

@interface SLSSdkFeature ()

@property(atomic, assign) bool hasInitialize;

@end

@implementation SLSSdkFeature

- (SLSSpanBuilder *) newSpanBuilder: (NSString *) spanName {
    return [[SLSSpanBuilder builder] initWithName:spanName provider:_configuration.spanProvider processor:_configuration.spanProcessor];
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


@end
