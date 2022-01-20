//
//  SLSNetworkDiagnosis.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/27.
//

#import "SLSNetworkDiagnosis.h"
#import "TimeUtils.h"
#import <Foundation/Foundation.h>

@interface SLSNetworkDiagnosis ()
@property(nonatomic, strong) NSString *idPrefix;
@property(nonatomic, assign) long index;
@property(nonatomic, strong) NSLock *lock;

@property(nonatomic, strong) SLSConfig *config;
@property(nonatomic, strong) ISender *sender;

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
        _idPrefix = [NSString stringWithFormat:@"%ld", [TimeUtils getTimeInMilliis]];
        _lock = [[NSLock alloc] init];
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
}

- (void) ping: (NSString *) domain {
    [self ping:domain callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        
    }];
}

- (void) ping: (NSString *) domain callback: (SLSNetworkDiagnosisCallBack) callback {
    [self ping:domain size:10 callback:callback];
}

- (void) ping: (NSString *) domain size:(int) size callback: (SLSNetworkDiagnosisCallBack) callback {
    [AliPing start:domain size:size traceID:[self generateId] context:[self class] output:nil complete:^(id context, NSString *traceID, AliPingResult *result) {
        SLSLogV(@"ping result: %@", result.content);
        [self reportWithString:result.content method:@"PING"];
        
        if (callback) {
         callback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (void) tcpPing: (NSString *) host port: (int) port {
    [self tcpPing:host port:port callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        
    }];
}

- (void) tcpPing: (NSString *) host port: (int) port callback: (SLSNetworkDiagnosisCallBack) callback {
    [self tcpPing:host port:port count:10 callback:callback];
}

- (void) tcpPing: (NSString *) host port: (int) port count: (int) count callback: (SLSNetworkDiagnosisCallBack) callback {
    [AliTcpPing start:host port:port count:count traceID:[self generateId] context:[self class] output:nil complete:^(id context, NSString *traceID, AliTcpPingResult *result) {
        SLSLogV(@"tcp ping result: %@", result.content);
        [self reportWithString:result.content method:@"TCPPING"];
        if (callback) {
            callback([SLSNetworkDiagnosisResult success:result.content]);
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
    [AliMTR start:host maxTtl:ttl context:[self class] traceID:[self generateId] output:nil complete:^(id context, NSString *traceID, AliMTRResult *result) {
        SLSLogV(@"mtr result: %@", result.content);
        [self reportWithString:result.content method:@"MTR"];
        
        if (callback) {
            callback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (void) httpPing: (NSString *)domain {
    [self httpPing:domain callback:^(SLSNetworkDiagnosisResult * _Nonnull result) {
        
    }];
}

- (void) httpPing: (NSString *)domain callback: (SLSNetworkDiagnosisCallBack) callback {
    [AliHttpPing start:domain traceId:[self generateId] context:[self class] complete:^(id context, NSString *traceID, AliHttpPingResult *result) {
        SLSLogV(@"http ping result: %@", result.content);
        
        [self reportWithString:result.content method:@"HTTP"];
        
        if (callback) {
            callback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (BOOL) report: (id) data method:(NSString *)method {
    return [self reportWithString:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil] encoding:NSUTF8StringEncoding] method:method];
}

- (BOOL) reportWithString: (NSString *) data method: (NSString *) method {
    TCData *tcdata = [TCData createDefaultWithSLSConfig:self.config];
    if (tcdata.app_id && [tcdata.app_id containsString:@"@"]) {
        NSRange atRange = [tcdata.app_id rangeOfString:@"@"];
        [tcdata setApp_id:[tcdata.app_id substringWithRange:NSMakeRange(0, atRange.location)]];
    }
    
    [tcdata setReserve6: data];

    NSDictionary *reserves = @{
        @"method": [method uppercaseString]
    };
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:reserves options:0 error:nil];
    tcdata.reserves = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    
    __block Log *log = [[Log alloc] init];
    [[tcdata toDictionary] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [log PutContent:key value:obj];
    }];
    BOOL result = [_sender sendDada:log];
    
    return result;
}
@end
