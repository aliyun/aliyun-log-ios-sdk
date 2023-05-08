//
//  AliTcpPing.h
//  NetDiag
//
//

#import <AliNetworkDiagnosis/AliProtocols.h>

#import <Foundation/Foundation.h>

@interface AliTcpPingResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSString* ip;
@property (readonly) NSString* traceID;
@property (readonly) NSString* networkInterface;
@property (readonly) NSTimeInterval maxTime;
@property (readonly) NSTimeInterval minTime;
@property (readonly) NSTimeInterval avgTime;
@property (readonly) NSInteger loss;
@property (readonly) NSInteger count;
@property (readonly) NSTimeInterval totalTime;
@property (readonly) NSTimeInterval stddev;
@property (nonatomic,strong) NSString* errMsg;
@property (nonatomic,strong) NSString* content;
- (NSString*)description;

@end

typedef void (^AliTcpPingCompleteHandler)(id context, NSString *traceID, AliTcpPingResult *result);
// results: AliTcpPingResult数组
typedef void (^AliTcpPingCombineCompleteHandler)(id context, NSString *traceID, NSMutableArray<AliTcpPingResult*> *results);

@interface AliTcpPingConfig : NSObject
@property NSString* host;
@property NSInteger timeout;
@property AliNetDiagNetworkInterfaceType interfaceType;
@property NSInteger prefer;
@property (nonatomic, strong) id context;
@property NSString* traceID;
@property NSString* src;

@property NSInteger port;
@property NSInteger count;
@property NSInteger interval;
@property AliTcpPingCompleteHandler complete;
@property AliTcpPingCombineCompleteHandler combineComplete;

-(instancetype)init:(NSString*)host
            timeout:(NSInteger)timeout
      interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType
             prefer:(NSInteger)prefer
            context:(id)context
            traceID:(NSString*)traceID
               port:(NSInteger)port
              count:(NSInteger)count
           interval:(NSInteger)interval
           complete:(AliTcpPingCompleteHandler)complete
    combineComplete:(AliTcpPingCombineCompleteHandler)combineComplete;
@end

@interface AliTcpPing : NSObject <AliStopDelegate>

/**
 *    default port is 80
 *
 *    @param host     domain or ip
 *    @param output   output logger
 *    @param complete complete callback, maybe null
 *
 */
+ (void)start:(NSString*)host
               output:(id<AliOutputDelegate>)output
             complete:(AliTcpPingCompleteHandler)complete;

+ (void)start:(NSString*)host
                 port:(NSUInteger)port
                count:(NSInteger)count
              traceID:(NSString*)traceID
              context:(id)context
               output:(id<AliOutputDelegate>)output
             complete:(AliTcpPingCompleteHandler)complete;

+ (void)start:(NSString*)host
                 port:(NSUInteger)port
                count:(NSInteger)count
              traceID:(NSString*)traceID
              context:(id)context
             complete:(AliTcpPingCombineCompleteHandler)complete;

+ (void)start:(NSString*)host
                 port:(NSUInteger)port
                count:(NSInteger)count
              traceID:(NSString*)traceID
              context:(id)context
             complete:(AliTcpPingCompleteHandler)complete
        interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType;

+ (NSArray<AliTcpPing*>*)startInstance:(NSString*)host
                 port:(NSUInteger)port
                count:(NSInteger)count
            interval:(NSInteger)interval
              traceID:(NSString*)traceID
              context:(id)context
             complete:(AliTcpPingCompleteHandler)complete
        interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType;
+(void)execute:(AliTcpPingConfig*)config;
- (void)stop;
-(void)setExInfo:(NSDictionary*)info;
@end
