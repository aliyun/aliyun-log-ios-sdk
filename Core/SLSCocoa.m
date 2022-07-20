//
//  SLSCocoa.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSCocoa.h"
#import "SLSSdkSender.h"
#import "SLSAppUtils.h"
#import "SLSFeatureProtocol.h"

@interface SLSCocoa ()
@property(atomic, assign) BOOL hasInitialize;
@property(nonatomic, copy) SLSCredentials *credentials;
@property(nonatomic, strong) SLSConfiguration *configuration;
@property(nonatomic, strong) NSMutableArray<id<SLSFeatureProtocol>> * features;

- (void) initializeDefaultSpanProvider;
- (void) initializeSdkSender;

- (void) initFeature: (NSString *) clazzName;
@end

@implementation SLSCocoa

+ (instancetype) sharedInstance {
    static SLSCocoa * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SLSCocoa alloc] init];
    });
    return ins;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _features = [NSMutableArray array];
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
    
    [self initFeature: @"SLSCrashReporterFeature"];
    
    _hasInitialize = YES;
    return YES;
}

- (void) initializeDefaultSpanProvider {
    SLSSpanProviderDelegate *delegate = [SLSSpanProviderDelegate provider:_configuration credentials:_credentials];
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

@end

@interface SLSSpanProviderDelegate ()
@property(nonatomic, strong) SLSConfiguration *configuration;
@property(nonatomic, strong) SLSCredentials *credentials;
@property(nonatomic, strong) id<SLSSpanProviderProtocol> spanProvider;
- (instancetype) initWithConfiguration: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials;
@end

@implementation SLSSpanProviderDelegate


- (instancetype) initWithConfiguration: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _credentials = credentials;
        _spanProvider = configuration.spanProvider;
    }
    return self;
}

+ (instancetype) provider: (SLSConfiguration *)configuration credentials: (SLSCredentials *) credentials {
    return [[SLSSpanProviderDelegate alloc] initWithConfiguration:configuration credentials:credentials];
}


- (SLSResource *)provideResource {
    return [SLSResource getDefault];
}

- (NSArray<SLSAttribute *> *)provideAttribute{
    NSMutableArray<SLSAttribute*> *attributes =  (NSMutableArray<SLSAttribute*> *) [SLSAttribute of:
//            [SLSKeyValue create:@"page.name" value:([SLSAppUtils sharedInstance].foreground ? @"true" : @"false")],
            [SLSKeyValue create:@"foreground" value:([SLSAppUtils sharedInstance].foreground ? @"true" : @"false")],
            [SLSKeyValue create:@"instance" value:_credentials.instanceId],
            [SLSKeyValue create:@"env" value:(_configuration.env ? _configuration.env : @"")],
            nil];
    
    NSArray<SLSAttribute *> *userAttributes = [_spanProvider provideAttribute];
    if (userAttributes) {
        [attributes addObjectsFromArray:userAttributes];
    }
    
    return attributes;
}

@end

