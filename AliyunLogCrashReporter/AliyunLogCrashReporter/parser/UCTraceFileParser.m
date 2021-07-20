//
//  UCTraceFileParser.m
//  AliyunLogCrashReporter
//
//  Created by gordon on 2021/5/19.
//

#import "UCTraceFileParser.h"
#import <AliyunLogCommon/AliyunLogCommon.h>


@interface UCTraceFileParser ()
- (void) internalParseFileWithType: (NSString *)type andFilePath: (NSString *)filePath;
@end

@implementation UCTraceFileParser

- (void) updateConfig:(SLSConfig *)config {
    [self setConfig:config];
}

- (void) parseFileWithType: (NSString *) type andFilePath: (NSString *) filePath {
    SLSLogV(@"start. tpye: %@, path: %@", type, filePath);
    
    if(type.length == 0) {
        SLSLog(@"type is empty.");
        return;
    }
    
    BOOL isDirectory;
    if(filePath.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory: &isDirectory]) {
        SLSLog(@"file path is empty or file not exists.");
        return;
    }
    
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:NULL];
    for (int count = 0; count < [contents count]; count ++) {
        [self internalParseFileWithType:type andFilePath:[filePath stringByAppendingPathComponent:[contents objectAtIndex:count]]];
    }
    
}

- (void) internalParseFileWithType: (NSString *)type andFilePath: (NSString *)filePath {
    SLSLogV(@"start. type: %@, path: %@", type, filePath);
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    TCData *tcdata = [TCData createDefaultWithSLSConfig:self.config];
    
    NSDictionary *reserves = nil;
    NSString *uuid = @"";
    NSString *time = @"";
    
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        // read uuid from dau file
        if ([line containsString:@"dn"]) {
            NSArray *chunks = [line componentsSeparatedByString:@"`"];
            for (NSString *chunk in chunks) {
                if ([chunk containsString:@"dn"]) {
                    uuid = [chunk componentsSeparatedByString:@"="][1];
                    break;
                }
            }
            break;
        }
        
        // read time from crash file
        if ([line containsString:@"Date/Time:"]) {
            NSArray *chunks = [line componentsSeparatedByString:@"Time:"];
            if (chunks && [chunks count] == 2) {
                time = [chunks objectAtIndex:1];
            }
            break;
        }
    }
    
    if ([type isEqual:@"crash"]) {
        tcdata.event_id = @"61011";
        reserves = @{@"trace_file_name": [filePath lastPathComponent]};
        
        if ([time length] != 0) {
            time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            // time format: 2021-06-09 19:32:17.341 +0800
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS Z"];
            NSDate *date = [dateFormatter dateFromString:time];
            
            tcdata.local_timestamp = [NSString stringWithFormat:@"%0.f", [date timeIntervalSince1970] * 1000];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss:SSS"];
            tcdata.local_time = [dateFormatter stringFromDate:date];
        }
    } else if ([type isEqual:@"crash_stat"]) {
        tcdata.event_id = @"61030";
        reserves = @{@"trace_app_id":self.config.pluginAppId, @"trace_uuid": uuid};
    } else {
        tcdata.event_id = @"-1";
    }
    
    tcdata.reserve6 = content;
    
    if (nil != reserves) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:reserves options:0 error:nil];
        tcdata.reserves = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    
    BOOL res = [self.sender sendDada:tcdata];
    SLSLogV(@"internalParseFileWithType. send res: %d", res);
    
    if (res) {
        res = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        SLSLogV(@"internalParseFileWithType. file remove res: %d", res);
    } else {
        SLSLog(@"data not sent, file will not be removed. file: %@", filePath);
    }
}

@end
