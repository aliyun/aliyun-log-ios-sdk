//
//  SLSNetworkDiagnosisProtocol.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Callback)(NSString *result);

@protocol SLSNetworkDiagnosisProtocol <NSObject>
- (void) http: (NSString *) url;
- (void) http: (NSString *) url callback: (nullable Callback) callback;

- (void) ping: (NSString *) domain;
- (void) ping: (NSString *) domain callback: (nullable Callback) callback;
- (void) ping: (NSString *) domain size: (int) size callback: (nullable Callback) callback;
- (void) ping: (NSString *) domain maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback;
- (void) ping: (NSString *) domain size: (int) size maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback;

- (void) tcpPing: (NSString *) domain port: (int) port;
- (void) tcpPing: (NSString *) domain port: (int) port callback: (nullable Callback) callback;
- (void) tcpPing: (NSString *) domain port: (int) port maxTimes: (int) maxTimes callback: (nullable Callback) callback;
- (void) tcpPing: (NSString *) domain port: (int) port maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback;

- (void) mtr: (NSString *) domain;
- (void) mtr: (NSString *) domain callback: (nullable Callback) callback;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL callback: (nullable Callback) callback;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL maxPaths: (int) maxPaths callback: (nullable Callback) callback;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL maxPaths: (int) maxPaths maxTimes: (int) maxTimes callback: (nullable Callback) callback;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL maxPaths: (int) maxPaths maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback;

- (void) dns: (NSString *) domain;
- (void) dns: (NSString *) domain callback: (nullable Callback) callback;
- (void) dns: (NSString *) nameServer domain: (NSString *) domain callback: (nullable Callback) callback;
- (void) dns: (NSString *) nameServer domain: (NSString *) domain type: (NSString *) type callback: (nullable Callback) callback;
- (void) dns: (NSString *) nameServer domain: (NSString *) domain type: (NSString *) type timeout: (int) timeout callback: (nullable Callback) callback;

@end

NS_ASSUME_NONNULL_END
