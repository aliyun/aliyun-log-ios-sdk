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

- (void) ping: (NSString *) domain callback: (SLSNetworkDiagnosisCallBack) callback {
    [AliPing start:domain size:10 traceID:[self generateId] context:[self class] output:nil complete:^(id context, NSString *traceID, AliPingResult *result) {
        NSDictionary *dictionary = @{
            @"code": [NSString stringWithFormat:@"%lu", result.code],
            @"traceID": result.traceID ? result.traceID : @"",
            @"networkInterface": result.networkInterface,
            @"ip": result.ip ? result.ip : @"",
            @"size": [NSString stringWithFormat:@"%lu", result.size],
            @"maxRtt": [NSString stringWithFormat:@"%f", result.maxRtt],
            @"minRtt": [NSString stringWithFormat:@"%f", result.minRtt],
            @"avgRtt": [NSString stringWithFormat:@"%f", result.avgRtt],
            @"loss": [NSString stringWithFormat:@"%lu", result.loss],
            @"count": [NSString stringWithFormat:@"%lu", result.count],
            @"totalTime": [NSString stringWithFormat:@"%f", result.totalTime],
            @"stddev": [NSString stringWithFormat:@"%f", result.stddev],
            @"errMsg": result.errMsg ? result.errMsg : @"",
        };
        SLSLogV(@"ping result: %@", dictionary);
        [self report:dictionary method:@"PING"];
        
        callback([SLSNetworkDiagnosisResult successWithDict:dictionary]);
    }];
}

- (void) tcpPing: (NSString *) host port: (int) port callback: (SLSNetworkDiagnosisCallBack) callback {
    [AliTcpPing start:host port:port count:10 traceID:[self generateId] context:[self class] complete:^(id context, NSString *traceID, NSMutableArray<AliTcpPingResult *> *results) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:results.count];
        for (AliTcpPingResult *result in results) {
            NSDictionary *dictionary = @{
                @"code": [NSString stringWithFormat:@"%lu", result.code],
                @"ip": result.ip ? result.ip : @"",
                @"traceID": result.traceID ? result.traceID : @"",
                @"networkInterface": result.networkInterface,
                @"maxTime": [NSString stringWithFormat:@"%f", result.maxTime],
                @"minTime": [NSString stringWithFormat:@"%f", result.minTime],
                @"avgTime": [NSString stringWithFormat:@"%f", result.avgTime],
                @"loss": [NSString stringWithFormat:@"%lu", result.loss],
                @"count": [NSString stringWithFormat:@"%lu", result.count],
                @"totalTime": [NSString stringWithFormat:@"%f", result.totalTime],
                @"stddev": [NSString stringWithFormat:@"%f", result.stddev],
                @"errMsg": result.errMsg ? result.errMsg : @"",
            };
            SLSLogV(@"tcp ping result: %@", dictionary);
            [array addObject:dictionary];
            [self report:dictionary method:@"TCPPING"];
        }
        
        callback([SLSNetworkDiagnosisResult successWithArray:array]);
    }];
}

- (void) mtr: (NSString *) host callback: (SLSNetworkDiagnosisCallBack) callback {
    [AliMTR start:host maxTtl:30 maxPaths:1 maxTimesEachIP:10 timeout:1*1000 context:[self class] traceID:[self generateId] complete:^(id context, NSString *traceID, NSMutableArray<AliMTRResult *> *results) {
        for (AliMTRResult * result in results) {
            SLSLogV(@"mtr result: %@", result.content);

            [self reportWithString:result.content method:@"MTR"];
            callback([SLSNetworkDiagnosisResult success:result.content]);
        }
    }];
}

- (void) httpPing: (NSString *)domain callback: (SLSNetworkDiagnosisCallBack) callback {
    [AliHttpPing start:domain traceId:[self generateId] context:[self class] complete:^(id context, NSString *traceID, AliHttpPingResult *result) {
        NSDictionary *dictionary = @{
            @"startDate": [NSString stringWithFormat:@"%llu", result.startDate],
            @"waitDnsTime": [NSString stringWithFormat:@"%d", result.waitDnsTime],
            @"dnsTime": [NSString stringWithFormat:@"%d", result.dnsTime],
            @"tcpTime": [NSString stringWithFormat:@"%d", result.tcpTime],
            @"sslTime": [NSString stringWithFormat:@"%d", result.sslTime],
            @"firstByteTime": [NSString stringWithFormat:@"%d", result.firstByteTime],
            @"allByteTime": [NSString stringWithFormat:@"%d", result.allByteTime],
            @"requestTime": [NSString stringWithFormat:@"%d", result.requestTime],
            @"httpCode": [NSString stringWithFormat:@"%ld", result.httpCode],
            @"reusedConnection": result.reusedConnection ? @"true": @"false",
            @"sendBytes": [NSString stringWithFormat:@"%d", result.sendBytes],
            @"receiveBytes": [NSString stringWithFormat:@"%d", result.receiveBytes],
            @"httpProtocol": result.httpProtocol ? result.httpProtocol : @"",
            @"remoteAddr": result.remoteAddr ? result.remoteAddr : @"",
            @"errCode": [NSString stringWithFormat:@"%ld", result.errCode],
            @"errDomain": result.errDomain ? result.errDomain : @"",
            @"errDesc": result.errDesc ? result.errDesc : @""
        };
        SLSLogV(@"http ping result: %@", dictionary);
        
        [self report:dictionary method:@"HTTP"];
        
        callback([SLSNetworkDiagnosisResult successWithDict:dictionary]);
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
    
    BOOL result = [_sender sendDada:tcdata];
    
    return result;
}
@end
