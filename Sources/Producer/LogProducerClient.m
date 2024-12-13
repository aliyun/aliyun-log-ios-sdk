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
#import <AliyunLogProducer/Log.h>
#import "TimeUtils.h"

@interface LogProducerClient ()

@end

@implementation LogProducerClient

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig
{
    return [self initWithLogProducerConfig:logProducerConfig callback:nil];
}

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig callback:(on_log_producer_send_done_function)callback
{
    return [self initWithLogProducerConfig:logProducerConfig callback:callback userparams:NULL];
}

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig callback:(on_log_producer_send_done_function)callback userparams: (NSObject *)params
{
    if (self = [super init])
    {
        self->config = logProducerConfig->config;
        self->producer = create_log_producer(logProducerConfig->config, *callback, (nil == params ? nil : (__bridge void *)(params)));
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
    CFRelease(self->config->user_params);
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
    NSMutableDictionary *logContents = [log getContent];
    int pairCount = (int)[logContents count];
        
    char **keyArray = (char **)malloc(sizeof(char *)*(pairCount));
    char **valueArray = (char **)malloc(sizeof(char *)*(pairCount));
    
    int32_t *keyCountArray = (int32_t*)malloc(sizeof(int32_t)*(pairCount));
    int32_t *valueCountArray = (int32_t*)malloc(sizeof(int32_t)*(pairCount));
    
    
    int ids = 0;
    for (NSString *key in logContents) {
        NSString *string = nil;
        id value = logContents[key];
        if ([value isKindOfClass:[NSNumber class]]) {
            string = [value stringValue];
        } else if ([value isKindOfClass: [NSString class]]){
            string = value;
        } else {
            continue;
        }
        
        char* keyChar=[self convertToChar:key];
        char* valueChar=[self convertToChar:string];

        keyArray[ids] = keyChar;
        valueArray[ids] = valueChar;
        keyCountArray[ids] = (int32_t)strlen(keyChar);
        valueCountArray[ids] = (int32_t)strlen(valueChar);
        
        ids = ids + 1;
    }
    log_producer_result res = log_producer_client_add_log_with_len_time_int32(self->client, [log getTime], pairCount, keyArray, keyCountArray, valueArray, valueCountArray, flush);
    
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
//    NSUInteger len = [strtemp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
//    if (len > 1000000) return strdup([strtemp UTF8String]);
//    char cStr [len];
//    [strtemp getCString:cStr maxLength:len encoding:NSUTF8StringEncoding];
//    return strdup(cStr);


    NSUInteger len = [strtemp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    // the limit on stack size will cause crash
    // https://github.com/CocoaLumberjack/CocoaLumberjack/issues/38
    char* cStr = malloc(sizeof(char) * len);
    [strtemp getCString:cStr maxLength:len encoding:NSUTF8StringEncoding];
    return cStr;
}

@end

