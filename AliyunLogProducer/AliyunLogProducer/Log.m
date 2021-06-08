//
//  Log.m
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Log.h"
#import "TimeUtils.h"

@interface Log ()

@end

@implementation Log

- (id) init
{
    if (self = [super init])
    {
        self->logTime = [TimeUtils getTimeInMilliis];
        self->content = [NSMutableDictionary dictionary];

    }

    return self;
}

- (void)PutContent:(NSString *) key value:(NSString *)value
{
    if (key && value) {
        [self->content setObject:value forKey:key];
    }
}

- (NSMutableDictionary *)getContent
{
    return self->content;
}

- (void)SetTime:(unsigned int) logTime
{
    self->logTime = logTime;
}

- (unsigned int)getTime
{
    return self->logTime;
}

@end
