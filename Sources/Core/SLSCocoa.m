//
//  SLSCocoa.m
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//
#import "SLSSystemCapabilities.h"
#if SLS_HAS_UIKIT
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import "SLSCocoa.h"
#import "AliyunLogProducer.h"
#import "SLSSdkSender.h"
#import "SLSAppUtils.h"
#import "SLSFeatureProtocol.h"
#import "SLSUtdid.h"
#import "SLSDeviceUtils.h"
#import "NSString+SLS.h"
#import "SLSUtils.h"
#import "SLSPrivocyUtils.h"

@interface SLSCocoa ()
@property(atomic, assign) BOOL hasPreInit;
@property(atomic, assign) BOOL hasInitialize;
@property(nonatomic, copy) SLSCredentials *credentials;
@property(nonatomic, strong) SLSConfiguration *configuration;
@property(nonatomic, strong) NSMutableArray<id<SLSFeatureProtocol>> *features;
@property(nonatomic, strong) SLSExtraProvider *extraProvider;

- (BOOL) internalPreInit: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration;
- (BOOL) internalInitialize: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration;
- (void) initializeDefaultSpanProvider;
- (void) initializeSdkSender;

- (void) preInitFeature: (NSString *) clazzName;
- (void) initFeature: (NSString *) clazzName;
@end

@implementation SLSCocoa

#pragma mark - instance
+ (instancetype) sharedInstance {
    static SLSCocoa * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SLSCocoa alloc] init];
    });
    return ins;
}

#pragma mark - initialize
- (instancetype)init
{
    self = [super init];
    if (self) {
        _features = [NSMutableArray array];
        _extraProvider = [[SLSExtraProvider alloc] init];
    }
    return self;
}

- (BOOL) preInit: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration {
    return [self internalPreInit: credentials configuration:configuration];
}

- (BOOL) initialize: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration {
    return [self internalInitialize: credentials configuration:configuration];
}

- (BOOL) internalPreInit: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration {
    if (!configuration) {
        return NO;
    }
    
    // disable privocy while pre-init
    [SLSPrivocyUtils setEnablePrivocy:NO];
    
    if (_hasPreInit) {
        return NO;
    }
    
    _credentials = credentials;
    _configuration = [[SLSConfiguration alloc] init];
    configuration(_configuration);
    [_configuration setup];
    
    [self initializeDefaultSpanProvider];
    [self initializeSdkSender];
    
    if (_configuration.enableCrashReporter || _configuration.enableBlockDetection) {
        [self preInitFeature: @"SLSCrashReporterFeature"];
    }
    
    if (_configuration.enableNetworkDiagnosis) {
        [self preInitFeature: @"SLSNetworkDiagnosisFeature"];
    }
    
    if (_configuration.enableTrace) {
        [self preInitFeature:@"SLSTraceFeature"];
    }
    
    _hasPreInit = YES;
    return YES;
}

- (BOOL) internalInitialize: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration {
    // should pre init first
    [self internalPreInit:credentials configuration:configuration];
    
    if (!configuration) {
        return NO;
    }
    
    // enable privocy while real-init
    [SLSPrivocyUtils setEnablePrivocy:YES];
    
    if (_hasInitialize) {
        return NO;
    }
    
    if (_configuration.enableCrashReporter || _configuration.enableBlockDetection) {
        [self initFeature: @"SLSCrashReporterFeature"];
    }
    
    if (_configuration.enableNetworkDiagnosis) {
        [self initFeature: @"SLSNetworkDiagnosisFeature"];
    }
    
    if (_configuration.enableTrace) {
        [self initFeature:@"SLSTraceFeature"];
    }
    
    _hasInitialize = YES;
    return YES;
}

- (void) initializeDefaultSpanProvider {
    SLSSpanProviderDelegate *delegate = [SLSSpanProviderDelegate provider:_configuration credentials:_credentials extraProvider:_extraProvider];
    _configuration.spanProvider = delegate;
}
- (void) initializeSdkSender {
    id<SLSSenderProtocol> sender = (id<SLSSenderProtocol>)_configuration.spanProcessor;
    [sender initialize: _credentials];
}

