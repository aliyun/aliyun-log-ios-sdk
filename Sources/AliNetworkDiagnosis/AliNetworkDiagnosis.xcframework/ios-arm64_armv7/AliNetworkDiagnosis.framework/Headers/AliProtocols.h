//
//  AliProtocols.h
//  NetDiag
//
//  Created by bailong on 15/12/30.
//  Copyright © 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <netinet/in.h>

#define __APPLE_USE_RFC_3542 /* for IPv6 definitions on Apple platforms */

union common_sockaddr {
    struct sockaddr sa;
    struct sockaddr_in sin;
    struct sockaddr_in6 sin6;
};
typedef union common_sockaddr sockaddr_any;

static NSString * const CelluarNetworkInterface = @"pdp_ip0";
static NSString * const WiFiNetworkInterface = @"en0";

typedef enum ICMPv4Type {
    kICMPv4TypeEchoReply = 0, // 回显应答
    kICMPv4TypeEchoRequest = 8, // 回显请求
    kICMPv4TypeTimeOut = 11, // 超时
    kICMPv6TypeEchoRequest = 128,
    kICMPv6TypeEchoReply = 129,
    
}ICMPType;

struct IPHeader {
    uint8_t versionAndHeaderLength;
    uint8_t differentiatedServices;
    uint16_t totalLength;
    uint16_t identification;
    uint16_t flagsAndFragmentOffset;
    uint8_t timeToLive;
    uint8_t protocol;
    uint16_t headerChecksum;
    uint8_t sourceAddress[4];
    uint8_t destinationAddress[4];
    // options...
    // data...
};
typedef struct IPHeader IPHeader;

typedef struct ICMPPacket {
    uint8_t type;
    uint8_t code;
    uint16_t checksum;
    uint16_t identifier;
    uint16_t sequenceNumber;
    uint8_t payload[0]; // data, variable length
} ICMPPacket;

typedef struct UDPPacket {
    uint16_t srcport;
    uint16_t dstport;
    uint16_t length;
    uint16_t checksum;
    uint8_t payload[0]; // data, variable length
} UDPPacket;

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
