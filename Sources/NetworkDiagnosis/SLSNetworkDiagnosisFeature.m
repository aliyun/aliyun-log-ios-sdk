//
//  SLSNetworkDiagnosisFeature.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/10.
//

#import "SLSProducer.h"
#import "SLSNetworkDiagnosisFeature.h"
#import "SLSUtdid.h"
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
#import "SLSDiagnosisProtocol.h"

// for better compatibility, use __has_include instead of preprocessor
// in AliyunLogNetworkDiagnosis-NoSwift target, there is no .swift files
#if __has_include("AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis-Swift.h")
    #define SLS_NETWORK_SWIFT_FEATURE
    #import "AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis-Swift.h"
#endif

static int DEFAULT_PING_SIZE = 64;
static int DEFAULT_TIMEOUT = 2 * 1000;
static int DEFAULT_MAX_TIMES = 10;
static int DEFAULT_MAX_COUNT = 10;
static int DEFAULT_MAX_INTERVAL = 200;

static int DEFAULT_MTR_MAX_TTL = 30;
static int DEFAULT_MTR_MAX_PATH = 1;
static int DEFAULT_INVALID = -1;

static BOOL DEFAULT_HTTP_HEADER_ONLY = NO;
static int DEFAULT_HTTP_DOWNLOAD_BYTES_LIMIT = 64 * 1024; // 64KB

static NSString *DNS_TYPE_IPv4 = @"A";
static NSString *DNS_TYPE_IPv6 = @"AAAA";

@class SLSNetworkDiagnosisSender;

#pragma mark -- network diagnosis sender
@interface SLSNetworkDiagnosisSender : SLSSdkSender<AliNetworkDiagnosisDelegate>
- (instancetype) initWithFeature: (SLSSdkFeature *) feature;
- (void) registerCallback: (nullable Callback2) callback;
+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature;
@end

#pragma mark -- internal credential delegate
@interface InternalHttpCredentialDelegate : NSObject<AliHttpCredentialDelegate>
@property(nonatomic, copy) CredentialDelegate delegate;
+ (instancetype) delegate: (CredentialDelegate) delegate;
@end

#pragma mark -- network diagnosis feature extension
@interface SLSNetworkDiagnosisFeature ()
@property(nonatomic, strong) SLSNetworkDiagnosisSender *sender;
@property(nonatomic, strong) NSString *idPrefix;
@property(nonatomic, assign) long index;
@property(nonatomic, strong) NSLock *lock;
@property(nonatomic, assign) BOOL enableMultiplePortsDetect;
@property(nonatomic, strong) id<SLSDiagnosisProtocol> diagnosis;

- (NSString *) getIPAIdBySecretKey: (NSString *) secretKey;
- (NSString *) generateId;
@end

#pragma mark -- request & response
@implementation SLSRequest
@end

@implementation SLSHttpRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        _headerOnly = DEFAULT_HTTP_HEADER_ONLY;
        _downloadBytesLimit = DEFAULT_HTTP_DOWNLOAD_BYTES_LIMIT;
    }
    return self;
}
@end

@implementation SLSPingRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        _size = DEFAULT_PING_SIZE;
        _maxTimes = DEFAULT_MAX_TIMES;
        _timeout = DEFAULT_TIMEOUT;
        _parallel = NO;
    }
    return self;
}
@end

@implementation SLSTcpPingRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        _port = DEFAULT_INVALID;
    }
    return self;
}
@end

@implementation SLSMtrRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxTTL = DEFAULT_MTR_MAX_TTL;
        _maxPaths = DEFAULT_MTR_MAX_PATH;
        _protocol = SLS_MTR_PROROCOL_ALL;
    }
    return self;
}
@end

@implementation SLSDnsRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = DNS_TYPE_IPv4;
    }
    return self;
}
@end

@interface SLSResponse ()
+ (instancetype) response: context type: (NSString *)type content: (NSString *)content;
+ (instancetype) error: (NSString *)content;
@end

@implementation SLSResponse
- (instancetype)initWithContext: context type: (NSString *)type content: (NSString *)content error: (NSString *)error {
    self = [super init];
    if (self) {
        _context = context;
        _type = type;
        _content = content;
        _error = error;
    }
    return self;
}

+ (instancetype) response: context type: (NSString *)type content: (NSString *)content {
    return [[SLSResponse alloc] initWithContext:context type:type content:content error:nil];
}
+ (instancetype) error: (NSString *)error {
    return [[SLSResponse alloc] initWithContext:nil type:nil content:nil error:error];
}
@end

