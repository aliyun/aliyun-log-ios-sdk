//
//  SLSAdapter.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/19.
//

#import "SLSAdapter.h"
#import "HttpConfigProxy.h"
//#import "SLSLog.h"

@implementation SLSAdapter
- (void) setChannel: (NSString *)channel{
    _channel = channel;
}
- (void) setChannelName: (NSString *)channelName{
    _channelName = channelName;
}
- (void) setUserNick: (NSString *)userNick{
    _userNick = userNick;
}
- (void) setLongLoginNick: (NSString *)longLoginNick{
    _longLoginNick = longLoginNick;
}
- (void) setLoginType: (NSString *)loginType {
    _loginType = loginType;
}

+ (instancetype)sharedInstance {
    static SLSAdapter * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SLSAdapter alloc] init];
    });
    return ins;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _plugins = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token
{
    SLSLogV(@"accessKeyId: %@, secret: %@, token: %@", accessKeyId, accessKeySecret, token);
    
    __block NSString *keyId = accessKeyId;
    __block NSString *keySecret = accessKeySecret;
    __block NSString *keyToken = token;
    
    [_plugins enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IPlugin *plugin = obj;
        [plugin resetSecurityToken:keyId secret:keySecret token:keyToken];
    }];
}

- (void)resetProject:(NSString *)endpoint project:(NSString *)project logstore:(NSString *)logstore
{
    SLSLogV(@"endpoint: %@, project: %@, logstore: %@", endpoint, project, logstore);
    for (IPlugin *plugin in _plugins) {
        [plugin resetProject:endpoint project:project logstore:logstore];
    }
}

- (void)updateConfig:(SLSConfig *)config {
    SLSLogV(@"config: %@", config);
    __block SLSConfig *conf = config;
    
    [_plugins enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IPlugin *plugin = obj;
        [plugin updateConfig:conf];
    }];
}

#pragma mark - init adapter
- (BOOL) initWithSLSConfig:(SLSConfig *)config {
    SLSLog(@"start.");
    
    NSString *version = [[[NSBundle bundleForClass:HttpConfigProxy.self] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [_plugins enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IPlugin *plugin = obj;
        SLSLogV(@"start init plugin: %@", [plugin name]);
        [plugin initWithSLSConfig:config];
        [[HttpConfigProxy sharedInstance] addPluginUserAgent:[plugin name] value:version];
        SLSLogV(@"end init plugin: %@", [plugin name]);
    }];

    SLSLog(@"end.");
    return YES;
}

#pragma mark - plugin manager
- (BOOL) addPlugin: (IPlugin *) plugin {
    if (nil == plugin) {
        return NO;
    }
    
    if ([_plugins containsObject:plugin]) {
        return NO;
    }
    
    [_plugins addObject:plugin];
    return YES;
}
- (void) removePlugin: (IPlugin *) plugin{
    if ([_plugins containsObject:plugin]) {
        [_plugins removeObject:plugin];
    }
}
@end
