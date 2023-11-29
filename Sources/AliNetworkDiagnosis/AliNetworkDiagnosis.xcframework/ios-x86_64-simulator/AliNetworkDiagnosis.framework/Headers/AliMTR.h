//
//  AliMTR.h
//  AliNetworkDiagnosis
//
//  Created by colin on 2021/4/2.
//

#import <Foundation/Foundation.h>

#import <AliNetworkDiagnosis/AliProtocols.h>
#import <AliNetworkDiagnosis/AliDetectConfig.h>
#import <Foundation/Foundation.h>

// all
#define MTR_PROTOCOL_ALL 0
// icmp
#define MTR_PROTOCOL_ICMP 1
// udp
#define MTR_PROTOCOL_UDP 2

@interface AliMTRResult : NSObject

@property (readonly) NSInteger code;
@property (readonly) NSString* host;
@property (readonly) NSString* content;

@end

typedef void (^AliMTRCompleteHandler)(id context, NSString *traceID, AliMTRResult *result);
// results: AliMTRResult数组
typedef void (^AliMTRCombineCompleteHandler)(id context, NSString *traceID, NSMutableArray<AliMTRResult*> *results);

@interface AliMTRConfig : AliDetectConfig

@property NSInteger timeout;
@property AliMTRCompleteHandler complete;
@property AliMTRCombineCompleteHandler combineComplete;
@property NSInteger maxTtl;
@property NSInteger maxPaths;
@property NSInteger maxTimesEachIP;
@property int protocol;
@property BOOL parallel;

-(instancetype)init:(NSString*)host
             maxTtl:(NSInteger)maxTtl
           maxPaths:(NSInteger)maxPaths
      maxTimeEachIP:(NSInteger)maxTimeEachIP
            timeout:(NSInteger)timeout
          interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType
             prefer:(NSInteger)prefer
            context:(id)context
            traceID:(NSString*)traceID
           complete:(AliMTRCompleteHandler)complete
    combineComplete:(AliMTRCombineCompleteHandler)combineComplete;
@end

@interface AliMTR : NSObject <AliStopDelegate>

// param desc:
// host: 必选，需要探测的目标IP或者域名
// context: 非必选，回调上下文，可以为空
// traceID: 非必选，本次任务唯一标识，如果传入nil，会自动生成，回调的时候返回
// output: 非必选，探测执行过程回调，快速返回部分探测结果
// complete: 必选，探测结果回调
// maxTtl: 探测最多跳数
// maxPaths: 探测最多的路径
// maxTimesEachIP: 每跳中的每个IP最多探测次数
// interfaceType: 使用蜂窝或者WiFi网络探测
+ (void)start:(NSString*)host
              context:(id)context
                traceID:(NSString*)traceID
               output:(id<AliOutputDelegate>)output
             complete:(AliMTRCompleteHandler)complete;

+ (void)start:(NSString*)host
               maxTtl:(int)maxTtl
              context:(id)context
              traceID:(NSString*)traceID
               output:(id<AliOutputDelegate>)output
             complete:(AliMTRCompleteHandler)complete;

+ (void)start:(NSString*)host
               maxTtl:(int)maxTtl
            interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType
            maxPaths:(int)maxPaths
            maxTimesEachIP:(int)maxTimesEachIP
            timeout:(int)timeout
              context:(id)context
              traceID:(NSString*)traceID
               output:(id<AliOutputDelegate>)output
             complete:(AliMTRCompleteHandler)complete;

+ (void)start:(NSString*)host
               maxTtl:(int)maxTtl
            maxPaths:(int)maxPaths
            maxTimesEachIP:(int)maxTimesEachIP
            timeout:(int)timeout
              context:(id)context
              traceID:(NSString*)traceID
             complete:(AliMTRCombineCompleteHandler)complete;

+ (NSArray<AliMTR*> *)startInstance:(NSString*)host
               maxTtl:(int)maxTtl
            interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType
            maxPaths:(int)maxPaths
            maxTimesEachIP:(int)maxTimesEachIP
            timeout:(int)timeout
              context:(id)context
              traceID:(NSString*)traceID
               output:(id<AliOutputDelegate>)output
             complete:(AliMTRCompleteHandler)complete;
- (void)stop;

+(void)execute:(AliMTRConfig*)config;
-(void)setExInfo:(NSDictionary*)info;
@end
