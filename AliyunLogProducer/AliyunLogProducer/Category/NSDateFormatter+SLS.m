//
//  NSDateFormatter+SLS.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/6/23.
//

#import "NSDateFormatter+SLS.h"
@interface NSDateFormatter()
@end

@implementation NSDateFormatter (SLS)
+ (instancetype) sharedInstance {
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formater = [threadDict objectForKey:@"sls_date_formater"];
    if (!formater) {
        @synchronized (self) {
            if (!formater) {
                formater = [[NSDateFormatter alloc] init];
                [formater setTimeZone:[NSTimeZone systemTimeZone]];
                [threadDict setObject:formater forKey:@"sls_date_formater"];
            }
        }
    }
    
    return formater;
}

- (NSDate *) fromString: (NSString *) date {
    [self setDateFormat:@"YYYY-MM-dd HH:mm:ss:SSS"];
    return [self dateFromString:date];
}

- (NSDate *) fromStringZ: (NSString *) date {
    [self setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS Z"];
    return [self dateFromString:date];
}

- (NSString *) fromDate: (NSDate *) date {
    [self setDateFormat:@"YYYY-MM-dd HH:mm:ss:SSS"];
    return [self stringFromDate:date];
}

@end