- (void) preInitFeature: (NSString *) clazzName {
    if (!clazzName || clazzName.length <= 0) {
        return;
    }
    
    SLSLog(@"preInitFeature, start init: %@", clazzName);
    
    Class clazz = NSClassFromString(clazzName);
    if (!clazz || ![clazz conformsToProtocol:@protocol(SLSFeatureProtocol)]) {
        SLSLog(@"preInitFeature, feature class not found.");
        return;
    }
    
    id<SLSFeatureProtocol> feature = [[clazz alloc] init];
    if (!feature) {
        SLSLog(@"preInitFeature, feature init error.");
        return;
    }
    
    [feature preInit:_credentials configuration:_configuration];
    
    [_features addObject:feature];
    SLSLog(@"preInitFeature, init: %@ success.", clazzName);
}

- (void) initFeature: (NSString *) clazzName {
    if (!clazzName || clazzName.length <= 0 || nil == _features) {
        return;
    }
    
    for (id<SLSFeatureProtocol> feature in _features) {
        SLSLog(@"initFeature, start init: %@", [feature name]);
        [feature initialize:_credentials configuration:_configuration];
        SLSLog(@"initFeature, init: %@ success.", [feature name]);
    }
}

#pragma mark - setter
- (void) setCredentials: (SLSCredentials *) credentials {
    if (!credentials) {
        return;
    }
    
    if (credentials.instanceId && credentials.instanceId.length > 0) {
        _credentials.instanceId = credentials.instanceId;
    }
    if (credentials.endpoint && credentials.endpoint.length > 0) {
        _credentials.endpoint = credentials.endpoint;
    }
    if (credentials.project && credentials.project.length > 0) {
        _credentials.project = credentials.project;
    }
    
    if (credentials.accessKeyId && credentials.accessKeyId.length > 0) {
        _credentials.accessKeyId = credentials.accessKeyId;
    }
    if (credentials.accessKeySecret && credentials.accessKeySecret.length > 0) {
        _credentials.accessKeySecret = credentials.accessKeySecret;
    }
    if (credentials.securityToken && credentials.securityToken.length > 0) {
        _credentials.securityToken = credentials.securityToken;
    }
    
    [(id<SLSSenderProtocol>) _configuration.spanProcessor setCredentials:credentials];
    
    for (id<SLSFeatureProtocol> feature in _features) {
        [feature setCredentials:credentials];
    }
    
}
- (void) setUserInfo: (SLSUserInfo *) userInfo {
    if (!_configuration || !userInfo) {
        return;
    }
    
    _configuration.userInfo = userInfo;
}
- (void)registerCredentialsCallback:(CredentialsCallback)callback {
    [(SLSSdkSender *) _configuration.spanProcessor setCallback: callback];
    
    for (id<SLSFeatureProtocol> feature in _features) {
        [feature setCallback:callback];
    }
}

#pragma mark - extras
- (void) setExtra: (NSString *)key value: (NSString *)value {
    [_extraProvider setExtra:key value:value];
}
- (void) setExtra: (NSString *)key dictValue: (NSDictionary<NSString *, NSString *> *)value {
    [_extraProvider setExtra:key dictValue:value];
}
- (void) removeExtra: (NSString *)key {
    [_extraProvider removeExtra:key];
}
- (void) clearExtras {
    [_extraProvider clearExtras];
}
- (void) setUtdid: (NSString *) utdid {
    [SLSUtdid setUtdid:utdid];
}

@end

#pragma mark - SLSSpanProviderDelegate
@interface SLSSpanProviderDelegate ()
@property(nonatomic, strong) SLSConfiguration *configuration;
@property(nonatomic, strong) SLSCredentials *credentials;
@property(nonatomic, strong) id<SLSSpanProviderProtocol> spanProvider;
@property(nonatomic, strong) SLSExtraProvider *extraProvider;
- (instancetype) initWithConfiguration: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials extraProvider: (SLSExtraProvider *)extraProvider;
- (void) provideExtra: (NSMutableArray<SLSAttribute *> *)attributes;
- (SLSResource *) createDefaultResource;
@end