#pragma mark -- feature
@implementation SLSNetworkDiagnosisFeature

#pragma mark - init
- (instancetype)init {
    if (self = [super init]) {
        _idPrefix = [NSString stringWithFormat:@"%ld", (long) [TimeUtils getTimeInMilliis]];
        _lock = [[NSLock alloc] init];
        _enableMultiplePortsDetect = NO;
        _diagnosis = [[NetSpeedDiagnosis alloc] init];
    }
    return self;
}

- (NSString *)name {
    return @"network_diagnosis";
}

- (void)setDiagnosis:(id<SLSDiagnosisProtocol>)diagnosis {
    _diagnosis = diagnosis;
}

- (SLSSpanBuilder *) newSpanBuilder: (NSString *)spanName provider: (id<SLSSpanProviderProtocol>) provider processor: (id<SLSSpanProcessorProtocol>) processor {
    return [[SLSSpanBuilder builder] initWithName:spanName
                                         provider:self.configuration.spanProvider
                                        processor:(id<SLSSpanProcessorProtocol>)_sender
    ];
}

- (void)onPreInit:(SLSCredentials *)credentials configuration:(SLSConfiguration *)configuration {
    [super onPreInit:credentials configuration:configuration];

    SLSNetworkDiagnosisCredentials *networkCredentials = credentials.networkDiagnosisCredentials;
    if (!networkCredentials) {
        SLSLog(@"SLSNetworkDiagnosisCredentials must not be null.");
        return;
    }
    
    if (networkCredentials.secretKey.length > 0) {
        networkCredentials.instanceId = [self getIPAIdBySecretKey:networkCredentials.secretKey];
    }
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    [NetworkDiagnosisHelper updateWorkspace:networkCredentials.endpoint
                                    project:networkCredentials.project
                                   logstore:networkCredentials.instanceId
    ];
#endif

    _sender = [SLSNetworkDiagnosisSender sender:credentials feature:self];
    
    [_diagnosis preInit:networkCredentials.secretKey
               deviceId:[[SLSUtdid getUtdid] copy]
                 siteId:networkCredentials.siteId
              extension:networkCredentials.extension
    ];
    
#ifdef DEBUG
    [_diagnosis enableDebug:self.configuration.debuggable];
#else
    [_diagnosis enableDebug:NO];
#endif
    
    [_diagnosis registerDelegate:_sender];
    
    [[SLSNetworkDiagnosis sharedInstance] setNetworkDiagnosisFeature:self];
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
    
    [_diagnosis init:networkCredentials.secretKey
            deviceId:[[SLSUtdid getUtdid] copy]
              siteId:networkCredentials.siteId
           extension:networkCredentials.extension];
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
    [_diagnosis disableExNetInfo];
}

- (void) setPolicyDomain: (NSString *) policyDomain {
    [_diagnosis setPolicyDomain:policyDomain];
}

- (void) setMultiplePortsDetect: (BOOL) enable {
    _enableMultiplePortsDetect = enable;
}

- (void) registerCallback:(Callback)callback {
    [self registerCallback2:^(SLSResponse * _Nonnull response) {
        if (callback) {
            callback([response.content copy]);
        }
    }];
}

- (void)registerCallback2:(nullable Callback2) callback {
    if (!_sender) {
        return;
    }
    
    [_sender registerCallback:callback];
}

- (void) updateExtensions: (NSDictionary *) extension {
    [_diagnosis updateExtension: [extension copy]];
}
- (void) registerHttpCredentialDelegate: (nullable CredentialDelegate) delegate {
    [_diagnosis registerHttpCredentialDelegate:[InternalHttpCredentialDelegate delegate:delegate]];
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
    SLSDnsRequest *request = [[SLSDnsRequest alloc] init];
    request.nameServer = nameServer;
    request.domain = domain;
    request.type = type;
    request.timeout =  timeout;
    
    [self dns2:request callback:^(SLSResponse * _Nonnull response) {
        if (callback) {
            callback([response.content copy]);
        }
    }];
}

- (void)dns2:(SLSDnsRequest *)request {
    [self dns2:request callback:nil];
}

