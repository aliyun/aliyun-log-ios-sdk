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
static int DEFAULT_INVALID = -1;

static BOOL DEFAULT_HTTP_HEADER_ONLY = NO;
static int DEFAULT_HTTP_DOWNLOAD_BYTES_LIMIT = 64 * 1024; // 64KB

static NSString *DNS_TYPE_IPv4 = @"A";
static NSString *DNS_TYPE_IPv6 = @"AAAA";

@class SLSNetworkDiagnosisSender;

@interface SLSNetworkDiagnosisSender : SLSSdkSender<AliNetworkDiagnosisDelegate>
- (instancetype) initWithFeature: (SLSSdkFeature *) feature;
- (void) registerCallback: (nullable Callback2) callback;
+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature;
@end

@interface InternalHttpCredentialDelegate : NSObject<AliHttpCredentialDelegate>
@property(nonatomic, copy) CredentialDelegate delegate;
+ (instancetype) delegate: (CredentialDelegate) delegate;
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
    [AliNetworkDiagnosis updateExtension: [extension copy]];
}
- (void) registerHttpCredentialDelegate: (nullable CredentialDelegate) delegate {
    [AliNetworkDiagnosis registerHttpCredentialDelegate:[InternalHttpCredentialDelegate delegate:delegate]];
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

    [AliDns execute:[[AliDnsConfig alloc] init:request.domain
                                    nameServer:request.nameServer
                                          type:request.type
                                       timeout:request.timeout
                                 interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                       traceID:[self generateId]
                                      complete:^(id context, NSString *traceID, AliDnsResult *result) {
                                                    if (callback) {
                                                        callback([SLSResponse response:context type:@"dns" content:[result.content copy]]);
                                                    }
                                                }
                                       context:request.context
                    ]
    ];
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
                                                            }
    ];
    
    [AliHttpPing execute:config];
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
    
    [AliMTR start:request.domain
           maxTtl:request.maxTTL
    interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
         maxPaths:request.maxPaths
   maxTimesEachIP:request.maxTimes
          timeout:request.timeout
          context:request.context
          traceID:[self generateId]
           output:nil
         complete:^(id context, NSString *traceID, AliMTRResult *result) {
                    if (callback && result) {
                        callback([SLSResponse response:context type:@"mtr" content:[result.content copy]]);
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
    
    [AliPing execute:[[AliPingConfig alloc] init:request.domain
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
    
    [AliTcpPing execute:[[AliTcpPingConfig alloc] init:request.domain
                                               timeout:request.timeout
                                         interfaceType:(_enableMultiplePortsDetect ? AliNetDiagNetworkInterfaceDefault : AliNetDiagNetworkInterfaceCurrent)
                                                prefer:0
                                               context:request.context
                                               traceID:[self generateId]
                                                  port:request.port
                                                 count:DEFAULT_MAX_COUNT
                                              interval:DEFAULT_MAX_INTERVAL
                                              complete:^(id context, NSString *traceID, AliTcpPingResult *result) {
                                                        if (callback) {
                                                            callback([SLSResponse response:context type:@"tcpping" content:[result.content copy]]);
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
         [SLSAttribute of:@"net.origin" value:finalContent],
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
