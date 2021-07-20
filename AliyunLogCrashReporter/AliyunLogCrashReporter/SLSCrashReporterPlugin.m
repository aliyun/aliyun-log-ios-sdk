//
//  SLSCrashReporterPlugin.m
//  AliyunLogCrashReporter
//
//  Created by gordon on 2021/5/19.
//

#import "SLSCrashReporterPlugin.h"
#import "AliyunLogCrashReporter.h"
#import "UCTraceFileParser.h"
#import "SLSReporterSender.h"
#import "WPKMobi/WPKSetup.h"


typedef void(^content_changed_block)(NSString*);

@interface SLSCrashReporterPlugin ()

@property(nonatomic, strong) IReporterSender *sender;
@property(nonatomic, strong) IFileParser *fileParser;

@property(nonatomic, strong) dispatch_source_t crashLogSource;
@property(nonatomic, strong) dispatch_source_t crashStatLogSource;

- (void) initWPKMobi: (SLSConfig *)config;
- (void) scanAndReport: (NSString *)path andType: (NSString *) type;
- (void) startLogDirectoryMonitor;
- (void) stopLogDirectoryMonitor;

@end

@implementation SLSCrashReporterPlugin

void monitorDirectory(SLSCrashReporterPlugin* plugin, dispatch_source_t _source, NSString *path, content_changed_block hander) {
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

- (instancetype)init
{
    if (self = [super init]) {
        self.sender = [[SLSReporterSender alloc] init];
        self.fileParser = [[UCTraceFileParser alloc] init];
    }
    return self;
}

- (NSString *)name{
    return @"SLSCrashReporterPlugin";
}

- (BOOL) initWithSLSConfig: (SLSConfig *) config {
    [super initWithSLSConfig:config];
    self.config = config;
    
    [self.sender initWithSLSConfig:config];
    [self.fileParser initWithSender:self.sender andSLSConfig:config];
    
    [self initWPKMobi:config];
    return YES;
}

- (void)resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    [_sender resetSecurityToken:accessKeyId secret:accessKeySecret token:token];
}

- (void)resetProject:(NSString *)endpoint project:(NSString *)project logstore:(NSString *)logstore {
    [_sender resetProject:endpoint project:project logstore:logstore];
}

- (void)updateConfig:(SLSConfig *)config {
    if (config) {
        if (config.channel && ![@"" isEqual:config.channel]) {
            [self.config setChannel:config.channel];
        }
        
        if (config.channelName && ![@"" isEqual:config.channelName]) {
            [self.config setChannelName:config.channelName];
        }
        
        if (config.userNick && ![@"" isEqual:config.userNick]) {
            [self.config setUserNick:config.userNick];
        }
        
        if (config.longLoginNick && ![@"" isEqual:config.longLoginNick]) {
            [self.config setLongLoginNick:config.longLoginNick];
        }
        
        if (config.userId && ![@"" isEqual:config.userId]) {
            [self.config setUserId:config.userId];
        }
        
        if (config.longLoginUserId && ![@"" isEqual:config.longLoginUserId]) {
            [self.config setLongLoginUserId:config.longLoginUserId];
        }
        
        if (config.loginType && ![@"" isEqual:config.loginType]) {
            [self.config setLoginType:config.loginType];
        }
        
        [_fileParser updateConfig:self.config];
    }
}

#pragma mark - WPKMobi log directory monitor

- (void) initWPKMobi: (SLSConfig *) config {
    [self startLogDirectoryMonitor];
    
    [WPKSetup setIsEncryptLog:NO];
    [WPKSetup enableDebugLog:config.debuggable];
//    [WPKSetup setCrashWritenCallback:^NSString * _Nullable(const char * _Nonnull crashUUID, WPKCrashType crashType, NSException * _Nullable exception) {
//        SLSLogV(@"creashType: %zd, exception: ", crashType);
//        return @"test";
//    }];
//    [WPKSetup disableWPKReporter];
    [WPKSetup startWithAppName:config.pluginAppId];
    [WPKSetup sendAllReports];
    SLSLogV(@"initWPKMobi success.");
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

- (void) startLogDirectoryMonitor {
    // AppData/Library/.WPKLog/CrashLog
    // AppData/Library/.WPKLog/CrashStatLog
    SLSLog(@"start");
    NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    SLSLogV(@"libraryPath: %@", libraryPath);
    
    NSString *wpkLogpath = [libraryPath stringByAppendingPathComponent:@".WPKLog"];
    if (![self checkAndCreateDirectory:wpkLogpath]) {
        return;
    }
    SLSLogV(@"wpkLogpath: %@", wpkLogpath);
    
    NSString *crashLogPath = [wpkLogpath stringByAppendingPathComponent:@"CrashLog"];
    if (![self checkAndCreateDirectory:crashLogPath]) {
        return;
    }
    SLSLogV(@"crashLogPath: %@", crashLogPath);
    
    NSString *crashStatLogPath = [wpkLogpath stringByAppendingPathComponent:@"CrashStatLog"];
    if (![self checkAndCreateDirectory:crashStatLogPath]) {
        return;
    }
    SLSLogV(@"CrashStatLogPath: %@", crashStatLogPath);
    
    SLSLog(@"scan files in crash directory and report if file exsits");
    [self scanAndReport:crashLogPath andType:@"crash"];
    [self scanAndReport:crashStatLogPath andType:@"crash_stat"];
    
    monitorDirectory(self, self.crashLogSource, crashLogPath, ^(NSString *path) {
        [self.fileParser parseFileWithType:@"crash" andFilePath:path];
    });

    monitorDirectory(self, self.crashStatLogSource, crashStatLogPath, ^(NSString *path) {
        [self.fileParser parseFileWithType:@"crash_stat" andFilePath:path];
    });
}

- (void)scanAndReport:(NSString *)path andType:(NSString *)type {
    SLSLogV(@"type: %@, path: %@", type, path);
    [self.fileParser parseFileWithType:type andFilePath:path];
}

- (void) stopLogDirectoryMonitor {
    dispatch_cancel(self.crashLogSource);
    dispatch_cancel(self.crashStatLogSource);
}


@end
