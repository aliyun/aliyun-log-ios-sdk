//
//  TimeUtils.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/6/8.
//  Copyright © 2021 lichao. All rights reserved.
//

#import "TimeUtils.h"
#import "LogProducerConfig.h"
#import <sys/sysctl.h>

@interface TimeUtils ()
+(NSTimeInterval) elapsedRealtime;

@end

static NSInteger serverTime = 0;
static NSTimeInterval elapsedRealtime = 0;

@implementation TimeUtils
+(void) startUpdateServerTime: (NSString *)endpoint project:(nonnull NSString *)project
{
    NSURL *url = [NSURL URLWithString:endpoint];
    NSString *urlString = [NSString stringWithFormat:@"https://%@.%@/servertime", project, url.host];
//    NSString *url = @"https://cn-shanghai-staging-share.sls.aliyuncs.com/servertime";
    
    
//    NSString *urlString = [NSString stringWithUTF8String:[url UTF8String]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod: @"GET"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request addValue:@"0.6.0" forHTTPHeaderField:@"x-log-apiversion"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (response != nil) {
            NSHTTPURLResponse *httpResponse = response;
            NSDictionary *fields = [httpResponse allHeaderFields];
            NSString *timeVal = fields[@"x-log-time"];
            if ([timeVal length] != 0) {
                NSInteger serverTime = [timeVal integerValue];
                if (serverTime > 1500000000 && serverTime < 4294967294) {
                    [TimeUtils updateServerTime:serverTime];
                }
            }
        }
    }];
}

+(void) updateServerTime: (NSInteger) timeInMillis
{
    serverTime = timeInMillis;
    elapsedRealtime = [self elapsedRealtime];
}
+(NSInteger) getTimeInMilliis
{
    if( 0L == elapsedRealtime) {
        NSInteger time = [[NSDate date] timeIntervalSince1970];
        return time;
    }
    
    NSInteger delta = [self elapsedRealtime] - elapsedRealtime;
    
    return serverTime + delta;
}
+(void) fixTime: (Log *)log
{
    if(!log) {
        return;
    }
    
    NSMutableDictionary *dictionary = [log getContent];
    if (!dictionary || [dictionary count] == 0) {
        return;
    }
    
    if (![dictionary objectForKey:@"local_timestamp"]) {
        return;
    }
    
    NSLog(@"log.getTime: %d", [log getTime]);
    
    NSDate *date = [NSDate date];
    NSString *local_timestamp = [NSString stringWithString:[[log getContent] objectForKey:@"local_timestamp"]];
    NSString *timestamp = [local_timestamp substringWithRange:NSMakeRange(0, 10)];
    NSString *timestampMillisPart = [[NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970] * 1000] substringFromIndex:10];
    local_timestamp = [timestamp stringByAppendingString:timestampMillisPart];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss:SSS"];
    
    date = [NSDate dateWithTimeIntervalSince1970:[local_timestamp doubleValue] / 1000];
    NSString *local_time = [dateFormatter stringFromDate:date];
    
    [log PutContent:@"local_timestamp_fixed" value:local_timestamp];
    [log PutContent:@"local_time_fixed" value:local_time];
}

+ (NSTimeInterval)elapsedRealtime {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);

    struct timeval now;
    struct timezone tz;
    gettimeofday(&now, &tz);

    double uptime = -1;

    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0)
    {
        uptime = now.tv_sec - boottime.tv_sec;
        uptime += (double)(now.tv_usec - boottime.tv_usec) / 1000000.0;
        return uptime;
    }
    
    return [[NSProcessInfo processInfo] systemUptime];
}
@end
