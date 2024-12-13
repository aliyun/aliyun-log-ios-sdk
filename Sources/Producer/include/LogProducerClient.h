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
#import "LogProducerConfig.h"
#import <AliyunLogProducer/Log.h>

typedef void (^AddLogInterceptor)(Log *log);

@interface LogProducerClient : NSObject
{
    @private log_producer* producer;
    @private log_producer_config* config;
    @private log_producer_client* client;
    @private BOOL _enableTrack;
    @private BOOL enable;
}

typedef NS_ENUM(NSInteger, LogProducerResult) {
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
    LogProducerParametersInvalid,
    LogProducerPERSISTENT_Error = 99
};

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig;

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig callback:(on_log_producer_send_done_function)callback;

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig callback:(on_log_producer_send_done_function)callback userparams: (NSObject *)params;

- (void)DestroyLogProducer;

- (LogProducerResult)AddLog:(Log *) log;

- (LogProducerResult)AddLog:(Log *) log flush:(int) flush;

@end