@implementation SLSSpanProviderDelegate

- (instancetype) initWithConfiguration: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials extraProvider: (SLSExtraProvider *)extraProvider {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _credentials = credentials;
        _spanProvider = configuration.spanProvider;
        _extraProvider = extraProvider;
    }
    return self;
}

+ (instancetype) provider: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials extraProvider: (SLSExtraProvider *)extraProvider {
    return [[SLSSpanProviderDelegate alloc] initWithConfiguration:configuration credentials:credentials extraProvider:extraProvider];
}

- (SLSResource *) createDefaultResource {
    BOOL privocy = [SLSPrivocyUtils isEnablePrivocy];
    
    SLSResource *resource = [[SLSResource alloc] init];
    [resource add:@"sdk.language" value:@"Objective-C"];
    
    // device specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/device.md
    [resource add:@"device.id" value:[[SLSUtdid getUtdid] copy]];
    [resource add:@"device.model.identifier" value:privocy ? [SLSDeviceUtils getDeviceModelIdentifier] : @""];
    [resource add:@"device.model.name" value:privocy ? [SLSDeviceUtils getDeviceModelIdentifier] : @""];
    [resource add:@"device.manufacturer" value:@"Apple"];
    [resource add:@"device.resolution" value:privocy ? [SLSDeviceUtils getResolution] : @""];
    
    // os specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/os.md
#if SLS_HAS_UIKIT
    NSString *systemName = [[[UIDevice currentDevice] systemName] copy];
    NSString *systemVersion = [[[UIDevice currentDevice] systemVersion] copy];
#else
    NSString *systemName = [[[NSProcessInfo processInfo] operatingSystemName] copy];
    NSString *systemVersion = [[[NSProcessInfo processInfo] operatingSystemVersionString] copy];
#endif
    [resource add:@"os.type" value: @"darwin"];
    [resource add:@"os.description" value: [NSString stringWithFormat:@"%@ %@", systemName, systemVersion]];
    
#if SLS_HOST_MAC
    [resource add:@"os.name" value: @"macOS"];
#elif SLS_HOST_TV
    [resource add:@"os.name" value: @"tvOS"];
#else
    [resource add:@"os.name" value: @"iOS"];
#endif
    [resource add:@"os.version" value: systemVersion];
    [resource add:@"os.root" value: privocy ? [SLSDeviceUtils isJailBreak] : @""];
//        @"os.sdk": [[TelemetryAttributeValue alloc] initWithStringValue:@"iOS"],
    
    // host specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/host.md
#if SLS_HOST_MAC
    [resource add:@"host.name" value: @"macOS"];
#elif SLS_HOST_TV
    [resource add:@"host.name" value: @"tvOS"];
#else
    [resource add:@"host.name" value: @"iOS"];
#endif
    [resource add:@"host.type" value: systemName];
    [resource add:@"host.arch" value: privocy ? [SLSDeviceUtils getCPUArch] : @""];
    
    [resource add:@"sls.sdk.language" value: @"Objective-C"];
    [resource add:@"sls.sdk.name" value: @"SLSCocoa"];
    [resource add:@"sls.sdk.version" value: [SLSUtils getSdkVersion]];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [infoDictionary objectForKey:@"CFBundleName"];
    }
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *buildCode = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    [resource add:@"app.version" value:(!appVersion ? @"-" : appVersion)];
    [resource add:@"app.build_code" value:(!buildCode ? @"-" : buildCode)];
    [resource add:@"app.name" value:(!appName ? @"-" : appName)];
    
    [resource add:@"net.access" value: privocy ? [SLSDeviceUtils getNetworkTypeName] : @""];
    [resource add:@"net.access_subtype" value: privocy ? [SLSDeviceUtils getNetworkSubTypeName] : @""];
    [resource add:@"carrier" value: privocy ? [[SLSDeviceUtils getCarrier] copy] : @""];
    return resource;
}