- (void)dns2:(SLSDnsRequest *)request callback:(Callback2)callback {
    if (nil == request || request.domain.length < 1) {
        if (callback) {
            callback([SLSResponse error:@"SLSDnsRequest is null or domain is empty."]);
        }
        return;
    }

    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    TraceNode *node = [TraceNode traceNode:@"dns" request:request];
#endif
    AliDnsConfig *dnsConfig = [[AliDnsConfig alloc] init:request.domain
                                              nameServer:request.nameServer
                                                    type:request.type
                                                 timeout:request.timeout
                                           interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                                 traceID:[self generateId]
                                                complete:^(id context, NSString *traceID, AliDnsResult *result) {
                                                              if (callback) {
                                                                  callback([SLSResponse response:context type:@"dns" content:[result.content copy]]);
                                                              }
#ifdef SLS_NETWORK_SWIFT_FEATURE
                                                              [node end];
#endif
                                                          }
                                                 context:request.context
    ];
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    [node setDetectConfig:dnsConfig];
#endif
    
    if (request.extention) {
        dnsConfig.detectExtension = [NSMutableDictionary dictionaryWithDictionary:request.extention];
    }
    
    [_diagnosis dns: dnsConfig];
}

#pragma mark - http
- (void)http:(nonnull NSString *)url {
    [self http:url callback:nil];
}

- (void)http:(nonnull NSString *)url callback:(nullable Callback)callback {
    [self http:url callback:callback credential:nil];
}


- (void)http:(nonnull NSString *)url callback:(nullable Callback)callback credential: (nullable CredentialDelegate)credential {
    SLSHttpRequest *request = [[SLSHttpRequest alloc] init];
    request.domain = url;
    request.credential = credential;
    request.context = self;
    
    [self http2:request callback:^(SLSResponse * _Nonnull response) {
        if (callback) {
            callback([response.content copy]);
        }
    }];
}

- (void)http2:(SLSHttpRequest *)request {
    [self http2:request callback:nil];
}

- (void)http2:(SLSHttpRequest *)request callback:(Callback2)callback {
    if (nil == request || request.domain.length < 1) {
        callback([SLSResponse error:@"SLSHttpRequest is null or domain is empty."]);
        return;
    }
    
    InternalHttpCredentialDelegate *delegate = [InternalHttpCredentialDelegate delegate:request.credential];
    AliHttpCredential *httpCredential = [delegate getHttpCredential:request.domain context:request.context];
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    TraceNode *node = [TraceNode traceNode:@"http" request:request];
#endif
    AliHttpPingConfig *config = [[AliHttpPingConfig alloc] init:request.domain
                                                        traceId:[self generateId]
                                               clientCredential:(nil != httpCredential ? httpCredential.clientCredential : nil)
                                               serverCredential:nil
                                                        timeout:request.timeout
                                                          limit:request.downloadBytesLimit
                                                     headerOnly:request.headerOnly
                                                        context:request.context
                                                       complete:^(id context, NSString *traceID, AliHttpPingResult *result) {
                                                                if (callback) {
                                                                    callback([SLSResponse response:context type:@"http" content:[result.content copy]]);
                                                                }

#ifdef SLS_NETWORK_SWIFT_FEATURE
                                                                [node end];
#endif
                                                            }
    ];
    if (request.extention) {
        config.detectExtension = [NSMutableDictionary dictionaryWithDictionary:request.extention];
    }
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    [node setDetectConfig:config];
#endif
    
    [_diagnosis http:config];
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
    SLSMtrRequest *request = [[SLSMtrRequest alloc] init];
    request.domain = domain;
    request.maxTTL = maxTTL;
    request.maxPaths = maxPaths;
    request.maxTimes = maxTimes;
    request.timeout = timeout;
    
    [self mtr2:request callback:^(SLSResponse * _Nonnull response) {
        if (callback) {
            callback([response.content copy]);
        }
    }];
}

- (void)mtr2:(SLSMtrRequest *)request {
    [self mtr2:request callback:nil];
}

