//
//  SLSSdkFeature.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSSdkFeature.h"

@interface SLSSdkFeature ()

@property(atomic, assign) bool hasInitialize;
@property(nonatomic, strong) SLSConfiguration *configuration;

@end

@implementation SLSSdkFeature

- (void) initialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    if (_hasInitialize) {
        return;
    }
    
    _configuration = configuration;
    
}

- (void)stop {
    if (_hasInitialize) {
        
        _hasInitialize = NO;
    }
}


@end
