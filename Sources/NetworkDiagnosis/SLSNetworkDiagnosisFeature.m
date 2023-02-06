//
//  SLSNetworkDiagnosisFeature.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/10.
//

#import "SLSProducer.h"
#import "SLSNetworkDiagnosisFeature.h"
#import "Utdid.h"
#import "NSString+SLS.h"
#import "SLSNetworkDiagnosis.h"
#import "TimeUtils.h"

#import "SLSSdkSender.h"
#import "SLSCredentials.h"

#import "AliNetworkDiagnosis/AliDns.h"
#import "AliNetworkDiagnosis/AliHttpPing.h"
#import "AliNetworkDiagnosis/AliMTR.h"
#import "AliNetworkDiagnosis/AliPing.h"
#import "AliNetworkDiagnosis/AliTcpPing.h"
#import "AliNetworkDiagnosis/AliNetworkDiagnosis.h"

#import "SLSHttpHeader.h"

static int DEFAULT_PING_SIZE = 64;
static int DEFAULT_TIMEOUT = 2 * 1000;
static int DEFAULT_MAX_TIMES = 10;
static int DEFAULT_MAX_COUNT = 10;
static int DEFAULT_MAX_INTERVAL = 200;

static int DEFAULT_MTR_MAX_TTL = 30;
static int DEFAULT_MTR_MAX_PATH = 1;

static NSString *DNS_TYPE_IPv4 = @"A";
static NSString *DNS_TYPE_IPv6 = @"AAAA";

@class SLSNetworkDiagnosisSender;

@interface SLSNetworkDiagnosisSender : SLSSdkSender<AliNetworkDiagnosisDelegate>
- (instancetype) initWithFeature: (SLSSdkFeature *) feature;
- (void) registerCallback: (nullable Callback) callback;
+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature;
@end

@interface SLSNetworkDiagnosisFeature ()
@property(nonatomic, strong) SLSNetworkDiagnosisSender *sender;
@property(nonatomic, strong) NSString *idPrefix;
@property(nonatomic, assign) long index;
@property(nonatomic, strong) NSLock *lock;
@property(nonatomic, assign) BOOL enableMultiplePortsDetect;

- (NSString *) getIPAIdBySecretKey: (NSString *) secretKey;
- (NSString *) generateId;
@end

@implementation SLSNetworkDiagnosisFeature

#pragma mark - init
- (instancetype)init {
    if (self = [super init]) {
        _idPrefix = [NSString stringWithFormat:@"%ld", (long) [TimeUtils getTimeInMilliis]];
        _lock = [[NSLock alloc] init];
        _enableMultiplePortsDetect = NO;
    }
    return self;
}

- (NSString *)name {
    return @"network_diagnosis";
}

- (SLSSpanBuilder *) newSpanBuilder: (NSString *)spanName provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor {
    return [[SLSSpanBuilder builder] initWithName:spanName
                                         provider:self.configuration.spanProvider
                                        processor:(id<SLSSpanProcessorProtocol>)_sender
    ];
}

- (void)onInitialize:(SLSCredentials *)credentials configuration:(SLSConfiguration *)configuration {
    [super onInitialize:credentials configuration:configuration];
    SLSNetworkDiagnosisCredentials *networkCredentials = credentials.networkDiagnosisCredentials;
    if (!networkCredentials) {
        SLSLog(@"SLSNetworkDiagnosisCredentials must not be null.");
        return;
    }
    
    if (networkCredentials.secretKey.length > 0) {
        networkCredentials.instanceId = [self getIPAIdBySecretKey:networkCredentials.secretKey];
    }
    
    _sender = [SLSNetworkDiagnosisSender sender:credentials feature:self];
    
    [AliNetworkDiagnosis init:networkCredentials.secretKey
                     deviceId:[[Utdid getUtdid] copy]
                       siteId:networkCredentials.siteId
                    extension:networkCredentials.extension
    ];
    
#ifdef DEBUG
    [AliNetworkDiagnosis enableDebug:self.configuration.debuggable];
#else
    [AliNetworkDiagnosis enableDebug:NO];
#endif
    
    [AliNetworkDiagnosis registerDelegate:_sender];
    
    [[SLSNetworkDiagnosis sharedInstance] setNetworkDiagnosisFeature:self];
}

- (void)setCredentials:(SLSCredentials *)credentials {
    if (nil == credentials.networkDiagnosisCredentials) {
        [credentials createNetworkDiagnosisCredentials];
    }
    [_sender setCredentials:credentials];
}

