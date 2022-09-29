//
//  LogProducerClient.h
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#ifndef LogProducerClient_h
#define LogProducerClient_h


#endif /* LogProducerClient_h */

#import "log_producer_client.h"
#import "AliyunLogProducerConfig.h"
#import "AliyunLog.h"

typedef void (^AddLogInterceptor)(AliyunLog *log);

@interface AliyunLogProducerClient : NSObject
{
    @private log_producer* producer;
    @private log_producer_client* client;
    @private AddLogInterceptor addLogInterceptor;
    @private BOOL _enableTrack;
}

typedef NS_ENUM(NSInteger, AliyunLogProducerResult) {
    LogProducerOK = 0,
    LogProducerInvalid,
    LogProducerWriteError,
    LogProducerDropError,
    LogProducerSendNetworkError,
    LogProducerSendQuotaError,
    LogProducerSendUnauthorized,
    LogProducerSendServerError,
    LogProducerSendDiscardError,
    LogProducerSendTimeError,
    LogProducerSendExitBufferdF,
    LogProducerPERSISTENT_Error = 99
};

- (id) initWithLogProducerConfig:(AliyunLogProducerConfig *)logProducerConfig;

- (id) initWithLogProducerConfig:(AliyunLogProducerConfig *)logProducerConfig callback:(on_log_producer_send_done_function)callback;

- (void)DestroyLogProducer;

- (AliyunLogProducerResult)AddLog:(AliyunLog *) log;

- (AliyunLogProducerResult)AddLog:(AliyunLog *) log flush:(int) flush;

- (void) setAddLogInterceptor: (AddLogInterceptor *) addLogInterceptor;

@end
