//
//  SLSCrashReporterFeature.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSCrashReporterFeature.h"
#import "WPKMobi/WPKSetup.h"
#import "Utdid.h"
#import "NSDateFormatter+SLS.h"

typedef void(^directory_changed_block)(NSString*);

@interface SLSCrashReporterFeature ()
@property(nonatomic, strong) NSString *wpkStatLogPath;
@property(nonatomic, strong) NSString *wpkCrashLogPath;

@property(nonatomic, strong) dispatch_source_t crashLogSource;
@property(nonatomic, strong) dispatch_source_t crashStatLogSource;

- (void) observeDirectoryChanged;
- (void) initWPKMobi: (SLSCredentials *) credentials;

- (void) reportState;
- (void) reportCrash;

- (void) reportState: (NSString *) file;
- (void) reportCrash: (NSString *) file;

@end

@implementation SLSCrashReporterFeature

- (NSString *)name {
    return @"crash_reporter";
}

- (void) onInitializeSender: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    [super onInitializeSender:credentials configuration:configuration];
}
- (void) onInitialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    [super onInitialize:credentials configuration:configuration];
    
    [self observeDirectoryChanged];
    [self initWPKMobi: credentials];
}
- (void) onPostInitialize {
    [super onPostInitialize];
}

- (void) onStop {
    [super onStop];
    [self stopLogDirectoryMonitor];
}
- (void) onPostStop {
    [super onPostStop];
}

- (void) initWPKMobi: (SLSCredentials *) credentials {
    [WPKSetup setIsEncryptLog:NO];
    [WPKSetup enableDebugLog:NO];
    [WPKSetup setUTDID:[Utdid getUtdid]];
    [WPKSetup startWithAppName:credentials.instanceId];
    [WPKSetup sendAllReports];
}

- (void) observeDirectoryChanged {
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    
    NSString *wpkLogpath = [libraryPath stringByAppendingPathComponent:@".WPKLog"];
    if (![self checkAndCreateDirectory:wpkLogpath]) {
        return;
    }
    
    _wpkCrashLogPath = [wpkLogpath stringByAppendingPathComponent:@"CrashLog"];
    if (![self checkAndCreateDirectory:_wpkCrashLogPath]) {
        return;
    }
    
    _wpkStatLogPath = [wpkLogpath stringByAppendingPathComponent:@"CrashStatLog"];
    if (![self checkAndCreateDirectory:_wpkStatLogPath]) {
        return;
    }
    
    // report old state & crash file first
    [self reportState];
    [self reportCrash];
    
    observeDirectory(_crashLogSource, _wpkCrashLogPath, ^(NSString *path) {
        [self reportCrash: path];
    });
    observeDirectory(_crashStatLogSource, _wpkStatLogPath, ^(NSString *path) {
        [self reportState: path];
    });
    
    //    [self.crashFileHelper scanAndReport: crashLogPath];
}

- (BOOL) checkAndCreateDirectory: (NSString*) dir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dir]) {
        SLSLogV(@"%@ path not exists.", dir);
        BOOL res = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        if (!res) {
            SLSLog(@"create directory %@ error.", dir);
        }
        return res;
    }
    return YES;
}

- (void) stopLogDirectoryMonitor {
    dispatch_cancel(self.crashLogSource);
    dispatch_cancel(self.crashStatLogSource);
}

static void observeDirectory(dispatch_source_t _source, NSString *path, directory_changed_block hander) {
    NSURL *dirURL = [NSURL URLWithString:path];
    int const fd = open([[dirURL path]fileSystemRepresentation], O_EVTONLY);
    if (fd < 0) {
        SLSLog(@"unable to open the path: %@", [dirURL path]);
        return;
    }
    
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_WRITE, DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_event_handler(source, ^() {
        unsigned long const type = dispatch_source_get_data(source);
        switch (type) {
            case DISPATCH_VNODE_WRITE: {
                SLSLogV(@"directory changed. %@", path);
                hander(path);
                break;
            }
            default:
                break;
        }
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fd);
    });
    
    _source = source;
    dispatch_resume(_source);
}

- (void) reportState {
    if (!_wpkStatLogPath || ![[NSFileManager defaultManager] fileExistsAtPath:_wpkStatLogPath isDirectory:nil]) {
        return;
    }
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_wpkStatLogPath error:nil];
    if (contents) {
        for (NSString *content in contents) {
            [self reportState:[_wpkStatLogPath stringByAppendingPathComponent:content]];
        }
    }
}
- (void) reportCrash {
    if (!_wpkCrashLogPath || ![[NSFileManager defaultManager] fileExistsAtPath:_wpkCrashLogPath isDirectory:nil]) {
        return;
    }
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_wpkCrashLogPath error:nil];
    if (contents) {
        for (NSString *content in contents) {
            [self reportCrash:[_wpkCrashLogPath stringByAppendingPathComponent:content]];
        }
    }
}

- (void) reportState: (NSString *) file {
    if (!file || file.length <= 0 || ![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        return;
    }
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    if (!content || content.length <= 0) {
        return;
    }
    
    SLSSpanBuilder *builder = [self newSpanBuilder:@"state"];
    [builder addAttribute:
         [SLSAttribute of:@"t" value:@"error"],
         [SLSAttribute of:@"ex.type" value:@"state"],
         [SLSAttribute of:@"ex.origin" value:content],
         [SLSAttribute of:@"ex.uuid" value:[Utdid getUtdid]] ,
         nil
    ];
    
    [[builder build] end];
}

- (void) reportCrash: (NSString *) file {
    if (!file || file.length <= 0 || ![[NSFileManager defaultManager] fileExistsAtPath:file isDirectory:nil]) {
        return;
    }
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    if (!content || content.length <= 0)  {
        return;
    }
    
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (!lines) {
        return;
    }
    
    NSString *time = @"";
    for (NSString *line in lines) {
        if ([line containsString:@"Date/Time:"]) {
            NSArray *chunks = [line componentsSeparatedByString:@"Time:"];
            if (chunks && [chunks count] == 2) {
                time = [chunks objectAtIndex:1];
            }
            break;
        }
    }
    
    SLSSpanBuilder *buidler = [self newSpanBuilder:@"crash"];
    [buidler addAttribute:
         [SLSAttribute of:@"t" value:@"error"],
         [SLSAttribute of:@"ex.type" value:@"crash"],
//         [SLSAttribute of:@"ex.sub_type" value:@""],
         [SLSAttribute of:@"ex.origin" value:content],
         [SLSAttribute of:@"ex.file" value:[file lastPathComponent]],
         nil
    ];
    
    if (time && time.length >0) {
        time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // time format: 2021-06-09 19:32:17.341 +0800
        NSDateFormatter *dateFormatter = [NSDateFormatter sharedInstance];
        NSDate *date = [dateFormatter fromStringZ:time];
        
//        tcdata.local_timestamp = [NSString stringWithFormat:@"%0.f", [date timeIntervalSince1970] * 1000];
//        tcdata.local_time = [dateFormatter fromDate:date];
        [buidler setStart:[date timeIntervalSince1970] * 1000];
    }
    
    [[buidler build] end];
}

@end
