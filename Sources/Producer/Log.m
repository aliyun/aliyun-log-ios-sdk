//
//  Log.m
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunLogProducer/Log.h>
#import "TimeUtils.h"
#import "SLSProducer.h"

@interface Log ()
@property (nonatomic, assign) unsigned int logTime;
@property (nonatomic, strong) NSMutableDictionary *content;
- (BOOL) checkValue: (NSString *)value;
@end

@implementation Log

- (id) init
{
    if (self = [super init])
    {
        _logTime = (unsigned int) [TimeUtils getTimeInMilliis];
        _content = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (instancetype) log {
    return [[Log alloc] init];
}

- (BOOL) checkValue:(NSString *)value {
    return value && [value isKindOfClass:[NSString class]];
}

- (void)PutContent:(NSString *) key value:(NSString *)value
{
    [self putContent:key value:value];
}

- (void) putContent: (NSString *) key value: (NSString *) value {
    if ([self checkValue:key] && [self checkValue:value]) {
        [_content setObject:value forKey:key];
    }
}

- (BOOL) putContents: (NSDictionary *) dict {
    if (!dict) {
        return NO;
    }
    
    NSDictionary *tmp = [NSDictionary dictionaryWithDictionary:dict];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    
    BOOL error = NO;
    id value = nil;
    for (id key in tmp.allKeys) {
        if (![key isKindOfClass:[NSString class]]) {
            error = YES;
            break;
        }
        
        value = [tmp objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [newDict setObject:value forKey:key];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            [newDict setObject:[value stringValue] forKey:key];
        } else if ([value isKindOfClass:[NSNull class]]) {
            [newDict setObject:@"null" forKey:key];
        } else if (([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]])
                   && [NSJSONSerialization isValidJSONObject:value]) {
            [newDict setObject:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:value
                                                                                              options:kNilOptions
                                                                                                error:nil
                                                              ]
                                                     encoding:NSUTF8StringEncoding]
                        forKey:key
            ];
        } else {
            error = YES;
            break;
        }
    }
    
    if (!error) {
        [_content addEntriesFromDictionary:newDict];
    } else {
        SLSLog(@"Your NSDictionary is not support convert to JSON, all values will not be added, please check your data.");
    }
    
    return error;
}

- (void) putContent: (NSString *) key intValue: (int) value {
    if ([self checkValue:key]) {
        [_content setObject:[NSString stringWithFormat:@"%d", value] forKey:key];
    }
}

- (void) putContent: (NSString *) key longValue: (long) value {
    if ([self checkValue:key]) {
        [_content setObject:[NSString stringWithFormat:@"%ld", value] forKey:key];
    }
}

- (void) putContent: (NSString *) key longlongValue: (long long) value {
    if ([self checkValue:key]) {
        [_content setObject:[NSString stringWithFormat:@"%lld", value] forKey:key];
    }
}

- (void) putContent: (NSString *) key floatValue: (float) value {
    if ([self checkValue:key]) {
        [_content setObject:[NSString stringWithFormat:@"%f", value] forKey:key];
    }
}

- (void) putContent: (NSString *) key doubleValue: (double) value {
    if ([self checkValue:key]) {
        [_content setObject:[NSString stringWithFormat:@"%f", value] forKey:key];
    }
}

- (void) putContent: (NSString *) key boolValue: (BOOL) value {
    if ([self checkValue:key]) {
        [NSNumber numberWithBool:YES];
        [_content setObject:(YES == value ? @"YES" : @"NO") forKey:key];
    }
}

- (BOOL) putContent: (NSData *) value {
    if (!value) {
        return NO;
    }
    
    if ([value isKindOfClass:[NSNull class]]) {
        [self putContent:@"data" value:@"null"];
        return YES;
    }
    
    NSError *error = nil;
    id data = [NSJSONSerialization JSONObjectWithData:value
                                              options:kNilOptions
                                                error:&error
    ];
    
    if (nil != error) {
        NSString *string = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
        [self putContent:@"data" value:string];
        return YES;
    }
    
    if ([data isKindOfClass:[NSDictionary class]]) {
        [self putContents:data];
    } else if ([data isKindOfClass:[NSArray class]]) {
        [self putContent:@"data" arrayValue:data];
    } else {
        SLSLog(@"Class %@ not support convert to JSON.", [data class]);
        return NO;
    }
    
    return YES;
}

- (BOOL) putContent: (NSString *) key dataValue: (NSData *)value {
    if ([self checkValue:key] && value && ![value isKindOfClass:[NSNull class]]) {
        [_content setObject:[[NSString alloc] initWithData:value
                                                  encoding:NSUTF8StringEncoding
                            ]
                     forKey:key];
        return YES;
    }
    return NO;
}

- (BOOL) putContent: (NSString *) key arrayValue: (NSArray *) value {
    if ([self checkValue:key] && value && [NSJSONSerialization isValidJSONObject:value]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:value
                                                       options:kNilOptions
                                                         error:&error
        ];
        
        if (nil != error) {
            SLSLog(@"error while deserializing NSArray to JSON. error: %@", error.description);
            return NO;
        }
        
        [_content setObject:[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding
                            ]
                     forKey:key];
        return YES;
    }
    
    return NO;
}


- (BOOL) putContent: (NSString *) key dictValue: (NSDictionary *) value {
    if ([self checkValue:key] && value && [NSJSONSerialization isValidJSONObject:value]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:value
                                                       options:kNilOptions
                                                         error:&error
        ];
        
        if (nil != error) {
            SLSLog(@"error while deserializing NSDictionary to JSON. error: %@", error.description);
            return NO;
        }
        
        [_content setObject:[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding
                            ]
                     forKey:key];
        return YES;
    }
    
    return NO;
}

- (NSMutableDictionary *)getContent
{
    return _content;
}

- (void)SetTime:(unsigned int) logTime
{
    _logTime = logTime;
}

- (unsigned int)getTime
{
    return _logTime;
}

@end
