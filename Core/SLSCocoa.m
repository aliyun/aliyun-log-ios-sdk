//
//  SLSCocoa.m
//  AliyunLogProducer
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
#import "SLSSdkSender.h"
#import "SLSAppUtils.h"
#import "SLSFeatureProtocol.h"
#import "Utdid.h"
#import "SLSDeviceUtils.h"
#import "HttpConfigProxy.h"
#import "NSString+SLS.h"

@interface SLSCocoa ()
@property(atomic, assign) BOOL hasInitialize;
@property(nonatomic, copy) SLSCredentials *credentials;
@property(nonatomic, strong) SLSConfiguration *configuration;
@property(nonatomic, strong) NSMutableArray<id<SLSFeatureProtocol>> *features;
@property(nonatomic, strong) SLSExtraProvider *extraProvider;

- (void) initializeDefaultSpanProvider;
- (void) initializeSdkSender;

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

- (BOOL) initialize: (SLSCredentials *) credentials configuration: (void (^)(SLSConfiguration *configuration)) configuration {
    if (!configuration) {
        return NO;
    }
    
    if (_hasInitialize) {
        return NO;
    }
    
    _credentials = credentials;
    _configuration = [[SLSConfiguration alloc] initWithProcessor:[SLSSdkSender sender]];
    configuration(_configuration);
    [self initializeDefaultSpanProvider];
    [self initializeSdkSender];
    
    if (_configuration.enableCrashReporter || _configuration.enableBlockDetection) {
        [self initFeature: @"SLSCrashReporterFeature"];
    }
    
    if (_configuration.enableNetworkDiagnosis) { 
        [self initFeature: @"SLSNetworkDiagnosisFeature"];
    }
    
    _hasInitialize = YES;
    return YES;
}

- (void) initializeDefaultSpanProvider {
    SLSSpanProviderDelegate *delegate = [SLSSpanProviderDelegate provider:_configuration credentials:_credentials extraProvider:_extraProvider];
    _configuration.spanProvider = delegate;
}
- (void) initializeSdkSender {
    SLSSdkSender *sender = (SLSSdkSender *)_configuration.spanProcessor;
    [sender initialize: _credentials];
}