- (void)mtr2:(SLSMtrRequest *)request callback:(Callback2)callback {
    if (nil == request || request.domain.length < 1) {
        if (callback) {
            callback([SLSResponse error:@"SLSMtrRequest is null or domain is empty."]);
        }
        return;
    }
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    TraceNode *node = [TraceNode traceNode:@"mtr" request:request];
#endif
    AliMTRConfig *config = [[AliMTRConfig alloc] init:request.domain
                                               maxTtl:request.maxTTL
                                             maxPaths:request.maxPaths
                                        maxTimeEachIP:request.maxTimes
                                              timeout:request.timeout
                                        interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                               prefer:0
                                              context:request.context
                                              traceID:[self generateId]
                                             complete:^(id context, NSString *traceID, AliMTRResult *result) {
                                                            if (callback && result) {
                                                                callback([SLSResponse response:context type:@"mtr" content:[result.content copy]]);
                                                            }
      
#ifdef SLS_NETWORK_SWIFT_FEATURE
                                                            [node end];
#endif
                                                        }
                                      combineComplete:nil
    ];
    if (request.extention) {
        config.detectExtension = [NSMutableDictionary dictionaryWithDictionary:request.extention];
    }

    config.protocol = request.protocol;
    config.parallel = request.parallel;
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    [node setDetectConfig:config];
#endif
    
    [_diagnosis mtr:config];
    
    
//    [AliMTR start:request.domain
//           maxTtl:request.maxTTL
//    interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
//         maxPaths:request.maxPaths
//   maxTimesEachIP:request.maxTimes
//          timeout:request.timeout
//          context:request.context
//          traceID:[self generateId]
//           output:nil
//         complete:^(id context, NSString *traceID, AliMTRResult *result) {
//                    if (callback && result) {
//                        callback([SLSResponse response:context type:@"mtr" content:[result.content copy]]);
//                    }
//                }
//    ];
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
    SLSPingRequest *request = [[SLSPingRequest alloc] init];
    request.domain = domain;
    request.size = size;
    request.maxTimes = maxTimes;
    request.timeout = timeout;
    request.context = self;
    
    [self ping2:request callback:^(SLSResponse * _Nonnull response) {
        if (callback) {
            callback([response.content copy]);
        }
    }];
}

- (void)ping2:(SLSPingRequest *)request {
    [self ping2:request callback:nil];
}

- (void)ping2:(SLSPingRequest *)request callback:(Callback2)callback {
    if (nil == request || request.domain.length < 1) {
        if (callback) {
            callback([SLSResponse error:@"SLSPingRequest is null or domain is empty."]);
        }
        return;
    }
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    TraceNode *node = [TraceNode traceNode:@"ping" request:request];
#endif
    
    AliPingConfig *config = [[AliPingConfig alloc] init:request.domain
                                                timeout:request.timeout
                                          interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                                 prefer:0
                                                context:request.context
                                                traceID:[self generateId]
                                                   size:request.size
                                                  count:DEFAULT_MAX_COUNT
                                               interval:DEFAULT_MAX_INTERVAL
                                               complete:^(id context, NSString *traceID, AliPingResult *result) {
                                                           if (callback) {
                                                               callback([SLSResponse response:context type:@"ping" content:[result.content copy]]);
                                                           }

#ifdef SLS_NETWORK_SWIFT_FEATURE
                                                           [node end];
#endif
                                                       }
                                        combineComplete:nil
    ];
    config.parallel = request.parallel;
    if (request.extention) {
        config.detectExtension = [NSMutableDictionary dictionaryWithDictionary:request.extention];
    }

#ifdef SLS_NETWORK_SWIFT_FEATURE
    [node setDetectConfig:config];
#endif
    
    [_diagnosis ping: config];
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
    SLSTcpPingRequest *request = [[SLSTcpPingRequest alloc] init];
    request.domain = domain;
    request.port = port;
    request.maxTimes = maxTimes;
    request.timeout = timeout;
    request.context = self;
    
    [self tcpPing2:request callback:^(SLSResponse * _Nonnull response) {
        if (callback) {
            callback([response.content copy]);
        }
    }];
    
}

- (void)tcpPing2:(SLSTcpPingRequest *)request {
    [self tcpPing2:request callback:nil];
}

- (void)tcpPing2:(SLSTcpPingRequest *)request callback:(Callback2)callback {
    if (nil == request || request.domain.length < 1) {
        if (callback) {
            callback([SLSResponse error:@"SLSTcpPingRequest is null or domain is empty."]);
        }
        return;
    }
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    TraceNode *node = [TraceNode traceNode:@"tcpping" request:request];
#endif
    
    AliTcpPingConfig *config = [[AliTcpPingConfig alloc] init:request.domain
                                                      timeout:request.timeout
                                                interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                                       prefer:0
                                                      context:request.context
                                                      traceID:[self generateId]
                                                         port:request.port
                                                        count:request.maxTimes
                                                     interval:DEFAULT_MAX_INTERVAL
                                                     complete:^(id context, NSString *traceID, AliTcpPingResult *result) {
                                                               if (callback) {
                                                                   callback([SLSResponse response:context type:@"tcpping" content:[result.content copy]]);
                                                               }

#ifdef SLS_NETWORK_SWIFT_FEATURE
                                                               [node end];
#endif
                                                           }
                                              combineComplete:nil
    ];
    if (request.extention) {
        config.detectExtension = [NSMutableDictionary dictionaryWithDictionary:request.extention];
    }
    
#ifdef SLS_NETWORK_SWIFT_FEATURE
    [node setDetectConfig:config];
#endif

    [_diagnosis tcpPing: config];
}

