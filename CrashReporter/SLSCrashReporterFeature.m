//
//  SLSCrashReporterFeature.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSCrashReporterFeature.h"
#import "WPKMobi/WPKSetup.h"
#import "WPKMobi/WPKThreadBlockChecker.h"
#import "Utdid.h"
#import "NSDateFormatter+SLS.h"
#import "SLSCrashReporter.h"

typedef void(^directory_changed_block)(NSString*);

@interface SLSCrashReporterFeature ()<WPKThreadBlockCheckerDelegate>
@property(nonatomic, strong) NSString *wpkStatLogPath;
@property(nonatomic, strong) NSString *wpkCrashLogPath;

@property(nonatomic, strong) dispatch_source_t crashLogSource;
@property(nonatomic, strong) dispatch_source_t crashStatLogSource;

- (void) observeDirectoryChanged;
- (void) initWPKMobi: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration;
- (NSString *) getAppIdByInstanceId: (NSString *) instanceId;

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
    [self initWPKMobi: credentials configuration:configuration];
    
    [[SLSCrashReporter sharedInstance] setCrashReporterFeature:self];
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

- (void)addCustom:(NSString *)eventId properties:(NSDictionary<NSString *,NSString *> *)proterties {
    [super addCustom:eventId properties:proterties];
    
    SLSSpanBuilder *buidler = [self newSpanBuilder:@"custom_error"];
    [buidler addAttribute:
         [SLSAttribute of:@"t" value:@"error"],
         [SLSAttribute of:@"ex.type" value:@"custom"],
         [SLSAttribute of:@"ex.event_id" value:eventId],
         nil
    ];
    
    if (proterties && [NSJSONSerialization isValidJSONObject:proterties]) {
        [buidler addAttribute:
             [SLSAttribute of:@"ex.custom" value:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:proterties
                                                                                                                options:kNilOptions
                                                                                                                  error:nil
                                                                                ]
                                                                       encoding:NSUTF8StringEncoding
                                                 ]
             ],
             nil
        ];
    }
    [[buidler build] end];
    
}


- (void) initWPKMobi: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    if (configuration.enableCrashReporter) {
        [WPKSetup setIsEncryptLog:NO];
        [WPKSetup enableDebugLog:NO];
        [WPKSetup startWithAppName:[self getAppIdByInstanceId:credentials.instanceId]];
    }
    
    if (configuration.enableBlockDetection) {
        WPKThreadBlockChecker *blockChecker = [WPKSetup threadBlockCheckerWithDelegate:self];
        
        WPKThreadBlockCheckerConfig *blockConfig = [[WPKThreadBlockCheckerConfig alloc] init];
        blockConfig.sendBeatInterval = 2;
        blockConfig.checkBeatInterval = 2;
        blockConfig.toleranceBeatMissingCount = 1;
        
        [blockChecker startWithConfig:blockConfig];
    }
    
    [WPKSetup sendAllReports];
}

- (NSString *) getAppIdByInstanceId: (NSString *) instanceId {
    return [NSString stringWithFormat:@"sls-%@", instanceId];
}

- (void) observeDirectoryChanged {
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    SLSLogV(@"library path: %@", libraryPath);
    
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
    
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (!lines) {
        return;
    }
    
    NSString *utdid = [Utdid getUtdid];
    
    for (NSString *line in lines) {
        if ([line containsString:@"dn"]) {
            NSArray *chunks = [line componentsSeparatedByString:@"`"];
            if (!chunks) {
                return;
            }
            content = [NSString string];
            for (NSString *chunk in chunks) {
                if ([chunk containsString:@"dn="]) {
                    content = [content stringByAppendingFormat: @"dn=%@`", utdid];
                } else if (chunk.length > 0){
                    content = [content stringByAppendingFormat: @"%@`", chunk];
                }
            }
            break;
        }
    }
    
    SLSSpanBuilder *builder = [self newSpanBuilder:@"state"];
    [builder addAttribute:
         [SLSAttribute of:@"t" value:@"error"],
         [SLSAttribute of:@"ex.type" value:@"state"],
         [SLSAttribute of:@"ex.origin" value:content],
         [SLSAttribute of:@"ex.uuid" value:utdid],
         nil
    ];
    
    BOOL ret = [[builder build] end];
    if (ret) {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
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
    content = [NSString string];
    for (NSString *line in lines) {
        if ([line containsString:@"Date/Time:"]) {
            NSArray *chunks = [line componentsSeparatedByString:@"Time:"];
            if (chunks && [chunks count] == 2) {
                time = [chunks objectAtIndex:1];
            }
        }
        
        if ([line containsString:@"UDID:"]) {
            content = [content stringByAppendingFormat:@"UDID:      %@\n", [Utdid getUtdid]];
        } else {
            content = [content stringByAppendingFormat:@"%@\n", line];
        }
    }
    
    NSString *type = @"crash";
    if ([[file pathExtension] isEqualToString:@"block"]) {
        type = @"block";
    }
    
    SLSSpanBuilder *buidler = [self newSpanBuilder:type];
    [buidler addAttribute:
         [SLSAttribute of:@"t" value:@"error"],
         [SLSAttribute of:@"ex.type" value:type],
         [SLSAttribute of:@"ex.sub_type" value:type],
         [SLSAttribute of:@"ex.origin" value:content],
         [SLSAttribute of:@"ex.file" value: [file lastPathComponent]],
         nil
    ];
    
    if (time && time.length >0) {
        time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // time format: 2021-06-09 19:32:17.341 +0800
        NSDateFormatter *dateFormatter = [NSDateFormatter sharedInstance];
        NSDate *date = [dateFormatter fromStringZ:time];
        
//        tcdata.local_timestamp = [NSString stringWithFormat:@"%0.f", [date timeIntervalSince1970] * 1000];
//        tcdata.local_time = [dateFormatter fromDate:date];
        [buidler setStart:[date timeIntervalSince1970] * 1000000000];
    }
    
    BOOL ret = [[buidler build] end];
    if (ret) {
//        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
}

/* @brief 检测到一次卡顿
 * @param blockTime 卡顿的时长
 */
- (void)onMainThreadBlockedWithBlockInterval:(NSTimeInterval)blockInterval {
    SLSLogV(@"onMainThreadBlockedWithBlockInterval, block interval: %f", blockInterval);
}

/* @biref 检测持续发生卡顿（第一次卡顿后，下个检测心跳又一次触发卡顿）。可以在这里做些统计等。
 */
- (void)onMainThreadKeepOnBlocking {
    SLSLogV(@"onMainThreadKeepOnBlocking");
}

/* @brief 心跳正常。两种情况表示正常：1、心跳正常（主线程正常）； 2、APP被置入后台。
 */
- (void)onMainThreadStayHealthy:(BOOL)mainThreadRespond {
//    SLSLogV(@"onMainThreadStayHealthy");
}

/* @brief 重新启动一轮心跳检测（卡顿计数重置）。
 */
- (void)onMainThreadCheckingReset {
//    SLSLogV(@"onMainThreadCheckingReset");
}

@end
