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
        producer = create_log_producer(logProducerConfig->config, *callback, nil);
        client = get_log_producer_client(producer, nil);
    }

    return self;
}

- (void)DestroyLogProducer
{
    destroy_log_producer(producer);
}

- (LogProducerResult)AddLog:(Log *) log
{
    return [self AddLog:log flush:1];
}

- (LogProducerResult)AddLog:(Log *) log flush:(int) flush
{
    if (client == NULL || log == nil) {
        return LogProducerInvalid;
    }
    NSMutableDictionary *logContents = log->content;
    int pairCount = (int)[logContents count];
        
    char **keyArray = (char **)malloc(sizeof(char *)*(pairCount));
    char **valueArray = (char **)malloc(sizeof(char *)*(pairCount));
    
    size_t *keyCountArray = (size_t*)malloc(sizeof(size_t)*(pairCount));
    size_t *valueCountArray = (size_t*)malloc(sizeof(size_t)*(pairCount));
    
    
    int ids = 0;
    for (NSString *key in logContents) {
        NSString *value = logContents[key];

        char* keyChar=[self convertToChar:key];
        char* valueChar=[self convertToChar:value];

        keyArray[ids] = keyChar;
        valueArray[ids] = valueChar;
        keyCountArray[ids] = strlen(keyChar);
        valueCountArray[ids] = strlen(valueChar);
        
        ids = ids + 1;
    }
    
    log_producer_result res = log_producer_client_add_log_with_len(client, pairCount, keyArray, keyCountArray, valueArray, valueCountArray, flush);
    
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

-(void)dealloc {
    [self DestroyLogProducer];
}

-(char*)convertToChar:(NSString*)strtemp
{
    NSUInteger arbLength = [strtemp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    char strArb [arbLength];
    [strtemp getCString:strArb maxLength:arbLength encoding:NSUTF8StringEncoding];
    return strdup(strArb);
}

@end