@end

#pragma mark - network diagnosis sender
@interface SLSNetworkDiagnosisSender ()
@property(nonatomic, strong) SLSSdkFeature *feature;
@property(nonatomic, strong, readonly) Callback2 globalCallback;
@end

@implementation SLSNetworkDiagnosisSender
+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature {
    SLSNetworkDiagnosisSender *sender = [[SLSNetworkDiagnosisSender alloc] initWithFeature:feature];
    [sender initialize:credentials];
    return sender;;
}

- (void) registerCallback: (nullable Callback2) callback {
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
         [SLSAttribute of:@"net.origin" dictValue:dict],
         nil
    ];
    [builder setGlobal:NO];
    [[builder build] end];
    
    if (_globalCallback) {
        _globalCallback([SLSResponse response:context type:method content:[content copy]]);
    }
}

@end

#pragma mark internal ali http credential delegate
@implementation InternalHttpCredentialDelegate
+ (instancetype) delegate: (CredentialDelegate) delegate {
    InternalHttpCredentialDelegate *instance =  [[self alloc] init];
    instance.delegate = delegate;
    return instance;
}

- (AliHttpCredential *)getHttpCredential:(NSString *)url context:(id)context {
    if (nil == _delegate) {
        return nil;
    }
    
    NSURLCredential *credential = _delegate(url);
    if (nil != credential) {
        AliHttpCredential *httpCredential = [[AliHttpCredential alloc] init];
        httpCredential.clientCredential = credential;
        return httpCredential;
    }
    return nil;
}
@end

#pragma mark -- NetSpeed Diagnosis
@implementation NetSpeedDiagnosis
- (void)dns:(nonnull AliDnsConfig *)config {
    [AliDns execute: config];
}

- (void)http:(nonnull AliHttpPingConfig *)config {
    [AliHttpPing execute: config];
}

- (void)mtr:(nonnull AliMTRConfig *)config {
    [AliMTR execute: config];
}

- (void)ping:(nonnull AliPingConfig *)config {
    [AliPing execute: config];
}

- (void)tcpPing:(nonnull AliTcpPingConfig *)config {
    [AliTcpPing execute:config];
}

- (void)disableExNetInfo {
    [AliNetworkDiagnosis disableExNetInfo];
}


- (void)enableDebug:(BOOL)debug {
    [AliNetworkDiagnosis enableDebug:debug];
}


- (void)executeOncePolicy:(nonnull NSString *)policy {
    [AliNetworkDiagnosis executeOncePolicy:policy];
}

- (void)preInit:(NSString*)secretKey deviceId:(NSString*)deviceId siteId:(NSString*)siteId extension:(NSDictionary*)extension {
    [AliNetworkDiagnosis preInit:secretKey deviceId:deviceId siteId:siteId extension:extension];
}

- (void)init:(nonnull NSString *)secretKey deviceId:(nonnull NSString *)deviceId siteId:(nonnull NSString *)siteId extension:(nonnull NSDictionary *)extension {
    [AliNetworkDiagnosis init:secretKey deviceId:deviceId siteId:siteId extension:extension];
}


- (void)refreshSecretKey:(nonnull NSString *)secretKey {
    [AliNetworkDiagnosis refreshSecretKey:secretKey];
}


- (void)registerDelegate:(nonnull id<AliNetworkDiagnosisDelegate>)delegate {
    [AliNetworkDiagnosis registerDelegate:delegate];
}


- (void)registerHttpCredentialDelegate:(nonnull id<AliHttpCredentialDelegate>)delegate {
    [AliNetworkDiagnosis registerHttpCredentialDelegate:delegate];
}


- (void)setPolicyDomain:(nonnull NSString *)domain {
    [AliNetworkDiagnosis setPolicyDomain:domain];
}


- (void)updateExtension:(nonnull NSDictionary *)extension {
    [AliNetworkDiagnosis updateExtension:extension];
}


@end

