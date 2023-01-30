//
//  SLSTraceFeature.m
//  Pods
//
//  Created by gordon on 2022/9/13.
//

#import "SLSTraceFeature.h"
#import "SLSSdkSender.h"
#import "SLSTracer+Internal.h"
#import "SLSURLSessionInstrumentation.h"
#import "LogProducerConfig.h"
#import "SLSHttpHeader.h"

@class SLSTraceSender;

#pragma mark - SLS Trace Sender
@interface SLSTraceSender : SLSSdkSender
@property(nonatomic, strong) SLSSdkFeature *feature;

+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature;
- (instancetype) initWithFeature: (SLSSdkFeature *) feature;

@end

#pragma mark - SLS Trace Feature
@interface SLSTraceFeature ()
@property(nonatomic, strong) SLSTraceSender *sender;
@end

@implementation SLSTraceFeature

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)name {
    return @"trace";
}

- (void)onInitialize:(SLSCredentials *)credentials configuration:(SLSConfiguration *)configuration {
    _sender = [SLSTraceSender sender: credentials feature: self];
    
    [SLSTracer setTraceFeature:self];
    [SLSTracer setSpanProvider:configuration.spanProvider];
    [SLSTracer setSpanProcessor:(id<SLSSpanProcessorProtocol>) _sender];
    
    if (configuration.enableInstrumentNSURLSession) {
        [SLSURLSessionInstrumentation inject];
    }
}

- (SLSSpanBuilder *)newSpanBuilder:(NSString *)spanName provider:(id<SLSSpanProviderProtocol>)provider processor:(id<SLSSpanProcessorProtocol>)processor {
    return [[SLSSpanBuilder builder] initWithName:spanName
                                         provider:self.configuration.spanProvider
                                        processor:(id<SLSSpanProcessorProtocol>) _sender
    ];
}

- (void)setCredentials:(SLSCredentials *)credentials {
    if (nil == credentials.traceCredentials) {
        [credentials createTraceCredentials];
    }
    [_sender setCredentials:credentials];
}

- (void) setCallback:(CredentialsCallback)callback {
    [_sender setCallback:callback];
}

@end

#pragma mark - SLS Trace Sender
@interface SLSTraceSender()

+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature;
- (instancetype) initWithFeature: (SLSSdkFeature *) feature;

@end

@implementation SLSTraceSender

+ (instancetype)sender:(SLSCredentials *)credentials feature:(SLSSdkFeature *)feature {
    SLSTraceSender *sender = [[SLSTraceSender alloc] initWithFeature:feature];
    [sender initialize:credentials];
    return sender;
}

- (instancetype)initWithFeature: (SLSSdkFeature *) feature {
    self = [super init];
    if (self) {
        _feature = feature;
    }
    return self;
}

- (NSString *)provideFeatureName {
    return [_feature name];
}

- (NSString *)provideLogFileName:(SLSCredentials *)credentials {
    return @"traces";
}

- (NSString *)provideEndpoint:(SLSCredentials *)credentials {
    return [super provideEndpoint:credentials.traceCredentials];
}

- (NSString *)provideProjectName:(SLSCredentials *)credentials {
    return credentials.traceCredentials.project;
}

- (NSString *)provideLogstoreName:(SLSCredentials *)credentials {
    return [NSString stringWithFormat:@"%@-traces", credentials.traceCredentials.instanceId];
    return credentials.traceCredentials.logstore;
}

- (NSString *)provideAccessKeyId:(SLSCredentials *)credentials {
    return credentials.traceCredentials.accessKeyId;
}

- (NSString *)provideAccessKeySecret:(SLSCredentials *)credentials {
    return credentials.traceCredentials.accessKeySecret;
}

- (NSString *)provideSecurityToken:(SLSCredentials *)credentials {
    return credentials.traceCredentials.securityToken;
}

- (void) provideLogProducerConfig: (id) config {
    [config setHttpHeaderInjector:^NSArray<NSString *> *(NSArray<NSString *> *srcHeaders) {
        return [SLSHttpHeader getHeaders:srcHeaders, [NSString stringWithFormat:@"%@/%@", [self->_feature name], [self->_feature version]], nil];
    }];
}

- (void)setCredentials:(nonnull SLSCredentials *)credentials {
    [super setCredentials:credentials.traceCredentials];
}

@end