- (SLSResource *)provideResource {
    return [[self createDefaultResource] copy];
}

- (NSArray<SLSAttribute *> *)provideAttribute{
    NSMutableArray<SLSAttribute*> *attributes =
    (NSMutableArray<SLSAttribute*> *) [SLSAttribute of:
                                               //            [SLSKeyValue create:@"page.name" value:([SLSAppUtils sharedInstance].foreground ? @"true" : @"false")],
                                           [SLSKeyValue create:@"foreground" value:([SLSAppUtils sharedInstance].foreground ? @"true" : @"false")],
                                           [SLSKeyValue create:@"instance" value:_credentials.instanceId],
                                           [SLSKeyValue create:@"env" value:(_configuration.env ? _configuration.env : @"default")],
                                           nil
    ];
    
    [self provideExtra:attributes];
    
    if (_configuration.userInfo) {
        [self provideUserInfo:attributes userinfo:_configuration.userInfo];
    }
    
    NSArray<SLSAttribute *> *userAttributes = [_spanProvider provideAttribute];
    if (userAttributes) {
        [attributes addObjectsFromArray:userAttributes];
    }
    
    return attributes;
}

- (void) provideExtra: (NSMutableArray<SLSAttribute *> *)attributes {
    NSDictionary<NSString *, NSString *> *extras = [_extraProvider getExtras];
    if (!extras) {
        return;
    }
    
    for (NSString *k in extras) {
        NSString *key = [NSString stringWithFormat:@"extras.%@", k];
        if ([[extras valueForKey:k] isKindOfClass:[NSDictionary<NSString *, NSString *> class]]) {
            [attributes addObject:[SLSAttribute of:key
                                             value:[NSString stringWithDictionary:(NSDictionary *)[extras valueForKey:k]]
                                  ]
            ];
        } else {
            [attributes addObject:[SLSAttribute of:key
                                             value:[extras valueForKey:k]
                                  ]
            ];
        }
    }
}

- (void) provideUserInfo: (NSMutableArray<SLSAttribute *> *) attributes userinfo: (SLSUserInfo *) info {
    if (info.uid.length > 0) {
        [attributes addObject:[SLSAttribute of:@"user.uid"
                                         value:[info.uid copy]
                              ]
        ];
    }
    
    if (info.channel.length > 0) {
        [attributes addObject:[SLSAttribute of:@"user.channel"
                                         value:[info.channel copy]
                              ]
        ];
    }
    
    if (info.ext) {
        for (NSString *k in info.ext) {
            if (k.length == 0) {
                continue;
            }
            
            [attributes addObject:[SLSAttribute of:[NSString stringWithFormat:@"user.%@", k]
                                             value:[[info.ext valueForKey:k] copy]
                                   ]
            ];
        }
    }
    
}
@end

#pragma mark - SLSExtraProvider
@interface SLSExtraProvider()
@property(nonatomic, strong, readonly) NSMutableDictionary *dict;
@end

@implementation SLSExtraProvider : NSObject

- (instancetype)init {
    if (self = [super init]) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) setExtra: (NSString *)key value: (NSString *)value {
    [_dict setObject:[value copy] forKey:[key copy]];
}
- (void) setExtra: (NSString *)key dictValue: (NSDictionary<NSString *, NSString *> *)value {
    if (![value isKindOfClass:[NSDictionary<NSString *, NSString *> class]]) {
        return;
    }

    [_dict setObject:[value copy] forKey:[key copy]];
}
- (void) removeExtra: (NSString *)key {
    [_dict removeObjectForKey:key];
}
- (void) clearExtras {
    [_dict removeAllObjects];
}
- (NSDictionary<NSString *, NSString *> *) getExtras {
    return [_dict copy];
}
@end
