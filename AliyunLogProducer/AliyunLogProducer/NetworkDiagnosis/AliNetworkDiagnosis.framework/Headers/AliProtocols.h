//
//  AliProtocols.h
//  NetDiag
//
//  Created by bailong on 15/12/30.
//  Copyright © 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString * const CelluarNetworkInterface = @"pdp_ip0";
static NSString * const WiFiNetworkInterface = @"en0";

typedef NS_ENUM(NSUInteger, AliNetDiagNetworkInterfaceType){
    AliNetDiagNetworkInterfaceCelluar   = 10, // 蜂窝网卡
    AliNetDiagNetworkInterfaceWiFi      = 11, // WiFi网卡
    AliNetDiagNetworkInterfaceCurrent   = 20, // 当前网卡
    AliNetDiagNetworkInterfaceDefault   = 30, // 默认网卡
};

@protocol AliStopDelegate <NSObject>

- (void)stop;

@end

@protocol AliOutputDelegate <NSObject>

- (void)write:(NSString*)line context:(id)context traceID:(NSString*)traceID;
@optional
- (void)write:(NSString*)line;


@end

@protocol AliMtrDelegate <NSObject>

- (int)getSendSock:(NSString*)interface protocol:(int)protocol;
- (int)getRecvSock:(NSString*)interface;


@end

/**
 *    中途取消的状态码
 */
extern const NSInteger kAliRequestStoped;
