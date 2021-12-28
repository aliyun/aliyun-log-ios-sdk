//
//  AliTcpPing.h
//  NetDiag
//
//  Created by bailong on 16/1/26.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "AliProtocols.h"
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
- (NSString*)description;

@end

typedef void (^AliTcpPingCompleteHandler)(id context, NSString *traceID, AliTcpPingResult *result);
// results: AliTcpPingResult数组
typedef void (^AliTcpPingCombineCompleteHandler)(id context, NSString *traceID, NSMutableArray<AliTcpPingResult*> *results);

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

- (void)stop;
-(void)setExInfo:(NSDictionary*)info;
@end
