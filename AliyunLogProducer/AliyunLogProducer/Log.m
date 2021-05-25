//
//  Log.m
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Log.h"

@interface Log ()

@end

@implementation Log

- (id) init
{
    if (self = [super init])
    {
        self->logTime = [[NSDate date] timeIntervalSince1970];
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

- (void)SetTime:(unsigned int) logTime
{
    self->logTime = logTime;
}

@end
