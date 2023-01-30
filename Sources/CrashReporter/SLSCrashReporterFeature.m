//
//  SLSCrashReporterFeature.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSSystemCapabilities.h"
#import "SLSCrashReporterFeature.h"
#import "WPKMobi/WPKSetup.h"
#import "WPKMobi/WPKThreadBlockChecker.h"
#import "Utdid.h"
#import "NSDateFormatter+SLS.h"
#import "SLSCrashReporter.h"
#import "SLSProducer.h"

typedef void(^directory_changed_block)(NSString *);

@interface SLSLastCachedSpan : SLSSpan
+ (SLSLastCachedSpan *) cachedSpan: (SLSSpan *) span;
@end

@implementation SLSLastCachedSpan

+ (SLSLastCachedSpan *) cachedSpan: (SLSSpan *) span {
    SLSLastCachedSpan *cachedSpan = [[SLSLastCachedSpan alloc] init];
    [cachedSpan setTraceID:span.traceID];
    if (span.parentSpanID.length > 0) {
        [cachedSpan setSpanID:span.parentSpanID];
    }
    
    return cachedSpan;
}

@end

@interface SLSCrashReporterFeature ()<WPKThreadBlockCheckerDelegate>
@property(nonatomic, strong) NSString *wpkStatLogPath;
@property(nonatomic, strong) NSString *wpkCrashLogPath;

@property(nonatomic, strong) dispatch_source_t crashLogSource;
@property(nonatomic, strong) dispatch_source_t crashStatLogSource;
@property(nonatomic, copy) NSString *project;

//@property(nonatomic, strong) SLSConfiguration *configuration;

- (void) observeDirectoryChanged;
- (void) initWPKMobi: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration;
- (NSString *) getAppIdByInstanceId: (NSString *) instanceId;

- (void) reportState;
- (void) reportCrash;

- (void) reportState: (NSString *) file;
- (void) reportCrash: (NSString *) file;

@end

@implementation SLSCrashReporterFeature

#pragma mark - init
- (NSString *)name {
    return @"crash_reporter";
}

- (void)setCredentials:(SLSCredentials *)credentials {
    if (nil == credentials) {
        return;
    }
    
    if ([credentials.project length] > 0) {
        _project = [credentials.project copy];
    }
}

- (void) onInitializeSender: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    [super onInitializeSender:credentials configuration:configuration];
}
- (void) onInitialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    [super onInitialize:credentials configuration:configuration];
    _project = credentials.project;
    
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

- (void) initWPKMobi: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration {
    if (configuration.enableCrashReporter) {
        [WPKSetup setIsEncryptLog:NO];
        [WPKSetup enableDebugLog:NO];
        [WPKSetup startWithAppName:[self getAppIdByInstanceId:credentials.instanceId]];
    }
    
    if (configuration.enableBlockDetection) {
        WPKThreadBlockChecker *blockChecker = [WPKSetup threadBlockCheckerWithDelegate:self];
        
        WPKThreadBlockCheckerConfig *blockConfig = [[WPKThreadBlockCheckerConfig alloc] init];
        blockConfig.sendBeatInterval = 3;
        blockConfig.checkBeatInterval = 3;
        blockConfig.toleranceBeatMissingCount = 2;
        
        [blockChecker startWithConfig:blockConfig];
    }
    
    [WPKSetup sendAllReports];
}

- (NSString *) getAppIdByInstanceId: (NSString *) instanceId {
    return [NSString stringWithFormat:@"sls-%@", instanceId];
}

