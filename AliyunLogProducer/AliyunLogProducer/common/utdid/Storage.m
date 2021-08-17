//
//  Storage.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/6/1.
//

#import "Storage.h"

@interface Storage ()
+ (NSString *) getFile;
@end

@implementation Storage
+ (NSString *) getFile {
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"startLogDirectoryMonitor. libraryPath: %@", libraryPath);

    NSString *slsRootDir = [libraryPath stringByAppendingPathComponent:@"sls-ios"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:slsRootDir]) {
        BOOL res = [fileManager createDirectoryAtPath:slsRootDir withIntermediateDirectories:YES attributes:nil error:nil];
        if(!res) {
            return @"";
        }
    }

    return [slsRootDir stringByAppendingPathComponent:@"files"];
}

+ (void) setUtdid: (NSString *)utdid {
    NSString *files = [self getFile];
    if (!files) {
        return;
    }
    
    BOOL res = [utdid writeToFile:files atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *) getUtdid {
    NSString *files = [self getFile];
    if(!files) {
        return nil;
    }
    
    NSString *content = [NSString stringWithContentsOfFile:files encoding:NSUTF8StringEncoding error:nil];
    if(!content) {
        return nil;
    }
    
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    NSString *utdid = nil;
    for (NSString *line in lines) {
        utdid = line;
        break;
    }
    
    return utdid;
}
@end
