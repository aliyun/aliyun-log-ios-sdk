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

@interface SLSTraceLogSender : SLSTraceSender
+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature;
@end

#pragma mark - SLS Trace Feature
@interface SLSTraceFeature ()
@property(nonatomic, strong) SLSTraceSender *sender;
@property(nonatomic, strong) SLSTraceLogSender *logsSender;
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
    
    if (configuration.enableTraceLogs) {
        _logsSender = [SLSTraceLogSender sender:credentials feature:self];
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
    [_logsSender setCredentials:credentials];
}

- (void) setCallback:(CredentialsCallback)callback {
    [_sender setCallback:callback];
    [_logsSender setCallback:callback];
}

- (BOOL) addLog:(Log *)log {
    if (nil == log || nil == _logsSender) {
        return NO;
    }
    
    return [_logsSender send: log];
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
    if (nil != credentials.traceCredentials && credentials.traceCredentials.endpoint.length > 0) {
        return credentials.traceCredentials.endpoint;
    }
    
    return [super provideEndpoint:credentials];
}

- (NSString *)provideProjectName:(SLSCredentials *)credentials {
    if (nil != credentials.traceCredentials && credentials.traceCredentials.project.length > 0) {
        return credentials.traceCredentials.project;
    }
    
    return [super provideProjectName:credentials];
}

- (NSString *)provideLogstoreName:(SLSCredentials *)credentials {
    if (nil != credentials.traceCredentials && credentials.traceCredentials.instanceId.length > 0) {
        return [NSString stringWithFormat:@"%@-traces", credentials.traceCredentials.instanceId];
    } else {
        if (credentials.instanceId.length > 0) {
            return [NSString stringWithFormat:@"%@-traces", credentials.instanceId];
        } else {
            return nil;
        }
    }
}

- (NSString *)provideAccessKeyId:(SLSCredentials *)credentials {
    if (nil != credentials.traceCredentials && credentials.traceCredentials.accessKeyId.length > 0) {
        return credentials.traceCredentials.accessKeyId;
    }
    
    return [super provideAccessKeyId:credentials];
}

- (NSString *)provideAccessKeySecret:(SLSCredentials *)credentials {
    if (nil != credentials.traceCredentials && credentials.traceCredentials.accessKeySecret.length > 0) {
        return credentials.traceCredentials.accessKeySecret;
    }
    
    return [super provideAccessKeySecret:credentials];
}

- (NSString *)provideSecurityToken:(SLSCredentials *)credentials {
    if (nil != credentials.traceCredentials && credentials.traceCredentials.securityToken.length > 0) {
            return credentials.traceCredentials.securityToken;
    }
    
    return [super provideSecurityToken:credentials];
}

- (void) provideLogProducerConfig: (id) config {
    [config setHttpHeaderInjector:^NSArray<NSString *> *(NSArray<NSString *> *srcHeaders) {
        return [SLSHttpHeader getHeaders:srcHeaders, [NSString stringWithFormat:@"%@/%@", [self->_feature name], [self->_feature version]], nil];
    }];
}

@end

#pragma mark - TraceLogSender
@interface SLSTraceLogSender()
@property(nonatomic, strong) SLSTraceLogSender *sender;
@end

@implementation SLSTraceLogSender
+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature {
    SLSTraceLogSender *sender = [[SLSTraceLogSender alloc] initWithFeature:feature];
    [sender initialize:credentials];
    return sender;
}

- (NSString *)provideFeatureName {
    return @"TraceLogs";
}

- (NSString *)provideLogFileName:(SLSCredentials *)credentials {
    return @"traces_logs";
}

- (NSString *)provideEndpoint:(SLSCredentials *)credentials {
    SLSLogsCredentials * logsCredentials = credentials.traceCredentials.logsCredentials;
    if (nil == logsCredentials || logsCredentials.endpoint.length == 0) {
        return [super provideEndpoint:credentials];
    }
    
    return logsCredentials.endpoint;
}

- (NSString *)provideProjectName:(SLSCredentials *)credentials {
    SLSLogsCredentials * logsCredentials = credentials.traceCredentials.logsCredentials;
    if (nil == logsCredentials || logsCredentials.project.length == 0) {
        return [super provideProjectName:credentials];
    }
    
    return logsCredentials.project;
}

- (NSString *)provideLogstoreName:(SLSCredentials *)credentials {
    SLSLogsCredentials * logsCredentials = credentials.traceCredentials.logsCredentials;
    if (nil == logsCredentials || logsCredentials.logstore.length == 0) {
        if (nil == credentials.traceCredentials || credentials.traceCredentials.instanceId.length == 0) {
            if (credentials.instanceId.length == 0) {
                return nil;
            } else {
                return [NSString stringWithFormat:@"%@-logs", credentials.instanceId];
            }
        } else {
            return [NSString stringWithFormat:@"%@-logs", credentials.traceCredentials.instanceId];
        }
    }
    
    return logsCredentials.logstore;
}
@end
