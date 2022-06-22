//
//  SLSNetworkDiagnosis.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/27.
//

#import "SLSNetworkDiagnosis.h"
#import "TimeUtils.h"
#import <Foundation/Foundation.h>
#import "Utdid.h"
#import <AliNetworkDiagnosis/AliPing.h>
#import <AliNetworkDiagnosis/AliHttpPing.h>
#import <AliNetworkDiagnosis/AliMTR.h>
#import <AliNetworkDiagnosis/AliTcpPing.h>

@interface SLSNetworkDiagnosis ()
@property(nonatomic, strong) NSString *idPrefix;
@property(nonatomic, assign) long index;
@property(nonatomic, strong) NSLock *lock;

@property(nonatomic, strong) SLSConfig *config;
@property(nonatomic, strong) ISender *sender;
@property(nonatomic, strong) NSMutableArray *callbacks;

- (NSString *) generateId;
- (BOOL) reportWithString: (NSString *) data method: (NSString *) method;
- (BOOL) report: (id) data method: (NSString *)method;
@end


@implementation SLSNetworkDiagnosis

+ (instancetype)sharedInstance {
    static SLSNetworkDiagnosis * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SLSNetworkDiagnosis alloc] init];
    });
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _idPrefix = [NSString stringWithFormat:@"%ld", (long) [TimeUtils getTimeInMilliis]];
        _lock = [[NSLock alloc] init];
        _callbacks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *) generateId {
    [_lock lock];
    _index += 1;
    NSString *traceId = [NSString stringWithFormat:@"%@_%ld", _idPrefix, _index];
    [_lock unlock];
    return traceId;
}

- (void) initWithConfig: (SLSConfig *)config sender: (ISender *)sender {
    _config = config;
    _sender = sender;
    [AliNetworkDiagnosis init:_config.pluginAppId deviceId:[Utdid getUtdid] withSiteId:@"public"];
    [AliNetworkDiagnosis registerDelegate: self];
}

- (void)report:(NSString*)content level:(AliNetDiagLogLevel)level context:(id)context {
    if (self.class == context) {
        // ignore
        return;
    }
    
    if (_config.debuggable) {
        SLSLogV("report. content: %@", content);
    }
    
    if (!content) {
        SLSLog("report. content is null");
        return;
    }
    
    NSDictionary *object = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSString *method = [object objectForKey:@"method"];
    if (!method) {
        SLSLog("report. method is null");
        return;
    }
    
    [self reportWithString:content method:method];
    
    for (SLSNetworkDiagnosisCallBack2 callback in _callbacks) {
        callback([SLSNetworkDiagnosisResult success:content]);
    }
}

- (void)log:(NSString*)content level:(AliNetDiagLogLevel)level context:(id)context {
    SLSLog("log. level: %lu, content: %@", (unsigned long)level, content);
}

- (void) updateConfig: (SLSConfig *)config {
    if (config) {
        if (config.channel && ![@"" isEqual:config.channel]) {
            [self.config setChannel:config.channel];
        }

        if (config.channelName && ![@"" isEqual:config.channelName]) {
            [self.config setChannelName:config.channelName];
        }

        if (config.userNick && ![@"" isEqual:config.userNick]) {
            [self.config setUserNick:config.userNick];
        }

        if (config.longLoginNick && ![@"" isEqual:config.longLoginNick]) {
            [self.config setLongLoginNick:config.longLoginNick];
        }

        if (config.userId && ![@"" isEqual:config.userId]) {
            [self.config setUserId:config.userId];
        }

        if (config.longLoginUserId && ![@"" isEqual:config.longLoginUserId]) {
            [self.config setLongLoginUserId:config.longLoginUserId];
        }

        if (config.loginType && ![@"" isEqual:config.loginType]) {
            [self.config setLoginType:config.loginType];
        }

        [self.config setExt:config.ext];
    }
}

- (void) registerPolicy: (NSString *)policy {
    [AliNetworkDiagnosis handlePushMessage:policy type:@"" context:self.class];
}

- (void) registerPolicyWithBuilder: (SLSNetPolicyBuilder *) builder {
    SLSNetPolicy *policy = [builder create];
    NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
    [object setObject:policy.enable ? @"on" : @"off" forKey:@"switch"];
    [object setObject:[NSString stringWithFormat:@"policy_%@", policy.type] forKey:@"type"];
    [object setObject:[NSString stringWithFormat:@"%d", policy.version] forKey:@"version"];
    [object setObject:policy.periodicity ? @"true" : @"false"  forKey:@"periodicity"];
    [object setObject:[NSString stringWithFormat:@"%d", policy.internal] forKey:@"interval"];
    [object setObject:[NSString stringWithFormat:@"%ld", policy.expiration] forKey:@"expiration"];
    [object setObject:[NSString stringWithFormat:@"%d", policy.ratio] forKey:@"ratio"];
    [object setObject:policy.whitelist forKey:@"whitelist"];
    [object setObject:policy.methods forKey:@"methods"];
    
    NSMutableArray *destinationArray = [[NSMutableArray alloc] init];
    for (SLSDestination *des in policy.destination) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"public" forKey:@"siteId"];
        [dict setObject:@"public" forKey:@"az"];
        [dict setObject:des.ips forKey:@"ips"];
        [dict setObject:des.urls forKey:@"urls"];
        
        [destinationArray addObject:dict];
    }
    [object setObject:destinationArray forKey:@"destination"];
    
    [self registerPolicy:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:object options:0 error:nil] encoding:NSUTF8StringEncoding]];
}