- (void) initFeature: (NSString *) clazzName {
    if (!clazzName || clazzName.length <= 0) {
        return;
    }
    
    Class clazz = NSClassFromString(clazzName);
    if (!clazz || ![clazz conformsToProtocol:@protocol(SLSFeatureProtocol)]) {
        return;
    }
    
    id<SLSFeatureProtocol> feature = [[clazz alloc] init];
    if (!feature) {
        return;
    }
    
    [feature initialize:_credentials configuration:_configuration];
    
    [_features addObject:feature];
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
    
    [(SLSSdkSender *) _configuration.spanProcessor setCredentials:credentials];
    
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

@end

#pragma mark - SLSSpanProviderDelegate
@interface SLSSpanProviderDelegate ()
@property(nonatomic, strong) SLSConfiguration *configuration;
@property(nonatomic, strong) SLSCredentials *credentials;
@property(nonatomic, strong) id<SLSSpanProviderProtocol> spanProvider;
@property(nonatomic, strong) SLSExtraProvider *extraProvider;
- (instancetype) initWithConfiguration: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials extraProvider: (SLSExtraProvider *)extraProvider;
- (void) provideExtra: (NSMutableArray<SLSAttribute *> *)attributes;
@end

static SLSResource *DEFAULT_RESOURCE;

@implementation SLSSpanProviderDelegate

- (instancetype) initWithConfiguration: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials extraProvider: (SLSExtraProvider *)extraProvider {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _credentials = credentials;
        _spanProvider = configuration.spanProvider;
        _extraProvider = extraProvider;
        
        if (!DEFAULT_RESOURCE) {
            DEFAULT_RESOURCE = [[SLSResource alloc] init];
            [DEFAULT_RESOURCE add:@"sdk.language" value:@"Objective-C"];
            [DEFAULT_RESOURCE add:@"host.name" value:@"iOS"];
            
            // device specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/device.md
            [DEFAULT_RESOURCE add:@"device.id" value:[Utdid getUtdid]];
            [DEFAULT_RESOURCE add:@"device.model.identifier" value:[SLSDeviceUtils getDeviceModelIdentifier]];
            [DEFAULT_RESOURCE add:@"device.model.name" value:[SLSDeviceUtils getDeviceModelIdentifier]];
            [DEFAULT_RESOURCE add:@"device.manufacturer" value:@"Apple"];
            [DEFAULT_RESOURCE add:@"device.resolution" value:[SLSDeviceUtils getResolution]];
            
            // os specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/os.md
    #if SLS_HAS_UIKIT
            NSString *systemName = [[UIDevice currentDevice] systemName];
            NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    #else
            NSString *systemName = [[NSProcessInfo processInfo] operatingSystemName];
            NSString *systemVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
    #endif
            [DEFAULT_RESOURCE add:@"os.type" value: @"darwin"];
            [DEFAULT_RESOURCE add:@"os.description" value: [NSString stringWithFormat:@"%@ %@", systemName, systemVersion]];
            [DEFAULT_RESOURCE add:@"os.name" value: @"iOS"];
            [DEFAULT_RESOURCE add:@"os.version" value: systemVersion];
            [DEFAULT_RESOURCE add:@"os.root" value: [SLSDeviceUtils isJailBreak]];
        //        @"os.sdk": [[TelemetryAttributeValue alloc] initWithStringValue:@"iOS"],
            
            // host specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/host.md
            [DEFAULT_RESOURCE add:@"host.name" value: @"iOS"];
            [DEFAULT_RESOURCE add:@"host.type" value: systemName];
            [DEFAULT_RESOURCE add:@"host.arch" value: [SLSDeviceUtils getCPUArch]];
            
            [DEFAULT_RESOURCE add:@"sls.sdk.language" value: @"Objective-C"];
            [DEFAULT_RESOURCE add:@"sls.sdk.name" value: @"tracesdk"];
            [DEFAULT_RESOURCE add:@"sls.sdk.version" value: [[HttpConfigProxy sharedInstance] getVersion]];
            
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [infoDictionary objectForKey:@"CFBundleName"];
            }
            NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            NSString *buildCode = [infoDictionary objectForKey:@"CFBundleVersion"];
            
            [DEFAULT_RESOURCE add:@"app.version" value:(!appVersion ? @"-" : appVersion)];
            [DEFAULT_RESOURCE add:@"app.build_code" value:(!buildCode ? @"-" : buildCode)];
            [DEFAULT_RESOURCE add:@"app.name" value:(!appName ? @"-" : appName)];
            
            [DEFAULT_RESOURCE add:@"net.access" value: [SLSDeviceUtils getNetworkTypeName]];
            [DEFAULT_RESOURCE add:@"net.access_subtype" value: [SLSDeviceUtils getNetworkSubTypeName]];
            [DEFAULT_RESOURCE add:@"carrier" value: [SLSDeviceUtils getCarrier]];
        }
    }
    return self;
}

+ (instancetype) provider: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials extraProvider: (SLSExtraProvider *)extraProvider {
    return [[SLSSpanProviderDelegate alloc] initWithConfiguration:configuration credentials:credentials extraProvider:extraProvider];
}


- (SLSResource *)provideResource {
    return [DEFAULT_RESOURCE copy];
}

- (NSArray<SLSAttribute *> *)provideAttribute{
    NSMutableArray<SLSAttribute*> *attributes =
    (NSMutableArray<SLSAttribute*> *) [SLSAttribute of:
                                               //            [SLSKeyValue create:@"page.name" value:([SLSAppUtils sharedInstance].foreground ? @"true" : @"false")],
                                           [SLSKeyValue create:@"foreground" value:([SLSAppUtils sharedInstance].foreground ? @"true" : @"false")],
                                           [SLSKeyValue create:@"instance" value:_credentials.instanceId],
                                           [SLSKeyValue create:@"env" value:(_configuration.env ? _configuration.env : @"")],
                                           nil
    ];
    
    [self provideExtra:attributes];
    
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
    [_dict setObject:value forKey:key];
}
- (void) setExtra: (NSString *)key dictValue: (NSDictionary<NSString *, NSString *> *)value {
    if (![value isKindOfClass:[NSDictionary<NSString *, NSString *> class]]) {
        return;
    }

    [_dict setObject:value forKey:key];
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
