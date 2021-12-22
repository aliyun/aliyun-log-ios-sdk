//
//  LogProducerClient.m
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogProducerClient.h"
#import "LogProducerConfig.h"
#import "Log.h"
#import "TimeUtils.h"

#if __has_include("LogProducerClient+Bricks.h")
#import "LogProducerClient+Bricks.h"
#import "TCData.h"
#endif


@interface LogProducerClient ()

@end

@implementation LogProducerClient

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig
{
    return [self initWithLogProducerConfig:logProducerConfig callback:nil];
}

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig callback:(on_log_producer_send_done_function)callback
{
    if (self = [super init])
    {
        self->producer = create_log_producer(logProducerConfig->config, *callback, nil);
        self->client = get_log_producer_client(self->producer, nil);
        
        NSString *endpoint = [logProducerConfig getEndpoint];
        NSString *project = [logProducerConfig getProject];
        if ([endpoint length] != 0 && [project length] != 0) {
            [TimeUtils startUpdateServerTime:endpoint project:project];
        }
        enable = YES;
    }

    return self;
}

- (void)DestroyLogProducer
{
    if (!enable) {
        return;
    }
    enable = NO;
    destroy_log_producer(self->producer);
}

- (LogProducerResult)AddLog:(Log *) log
{
    return [self AddLog:log flush:0];
}

- (LogProducerResult)AddLog:(Log *) log flush:(int) flush
{
    if (!enable || self->client == NULL || log == nil) {
        return LogProducerInvalid;
    }
    NSMutableDictionary *logContents = log->content;
    
#if __has_include("LogProducerClient+Bricks.h")
    if (self->_enableTrack) {
        TCData *data = [TCData createDefault];
        NSDictionary *fields = [data toDictionary] ;
        for (id key in fields) {
            [logContents setObject:[fields valueForKey:key] forKey:key];
        }
    } else {
        if(self ->addLogInterceptor) {
            addLogInterceptor(log);
        }
    }
#else
    if(self ->addLogInterceptor) {
        addLogInterceptor(log);
    }
#endif
    
    int pairCount = (int)[logContents count];
        
    char **keyArray = (char **)malloc(sizeof(char *)*(pairCount));
    char **valueArray = (char **)malloc(sizeof(char *)*(pairCount));
    
    int32_t *keyCountArray = (int32_t*)malloc(sizeof(int32_t)*(pairCount));
    int32_t *valueCountArray = (int32_t*)malloc(sizeof(int32_t)*(pairCount));
    
    
    int ids = 0;
    for (NSString *key in logContents) {
        NSString *value = logContents[key];

        char* keyChar=[self convertToChar:key];
        char* valueChar=[self convertToChar:value];

        keyArray[ids] = keyChar;
        valueArray[ids] = valueChar;
        keyCountArray[ids] = (int32_t)strlen(keyChar);
        valueCountArray[ids] = (int32_t)strlen(valueChar);
        
        ids = ids + 1;
    }
    log_producer_result res = log_producer_client_add_log_with_len_time_int32(self->client, log->logTime, pairCount, keyArray, keyCountArray, valueArray, valueCountArray, flush);
    
    for(int i=0;i<pairCount;i++) {
        free(keyArray[i]);
        free(valueArray[i]);
    }
    free(keyArray);
    free(valueArray);
    free(keyCountArray);
    free(valueCountArray);
    return res;
}

-(char*)convertToChar:(NSString*)strtemp
{
    NSUInteger len = [strtemp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    if (len > 1000000) return strdup([strtemp UTF8String]);
    char cStr [len];
    [strtemp getCString:cStr maxLength:len encoding:NSUTF8StringEncoding];
    return strdup(cStr);
}

- (void) setAddLogInterceptor: (AddLogInterceptor *) addLogInterceptor {
    self -> addLogInterceptor = *addLogInterceptor;
}

@end