- (void) registerCallback: (SLSNetworkDiagnosisCallBack2) callback {
    [_callbacks addObject:callback];
}

- (void) removeCallback: (SLSNetworkDiagnosisCallBack2) callback {
    [_callbacks removeObject:callback];
}

- (void) clearCallback {
    [_callbacks removeAllObjects];
}

- (void) ping: (NSString *) domain {
    [self ping:domain callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        // ignore
    }];
}

- (void) ping: (NSString *) domain callback: (SLSNetworkDiagnosisCallBack) callback {
    [self ping:domain size:10 callback:callback];
}

- (void) ping: (NSString *) domain size:(int) size callback: (SLSNetworkDiagnosisCallBack) callback {
    __weak typeof(self) weakSelf = self;
    SLSNetworkDiagnosisCallBack copyedCallback = [callback copy];
    [AliPing start:domain size:size traceID:[self generateId] context:[self class] output:nil complete:^(id context, NSString *traceID, AliPingResult *result) {
//        SLSLogV(@"ping result: %@", result.content);
        SLSNetworkDiagnosis *strongSelf = weakSelf;
        [strongSelf reportWithString:[result.content copy] method:@"PING"];
        
        if (copyedCallback) {
            copyedCallback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (void) tcpPing: (NSString *) host port: (int) port {
    [self tcpPing:host port:port callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        // ignore
    }];
}

- (void) tcpPing: (NSString *) host port: (int) port callback: (SLSNetworkDiagnosisCallBack) callback {
    [self tcpPing:host port:port count:10 callback:callback];
}

- (void) tcpPing: (NSString *) host port: (int) port count: (int) count callback: (SLSNetworkDiagnosisCallBack) callback {
    __weak typeof(self) weakSelf = self;
    SLSNetworkDiagnosisCallBack copyedCallback = [callback copy];
    [AliTcpPing start:host port:port count:count traceID:[self generateId] context:[self class] output:nil complete:^(id context, NSString *traceID, AliTcpPingResult *result) {
//        SLSLogV(@"tcp ping result: %@", result.content);
        SLSNetworkDiagnosis *strongSelf = weakSelf;
        [strongSelf reportWithString:[result.content copy] method:@"TCPPING"];
        if (copyedCallback) {
            copyedCallback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (void) mtr: (NSString *) host {
    [self mtr:host maxTtl:30 callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        
    }];
}

- (void) mtr: (NSString *) host callback: (SLSNetworkDiagnosisCallBack) callback {
    [self mtr:host maxTtl:30 callback:callback];
}

- (void) mtr: (NSString *) host maxTtl: (int) ttl callback: (SLSNetworkDiagnosisCallBack) callback {
    __weak typeof(self) weakSelf = self;
    SLSNetworkDiagnosisCallBack copyedCallback = [callback copy];
    [AliMTR start:host maxTtl:ttl context:[self class] traceID:[self generateId] output:nil complete:^(id context, NSString *traceID, AliMTRResult *result) {
//        SLSLogV(@"mtr result: %@", result.content);
        SLSNetworkDiagnosis *strongSelf = weakSelf;
        [strongSelf reportWithString:[result.content copy] method:@"MTR"];
        
        if (copyedCallback) {
            copyedCallback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (void) httpPing: (NSString *)domain {
    [self httpPing:domain callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        
    }];
}

- (void) httpPing: (NSString *)domain callback: (SLSNetworkDiagnosisCallBack) callback {
    __weak typeof(self) weakSelf = self;
    SLSNetworkDiagnosisCallBack copyedCallback = [callback copy];
    [AliHttpPing start:domain traceId:[self generateId] context:[self class] complete:^(id context, NSString *traceID, AliHttpPingResult *result) {
//        SLSLogV(@"http ping result: %@", result.content);
        SLSNetworkDiagnosis *strongSelf = weakSelf;
        [strongSelf reportWithString:[result.content copy] method:@"HTTP"];
        
        if (copyedCallback) {
            copyedCallback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (BOOL) report: (id) data method:(NSString *)method {
    return [self reportWithString:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil] encoding:NSUTF8StringEncoding] method:method];
}

- (BOOL) reportWithString: (NSString *) data method: (NSString *) method {
    TCData *tcdata = [TCData createDefaultWithSLSConfig:_config];
    if (tcdata.app_id && [tcdata.app_id containsString:@"@"]) {
        NSRange atRange = [tcdata.app_id rangeOfString:@"@"];
        [tcdata setApp_id:[tcdata.app_id substringWithRange:NSMakeRange(0, atRange.location)]];
    }
    
    [tcdata setReserve6: data];

    NSMutableDictionary *reserves = [NSMutableDictionary dictionary];
    [reserves setObject:[method uppercaseString] forKey:@"method"];

    // put ext fields to reserves
    if (_config.ext) {
        for (NSString *key in _config.ext) {
            [reserves setObject:_config.ext[key] forKey:key];
        }
    }
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:reserves options:0 error:nil];
    tcdata.reserves = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];

    Log *log = [[Log alloc] init];
    NSDictionary *dict = [tcdata toDictionaryWithIgnoreExt:YES];
    for (NSString *key in dict.allKeys) {
        [log PutContent:key value:[dict objectForKey:key]];
    }

    BOOL result = [_sender sendDada:log];
    
    return result;
}
@end
