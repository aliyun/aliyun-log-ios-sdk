//
//  AliIntervalDetection.h
//  AliNetworkDiagnosis
//
//  Created by colin on 2021/11/21.
//


#import <Foundation/Foundation.h>

@interface AliIntervalDetection : NSObject

+(void)startIntervalDetection:(NSString*)roomId
                         ping:(NSString*)pingAddress
                          tcp:(NSString*)tcpAddress
                         port:(int)port
                   intervalMs:(int)intervalMs
                      context:(id)context;

+(void)stopIntervalDetection:(NSString*)roomId;

+(void)triggerDetection:(NSString*)roomId
               ping:(NSString*)pingAddress
                tcp:(NSString*)tcpAddress
               port:(int)port
            context:(id)context;

@end
