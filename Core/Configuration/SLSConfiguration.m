//
//  SLSConfiguration.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import "SLSConfiguration.h"
#import "SLSSdkSender.h"
#import "SLSNoOpSender.h"
#import "AliyunLogProducer/AliyunLogProducer.h"
#import "SLSHttpHeader.h"
#import "SLSUtils.h"

@interface DefaultSdkSender : SLSSdkSender
+ (instancetype) sender;
@end

@implementation DefaultSdkSender
+ (instancetype) sender {
    return [[DefaultSdkSender alloc] init];
}
- (void) provideLogProducerConfig: (id) config {
    [config setHttpHeaderInjector:^NSArray<NSString *> *(NSArray<NSString *> *srcHeaders) {
        return [SLSHttpHeader getHeaders:srcHeaders, [NSString stringWithFormat:@"apm/%@", [SLSUtils getSdkVersion]],nil];
    }];
}

@end

@implementation SLSConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enableCrashReporter = NO;
        _enableBlockDetection = NO;
        _enableNetworkDiagnosis = NO;
        _debuggable = NO;
        _enableInstrumentNSURLSession = NO;
    }
    return self;
}

- (instancetype) initWithProcessor: (id<SLSSpanProcessorProtocol>) processor {
    self = [self init];
    if (self) {
        _spanProcessor = processor;
    }

    return self;
}
- (void) setup {
    if (_enableCrashReporter || _enableBlockDetection) {
        _spanProcessor = [DefaultSdkSender sender];
    } else {
        _spanProcessor = [[SLSNoOpSender alloc] init];
    }
}

@end
