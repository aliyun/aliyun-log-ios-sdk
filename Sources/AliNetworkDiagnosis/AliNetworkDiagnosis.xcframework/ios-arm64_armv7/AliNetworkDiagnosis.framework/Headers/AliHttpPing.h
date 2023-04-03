//
//  AliHttpPing.h
//  AliNetworkDiagnosis
//
//  Created by colin on 2021/9/13.
//

#import <Foundation/Foundation.h>

@interface AliHttpCredential : NSObject
// 客户端提供凭证，供服务器认证客户端时使用
@property (nonatomic, strong) NSURLCredential* clientCredential;
// 服务端凭证，供客户端认证服务器时使用
@property (nonatomic, strong) NSURLCredential* serverCredential;
@end

@protocol AliHttpCredentialDelegate <NSObject>
- (AliHttpCredential*)getHttpCredential:(NSString*)url context:(id)context;
@end

@interface AliHttpPingResult : NSObject
//客户端发起请求的时间
@property (nonatomic, assign) UInt64 startDate;
//客户端开始请求到开始dns解析的等待时间,单位ms
@property (nonatomic, assign) int waitDnsTime;
//DNS 解析耗时
@property (nonatomic, assign) int dnsTime;
//tcp 三次握手耗时,单位ms
@property (nonatomic, assign) int tcpTime;
//ssl 握手耗时
@property (nonatomic, assign) int sslTime;
//首包耗时 从http请求到收到首包 不包含dns,tcp和ssl耗时
@property (nonatomic, assign) int firstByteTime;
//所有http payload耗时 从http请求到收到结束 不包含dns,tcp和ssl耗时
@property (nonatomic, assign) int allByteTime;
//一个完整请求的耗时,单位ms
@property (nonatomic, assign) int requestTime;
//http 响应码
@property (nonatomic, assign) NSUInteger httpCode;
//连接复用
@property (nonatomic, assign) BOOL reusedConnection;
//发送的字节数
@property (nonatomic, assign) int sendBytes;
//接收的字节数
@property (nonatomic, assign) int receiveBytes;

@property (nonatomic, strong) NSString *httpProtocol;
@property (nonatomic, strong) NSString *remoteAddr;
@property (nonatomic, strong) NSString *rdr_location;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, assign) NSUInteger errCode;
@property (nonatomic, strong) NSString *errDomain;
@property (nonatomic, strong) NSString *errDesc;
@end

typedef void (^AliHttpPingCompleteHandler)(id context, NSString *traceID, AliHttpPingResult *result);


@interface AliHttpPingConfig : NSObject
@property NSString* url;
@property NSString* traceId;
@property id context;
@property AliHttpPingCompleteHandler complete;
@property NSString* src;
@property NSURLCredential* clientCredential;
@property NSURLCredential* serverCredential;

-(instancetype)init:(NSString*)url
            traceId:(NSString*)traceId
            context:(id)context
           complete:(AliHttpPingCompleteHandler)complete;

-(instancetype)init:(NSString*)url
            traceId:(NSString*)traceId
clientCredential:(NSURLCredential*)clientCredential
serverCredential:(NSURLCredential*)serverCredential
            context:(id)context
           complete:(AliHttpPingCompleteHandler)complete;
@end

@interface  AliHttpPing : NSObject <NSURLSessionTaskDelegate>
+(void)start:(NSString*)url
     traceId:(NSString*)traceId
     context:(id)context
    complete:(AliHttpPingCompleteHandler)complete;
+(void)execute:(AliHttpPingConfig*)config;
@end