- (void)setCallback:(CredentialsCallback)callback {
    [super setCallback:callback];
    if (_sender) {
        [_sender setCallback:callback];
    }
}

- (NSString *) getIPAIdBySecretKey: (NSString *) secretKey {
    NSString *decode = [secretKey base64Decode];
    if (!decode) {
        return @"";
    }
    
    NSDictionary *dict = [decode toDictionary];
    if (!dict || ![dict objectForKey:@"ipa_app_id"]) {
        return @"";
    }
    
    
    return [[dict objectForKey:@"ipa_app_id"] lowercaseString];
}

- (NSString *)generateId {
    [_lock lock];
    _index += 1;
    NSString *traceId = [NSString stringWithFormat:@"%@_%ld", _idPrefix, _index];
    [_lock unlock];

    return traceId;
}

- (void) disableExNetworkInfo {
    [AliNetworkDiagnosis disableExNetInfo];
}

- (void) setPolicyDomain: (NSString *) policyDomain {
    [AliNetworkDiagnosis setPolicyDomain:policyDomain];
}

- (void) setMultiplePortsDetect: (BOOL) enable {
    _enableMultiplePortsDetect = enable;
}

- (void) registerCallback:(Callback)callback {
    if (!_sender) {
        return;
    }
    
    [_sender registerCallback:callback];
}

- (void) updateExtensions: (NSDictionary *) extension {
    [AliNetworkDiagnosis updateExtension: [extension copy]];
}

#pragma mark - dns
- (void)dns:(nonnull NSString *)domain {
    [self dns:domain callback:nil];
}

- (void)dns:(nonnull NSString *)domain callback:(nullable Callback)callback {
    [self dns:@"" domain:domain callback:callback];
}

- (void)dns:(nonnull NSString *)nameServer domain:(nonnull NSString *)domain callback:(nullable Callback)callback {
    [self dns:nameServer domain:domain type:DNS_TYPE_IPv4 callback:callback];
}

- (void)dns:(nonnull NSString *)nameServer domain:(nonnull NSString *)domain type:(nonnull NSString *)type callback:(nullable Callback)callback {
    [self dns:nameServer domain:domain type:type timeout:DEFAULT_TIMEOUT callback:callback];
}

- (void)dns:(nonnull NSString *)nameServer domain:(nonnull NSString *)domain type:(nonnull NSString *)type timeout:(int)timeout callback:(nullable Callback)callback {
    NSString *server = [nameServer isEqualToString:@""] ? nil : nameServer;
    [AliDns execute:[[AliDnsConfig alloc] init:domain
                                    nameServer:server
                                          type:type
                                       timeout:timeout
                                 interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                       traceID:[self generateId]
                                      complete:^(id context, NSString *traceID, AliDnsResult *result) {
                                                    if (callback) {
                                                        callback([result.content copy]);
                                                    }
                                                }
                                       context:self
                    ]
    ];
}

#pragma mark - http
- (void)http:(nonnull NSString *)url {
    [self http:url callback:nil];
}

- (void)http:(nonnull NSString *)url callback:(nullable Callback)callback {
    [AliHttpPing start:url
               traceId:[self generateId]
               context:self
              complete:^(id context, NSString *traceID, AliHttpPingResult *result) {
                        if (callback) {
                            callback([result.content copy]);
                        }
                    }
    ];
}

#pragma mark - mtr
- (void)mtr:(nonnull NSString *)domain {
    [self mtr:domain callback:nil];
}

- (void)mtr:(nonnull NSString *)domain callback:(nullable Callback)callback {
    [self mtr:domain maxTTL:DEFAULT_MTR_MAX_TTL callback:callback];
}

- (void)mtr:(nonnull NSString *)domain maxTTL:(int)maxTTL callback:(nullable Callback)callback {
    [self mtr:domain maxTTL:maxTTL maxPaths:DEFAULT_MTR_MAX_PATH callback:callback];
}

- (void)mtr:(nonnull NSString *)domain maxTTL:(int)maxTTL maxPaths:(int)maxPaths callback:(nullable Callback)callback {
    [self mtr:domain maxTTL:maxTTL maxPaths:maxPaths maxTimes:DEFAULT_MAX_TIMES callback:callback];
}

