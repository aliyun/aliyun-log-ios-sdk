//
//  AliUdpDetect.h
//  AliNetworkDiagnosis
//
//  Created by  yangrunmin on 2023/4/19.
//

#import <Foundation/Foundation.h>
#import <AliNetworkDiagnosis/AliProtocols.h>

#define MAX_SEND_BUF_SIZE 2400
#define MAX_RECV_BUF_SIZE 8000

@interface AliUdpDetectResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSString* ip;
@property (readonly) NSString* traceID;
@property (readonly) NSString* networkInterface;
@property (readonly) NSString* payload;
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

typedef void (^AliUdpDetectCompleteHandler)(id context, NSString *traceID, AliUdpDetectResult *result);
// results: AliUdpDetectResult数组
typedef void (^AliUdpDetectCombineCompleteHandler)(id context, NSString *traceID, NSMutableArray<AliUdpDetectResult*> *results);

@interface AliUdpDetectConfig : NSObject
@property NSString* host;
@property NSInteger timeout;
@property AliNetDiagNetworkInterfaceType interfaceType;
@property NSString* payload;
@property NSInteger prefer;
@property (nonatomic, strong) id context;
@property NSString* traceID;
@property NSString* src;

@property NSInteger port;
@property NSInteger count;
@property NSInteger interval;
@property AliUdpDetectCompleteHandler complete;
@property AliUdpDetectCombineCompleteHandler combineComplete;

-(instancetype)init:(NSString*)host
            timeout:(NSInteger)timeout
      interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType
            payload:(NSString*)payload
             prefer:(NSInteger)prefer
            context:(id)context
            traceID:(NSString*)traceID
               port:(NSInteger)port
              count:(NSInteger)count
           interval:(NSInteger)interval
           complete:(AliUdpDetectCompleteHandler)complete
    combineComplete:(AliUdpDetectCombineCompleteHandler)combineComplete;
@end

@interface AliUdpDetect : NSObject <AliStopDelegate>

/**
 *    default port is --
 *
 *    @param host     domain or ip
 *    @param output   output logger
 *    @param complete complete callback, maybe null
 *
 */
//+ (NSArray<AliUdpDetect*>*)startInstance:(NSString*)host
//                 port:(NSUInteger)port
//                count:(NSInteger)count
//            interval:(NSInteger)interval
//              traceID:(NSString*)traceID
//              context:(id)context
//             complete:(AliUdpDetectCompleteHandler)complete
//        interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType;
+(void)execute:(AliUdpDetectConfig*)config;
- (void)stop;
-(void)setExInfo:(NSDictionary*)info;
@end