- (void) observeDirectoryChanged {
#if SLS_HOST_TV
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
#else
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
#endif
    SLSLogV(@"start observe directory changed start. library path: %@", libraryPath);
    
    NSString *wpkLogpath = [libraryPath stringByAppendingPathComponent:@".WPKLog"];
    if (![self checkAndCreateDirectory:wpkLogpath]) {
        SLSLog(@"create wpklog directory fail.");
        return;
    }
    
    _wpkCrashLogPath = [wpkLogpath stringByAppendingPathComponent:@"CrashLog"];
    if (![self checkAndCreateDirectory:_wpkCrashLogPath]) {
        SLSLog(@"create CrashLog directory fail.");
        return;
    }
    
    _wpkStatLogPath = [wpkLogpath stringByAppendingPathComponent:@"CrashStatLog"];
    if (![self checkAndCreateDirectory:_wpkStatLogPath]) {
        SLSLog(@"create CrashStatLog directory fail.");
        return;
    }
    
    // report old state & crash file first
    [self reportState];
    [self reportCrash];
    
    observeDirectory(self.crashLogSource, self.wpkCrashLogPath, ^(NSString *path) {
        [self reportCrash];
    });
    observeDirectory(self.crashStatLogSource, self.wpkStatLogPath, ^(NSString *path) {
        [self reportState];
    });
    SLSLogV(@"observe directory changed end. ");
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
        SLSLog(@"SLSCrashReporterFeature, unable to open the path: %@", [dirURL path]);
        return;
    }
    
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_WRITE, DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_event_handler(source, ^() {
        unsigned long const type = dispatch_source_get_data(source);
        switch (type) {
            case DISPATCH_VNODE_WRITE: {
                SLSLogV(@"SLSCrashReporterFeature, directory changed. %@", path);
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
    if (contents && contents.count > 0) {
        SLSLogV(@"report existing state file. count: %lu", (unsigned long)contents.count);
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
    if (contents && contents.count > 0) {
        SLSLogV(@"report existing crash file. count: %lu", (unsigned long)contents.count);
        for (NSString *content in contents) {
            [self reportCrash:[_wpkCrashLogPath stringByAppendingPathComponent:content]];
        }
    }
}

- (void) reportState: (NSString *) file {
    SLSLogV(@"start report state file. file: %@", file);
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
    
    // lines 可能存在多行的情况
    for (NSString *line in lines) {
        if ([line containsString:@"dn"]) {
            NSArray *chunks = [line componentsSeparatedByString:@"`"];
            if (!chunks) {
                return;
            }
            content = [NSMutableString string];
            for (NSString *chunk in chunks) {
                if ([chunk containsString:@"dn="]) {
                    [((NSMutableString *) content) appendFormat: @"dn=%@`", utdid];
                } else if (chunk.length > 0){
                    [((NSMutableString *) content) appendFormat: @"%@`", chunk];
                }
            }
            
            // 每一行单独上报
            SLSSpanBuilder *builder = [self newSpanBuilder:@"state"];
            [builder addAttribute:
                 [SLSAttribute of:@"t" value:@"error"],
                 [SLSAttribute of:@"ex.type" value:@"state"],
                 [SLSAttribute of:@"ex.origin" value:content],
                 [SLSAttribute of:@"ex.uuid" value:utdid],
                 nil
            ];
            [builder setGlobal:NO];
            
            BOOL ret = [[builder build] end];
            if (ret) {
                [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
                SLSLogV(@"report state file success.");
            } else {
                SLSLogV(@"report state file fail.");
            }
        }
    }
}

- (void) reportCrash: (NSString *) file {
    SLSLogV(@"start report crash file. file: %@", file);
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
    NSString *subType = @"crash";
    content = [NSMutableString string];
    for (NSString *line in lines) {
        if ([line containsString:@"Date/Time:"]) {
            NSArray *chunks = [line componentsSeparatedByString:@"Time:"];
            if (chunks && [chunks count] == 2) {
                time = [chunks objectAtIndex:1];
            }
        }
        
        if ([line containsString:@"UDID:"]) {
            [((NSMutableString *) content) appendFormat:@"UDID:      %@\n", [Utdid getUtdid]];
        } else {
            if ([line containsString:@"k_ac:"]) {
                NSArray *chunks = [line componentsSeparatedByString:@"k_ac:"];
                if (nil != chunks && [chunks count] == 2) {
                    subType = [chunks[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
            }
            
            [((NSMutableString *) content) appendFormat:@"%@\n", line];
        }
    }
    
    NSString *type = @"crash";
    if ([[file pathExtension] isEqualToString:@"block"]) {
        type = @"block";
    }
    
    SLSLastCachedSpan *lastCachedSpan = nil;
    if (self.configuration.enableTrace) {
        SLSSpan *span = [SLSContextManager getLastGlobalActiveSpan];
        if (nil != span) {
            lastCachedSpan = [SLSLastCachedSpan cachedSpan:span];
        }
    }
    
    SLSSpanBuilder *buidler = [self newSpanBuilder:type];
    [buidler addAttribute:
         [SLSAttribute of:@"t" value:@"error"],
         [SLSAttribute of:@"ex.type" value:type],
         [SLSAttribute of:@"ex.sub_type" value:subType],
         [SLSAttribute of:@"ex.origin" value:content],
         [SLSAttribute of:@"ex.file" value: [file lastPathComponent]],
         nil
    ];
    
    if (nil != lastCachedSpan) {
        [buidler setParent:lastCachedSpan];
    }
    
    if (time && time.length >0) {
        time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // time format: 2021-06-09 19:32:17.341 +0800
        NSDateFormatter *dateFormatter = [NSDateFormatter sharedInstance];
        NSDate *date = [dateFormatter fromStringZ:time];
        
//        tcdata.local_timestamp = [NSString stringWithFormat:@"%0.f", [date timeIntervalSince1970] * 1000];
//        tcdata.local_time = [dateFormatter fromDate:date];
        [buidler setStart:[date timeIntervalSince1970] * 1000000000];
    } else {
        time = [[NSDateFormatter sharedInstance] fromDate:[NSDate date] formatter:@"YYYY-MM-dd HH:mm:ss.SSS Z"];
    }
    
    SLSSpan *crashedSpan = [buidler build];
    BOOL ret = [crashedSpan end];
    if (ret) {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
        SLSLogV(@"report crash file success.");
    } else {
        SLSLogV(@"report crash file fail.");
    }
    
    if (self.configuration.enableTrace && [@"crash" isEqualToString:type]) {
        Class clazz = NSClassFromString(@"SLSTracer");
        if (!clazz) {
            return;
        }
        
        NSDate *d = [[NSDateFormatter sharedInstance] fromStringZ:time];
        NSString *t = [[NSDateFormatter sharedInstance] fromDate:d formatter:@"yyyyMMddHHmmss"];

//        SLSSpan *span = [SLSTracer startSpan:@"Application Crashed"];
        SLSSpan *span = [clazz performSelector:@selector(startSpan:) withObject:@"Application Crashed"];
        [span setSpanID:crashedSpan.spanID];
        [span addAttribute:
             [SLSAttribute of:@"ex.file" value:[file lastPathComponent]],
             [SLSAttribute of:@"ex.uuid" value:[[Utdid getUtdid] copy]],
             [SLSAttribute of:@"ex.project" value:_project],
             [SLSAttribute of:@"ex.time" value:t],
             [SLSAttribute of:@"ex.filter_time" value:[t substringToIndex:10]],
             [SLSAttribute of:@"ex.filter_classify" value:@"crash"],
             [SLSAttribute of:@"ex.filter_type" value:@""],
             nil
        ];
        [span setStatusCode:ERROR];
        
        if (nil != lastCachedSpan) {
            [span setParent:lastCachedSpan];
        }
        
        [span end];
    }
}

#pragma mark - block
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
    [WPKSetup sendAllReports];
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

#pragma mark - setter
- (void) setFeatureEnabled: (BOOL) enable {
    if (enable) {
        if ([WPKSetup isWPKReporterActive]) {
            return;
        }
        
        [WPKSetup activeWPKReporter];
        SLSLog(@"CrashReporterFeature enabled.");
        return;
    } else {
        if ([WPKSetup isWPKReporterActive]) {
            [WPKSetup disableWPKReporter];
        }
        SLSLog(@"CrashReporterFeature disabled.");
    }
}

#pragma mark - getter
- (BOOL) isFeatureEnabled {
    return [WPKSetup isWPKReporterActive];
}

#pragma mark - report custom log
- (void) reportCustomLog: (nonnull NSString *)log type: (nonnull NSString *)type {
    SLSSpanBuilder *buidler = [self newSpanBuilder:@"custom log"];
    [buidler addAttribute:
         [SLSAttribute of:@"t" value:@"custom"],
         [SLSAttribute of:@"ex.type" value:([type length] > 0 ? type: @"log")],
         [SLSAttribute of:@"ex.origin" value: ([log length] > 0 ? log : @"")],
         nil
    ];
    
    [[buidler build] end];
}

#pragma mark - report error
- (void) reportError: (NSString *) type level: (SLSLogLevel) level message: (NSString *) message stacktraces: (NSArray<NSString *> *) stacktraces {
    [WPKSetup reportScriptException:[type copy] reason:[message copy] stackTrace:[stacktraces copy] terminateProgram:NO];
    [WPKSetup sendAllReports: NO];
}

@end
