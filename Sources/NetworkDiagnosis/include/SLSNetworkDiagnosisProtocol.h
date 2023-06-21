//
//  SLSNetworkDiagnosisProtocol.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSURLCredential* _Nullable (^CredentialDelegate)(NSString *url);

#pragma mark -- request & response define
@interface SLSRequest : NSObject
@property(nonatomic, copy) NSString *domain;
@property(nonatomic, strong) id context;
@end

@interface SLSPingRequest : SLSRequest
@property(atomic, assign) int size;
@property(atomic, assign) int maxTimes;
@property(atomic, assign) int timeout;
@property(atomic, assign) BOOL parallel;
@property(nonatomic, strong) NSDictionary<NSString*, NSString*> *extention;
@end

@interface SLSHttpRequest : SLSPingRequest
@property(nonatomic, copy) NSString *ip;
@property(nonatomic) CredentialDelegate credential;
@property(atomic, assign) BOOL headerOnly;
@property(atomic, assign) int downloadBytesLimit;
@end

@interface SLSTcpPingRequest : SLSPingRequest
@property(atomic, assign) NSInteger port;
@end

#define SLS_MTR_PROROCOL_ALL 0
#define SLS_MTR_PROROCOL_ICMP 1
#define SLS_MTR_PROROCOL_UDP 2

@interface SLSMtrRequest : SLSTcpPingRequest
@property(atomic, assign) int maxTTL;
@property(atomic, assign) int maxPaths;
@property(atomic, assign) int protocol;
@end

@interface SLSDnsRequest : SLSMtrRequest
@property(nonatomic, copy) NSString* type;
@property(nonatomic, copy) NSString* nameServer;
@end

@interface SLSResponse : NSObject
@property(nonatomic, readonly, copy) NSString *type;
@property(nonatomic, readonly, copy) NSString *content;
@property(nonatomic, readonly) id context;
@property(nonatomic, readonly, copy) NSString *error;
@end

#pragma mark -- callback
typedef void (^Callback)(NSString *result);
typedef void (^Callback2)(SLSResponse *response);

#pragma mark -- protocol
@protocol SLSNetworkDiagnosisProtocol <NSObject>
- (void) disableExNetworkInfo;
- (void) setPolicyDomain: (NSString *) policyDomain;
- (void) setMultiplePortsDetect: (BOOL) enable;
/**
 * @deprecated use registerCallback2.
 */
- (void) registerCallback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) registerCallback2: (nullable Callback2) callback;
- (void) registerHttpCredentialDelegate: (nullable CredentialDelegate) delegate;

- (void) http2: (SLSHttpRequest *) request;
- (void) http2: (SLSHttpRequest *) request callback: (nullable Callback2) callback;
- (void) http: (NSString *) url DEPRECATED_ATTRIBUTE;
- (void) http: (NSString *) url callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) http: (NSString *) url callback: (nullable Callback) callback credential: (nullable CredentialDelegate)delegate DEPRECATED_ATTRIBUTE;


- (void) ping2: (SLSPingRequest *) request;
- (void) ping2: (SLSPingRequest *) request callback: (nullable Callback2) callback;
/**
 * @deprecated
 */
- (void) ping: (NSString *) domain DEPRECATED_ATTRIBUTE;
- (void) ping: (NSString *) domain callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) ping: (NSString *) domain size: (int) size callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) ping: (NSString *) domain maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) ping: (NSString *) domain size: (int) size maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;

- (void) tcpPing2: (SLSTcpPingRequest *) request;
- (void) tcpPing2: (SLSTcpPingRequest *) request callback: (nullable Callback2) callback;

- (void) tcpPing: (NSString *) domain port: (int) port DEPRECATED_ATTRIBUTE;
- (void) tcpPing: (NSString *) domain port: (int) port callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) tcpPing: (NSString *) domain port: (int) port maxTimes: (int) maxTimes callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) tcpPing: (NSString *) domain port: (int) port maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;

- (void) mtr2: (SLSMtrRequest *) request;
- (void) mtr2: (SLSMtrRequest *) request callback: (nullable Callback2) callback;

- (void) mtr: (NSString *) domain DEPRECATED_ATTRIBUTE;
- (void) mtr: (NSString *) domain callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL maxPaths: (int) maxPaths callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL maxPaths: (int) maxPaths maxTimes: (int) maxTimes callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) mtr: (NSString *) domain maxTTL: (int) maxTTL maxPaths: (int) maxPaths maxTimes: (int) maxTimes timeout: (int) timeout callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;

- (void) dns2: (SLSDnsRequest *) request;
- (void) dns2: (SLSDnsRequest *) request callback: (nullable Callback2) callback;

- (void) dns: (NSString *) domain DEPRECATED_ATTRIBUTE;
- (void) dns: (NSString *) domain callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) dns: (NSString *) nameServer domain: (NSString *) domain callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) dns: (NSString *) nameServer domain: (NSString *) domain type: (NSString *) type callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;
- (void) dns: (NSString *) nameServer domain: (NSString *) domain type: (NSString *) type timeout: (int) timeout callback: (nullable Callback) callback DEPRECATED_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