- (void)mtr:(nonnull NSString *)domain maxTTL:(int)maxTTL maxPaths:(int)maxPaths maxTimes:(int)maxTimes callback:(nullable Callback)callback {
    [self mtr:domain maxTTL:maxTTL maxPaths:maxPaths maxTimes:maxTimes timeout:DEFAULT_TIMEOUT callback:callback];
}

- (void)mtr:(nonnull NSString *)domain maxTTL:(int)maxTTL maxPaths:(int)maxPaths maxTimes:(int)maxTimes timeout:(int)timeout callback:(nullable Callback)callback {
    [AliMTR start:domain
           maxTtl:maxTTL
    interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
         maxPaths:maxPaths
   maxTimesEachIP:DEFAULT_MAX_TIMES
          timeout:timeout
          context:self
          traceID:[self generateId]
           output:nil
         complete:^(id context, NSString *traceID, AliMTRResult *result) {
                    if (callback && result) {
                        callback([result.content copy]);
                    }
                }
    ];
}

#pragma mark - ping
- (void)ping:(nonnull NSString *)domain {
    [self ping:domain callback:nil];
}

- (void)ping:(nonnull NSString *)domain callback:(nullable Callback)callback {
    [self ping:domain maxTimes:DEFAULT_MAX_TIMES timeout:DEFAULT_TIMEOUT callback:callback];
}

- (void)ping:(nonnull NSString *)domain maxTimes:(int)maxTimes timeout:(int)timeout callback:(nullable Callback)callback {
    [self ping:domain size:DEFAULT_PING_SIZE maxTimes:maxTimes timeout:timeout callback:callback];
}

- (void)ping:(nonnull NSString *)domain size:(int)size callback:(nullable Callback)callback {
    [self ping:domain size:size maxTimes:DEFAULT_MAX_TIMES timeout:DEFAULT_TIMEOUT callback:callback];
}

- (void)ping:(nonnull NSString *)domain size:(int)size maxTimes:(int)maxTimes timeout:(int)timeout callback:(nullable Callback)callback {
    [AliPing execute:[[AliPingConfig alloc] init:domain
                                         timeout:timeout
                                   interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                          prefer:0
                                         context:self
                                         traceID:[self generateId]
                                            size:size
                                           count:DEFAULT_MAX_COUNT
                                        interval:DEFAULT_MAX_INTERVAL
                                        complete:^(id context, NSString *traceID, AliPingResult *result) {
                                                    if (callback) {
                                                        callback([result.content copy]);
                                                    }
                                                }
                                 combineComplete:nil
                     ]
    ];

}

#pragma mark - tcpping
- (void)tcpPing:(nonnull NSString *)domain port:(int)port {
    [self tcpPing:domain port:port callback:nil];
}

- (void)tcpPing:(nonnull NSString *)domain port:(int)port callback:(nullable Callback)callback {
    [self tcpPing:domain port:port maxTimes:DEFAULT_MAX_TIMES callback:callback];
}

- (void)tcpPing:(nonnull NSString *)domain port:(int)port maxTimes:(int)maxTimes callback:(nullable Callback)callback {
    [self tcpPing:domain port:port maxTimes:maxTimes timeout:DEFAULT_TIMEOUT callback:callback];
}

- (void)tcpPing:(nonnull NSString *)domain port:(int)port maxTimes:(int)maxTimes timeout:(int)timeout callback:(nullable Callback)callback {
    [AliTcpPing execute:[[AliTcpPingConfig alloc] init:domain
                                               timeout:timeout
                                         interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                                prefer:0
                                               context:self
                                               traceID:[self generateId]
                                                  port:port
                                                 count:DEFAULT_MAX_COUNT
                                              interval:DEFAULT_MAX_INTERVAL
                                              complete:^(id context, NSString *traceID, AliTcpPingResult *result) {
                                                        if (callback) {
                                                            callback([result.content copy]);
                                                        }
                                                    }
                                       combineComplete:nil
                        ]
    ];
}

@end

#pragma mark - network diagnosis sender
@interface SLSNetworkDiagnosisSender ()
@property(nonatomic, strong) SLSSdkFeature *feature;
@property(nonatomic, strong, readonly) Callback globalCallback;
@end

@implementation SLSNetworkDiagnosisSender
+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature {
    SLSNetworkDiagnosisSender *sender = [[SLSNetworkDiagnosisSender alloc] initWithFeature:feature];
    [sender initialize:credentials];
    return sender;;
}

- (void) registerCallback: (nullable Callback) callback {
    _globalCallback = callback;
}

- (instancetype) initWithFeature: (SLSSdkFeature *) feature {
    if (self = [super init]) {
        _feature = feature;
    }
    return self;
}

- (NSString *)provideFeatureName {
    return [_feature name];
}

- (NSString *)provideLogFileName:(SLSCredentials *)credentials {
    return @"net_d";
}

- (NSString *)provideEndpoint:(SLSCredentials *)credentials {
    if (nil != credentials.networkDiagnosisCredentials && credentials.networkDiagnosisCredentials.endpoint.length > 0) {
        return credentials.networkDiagnosisCredentials.endpoint;
    }
    
    return [super provideEndpoint:credentials];
}

- (NSString *)provideProjectName:(SLSCredentials *)credentials {
    if (nil != credentials.networkDiagnosisCredentials && credentials.networkDiagnosisCredentials.project.length > 0) {
        return credentials.networkDiagnosisCredentials.project;
    }
    
    return [super provideProjectName:credentials];
}

- (NSString *)provideLogstoreName:(SLSCredentials *)credentials {
    if (nil != credentials.networkDiagnosisCredentials && credentials.networkDiagnosisCredentials.instanceId.length > 0) {
        return [NSString stringWithFormat:@"ipa-%@-raw", credentials.networkDiagnosisCredentials.instanceId];
    } else {
        if (credentials.instanceId.length > 0) {
            return [NSString stringWithFormat:@"ipa-%@-raw", credentials.instanceId];
        }
        return nil;
    }
}

- (NSString *)provideAccessKeyId:(SLSCredentials *)credentials {
    if (nil != credentials.networkDiagnosisCredentials && credentials.networkDiagnosisCredentials.accessKeyId.length > 0) {
        return credentials.networkDiagnosisCredentials.accessKeyId;
    }
    
    return [super provideAccessKeyId:credentials];
}

- (NSString *)provideAccessKeySecret:(SLSCredentials *)credentials {
    if (nil != credentials.networkDiagnosisCredentials && credentials.networkDiagnosisCredentials.accessKeySecret.length > 0) {
        return credentials.networkDiagnosisCredentials.accessKeySecret;
    }
    
    return [super provideAccessKeySecret:credentials];
}

- (NSString *)provideSecurityToken:(SLSCredentials *)credentials {
    if (nil != credentials.networkDiagnosisCredentials && credentials.networkDiagnosisCredentials.securityToken.length > 0) {
        return credentials.networkDiagnosisCredentials.securityToken;
    }
    
    return [super provideSecurityToken:credentials];
}

- (void) provideLogProducerConfig: (id) config {
    [config setHttpHeaderInjector:^NSArray<NSString *> *(NSArray<NSString *> *srcHeaders) {
        return [SLSHttpHeader getHeaders:srcHeaders, [NSString stringWithFormat:@"%@/%@", [self->_feature name], [self->_feature version]], nil];
    }];
}


- (void)log:(NSString *)content level:(AliNetDiagLogLevel)level context:(id)context {
    if (level <= AliNetDiagLogLevelInfo) {
        SLSLogV(@"network_diagnosis, %@", content);
    } else {
        SLSLog(@"network_diagnosis, %@", content);
    }
}

- (void)report:(NSString *)content level:(AliNetDiagLogLevel)level context:(id)context {
    if (!content) {
        SLSLog(@"network_diagnosis, content is empty.");
        return;
    }
    
    NSString *finalContent = [content mutableCopy];
    
    NSData *data = [finalContent dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                    options:kNilOptions
                                      error:&error
    ];
    if (error) {
        SLSLog(@"network_diagnosis, content is not valid json. content: %@", finalContent);
        return;
    }
    
    NSString *method = [dict objectForKey:@"method"];
    if (!method) {
        SLSLog(@"network_diagnosis, method is empty.");
        return;
    }
    
    SLSSpanBuilder *builder = [_feature newSpanBuilder:@"network_diagnosis"];
    [builder addAttribute:
         [SLSAttribute of:@"t" value:@"net_d"],
         [SLSAttribute of:@"net.type" value:method],
         [SLSAttribute of:@"net.origin" value:finalContent],
         nil
    ];
    [builder setGlobal:NO];
    [[builder build] end];
    
    if (_globalCallback) {
        _globalCallback([content copy]);
    }
}

@end
