//
//  WPKSetup.h
//  KSCrash-iOS
//
//  Created by xc on 2019/3/8.
//  Copyright © 2019 Karl Stenerud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WPKCrashType)
{
    /* Captures and reports Mach exceptions. */
    WPKCrashTypeMachException      = 0x01,
    
    /* Captures and reports POSIX signals. */
    WPKCrashTypeSignal             = 0x02,
    
    /* Captures and reports C++ exceptions.
     * Note: This will slightly slow down exception processing.
     */
    WPKCrashTypeCPPException       = 0x04,
    
    /* Captures and reports NSExceptions. */
    WPKCrashTypeNSException        = 0x08,
    
    /* Detects and reports a deadlock in the main thread. */
    WPKCrashTypeMainThreadDeadlock = 0x10,
    
    /* Accepts and reports user-generated exceptions. */
    WPKCrashTypeUserReported       = 0x20,
    
    /* Keeps track of and injects system information. */
    WPKCrashTypeSystem             = 0x40,
    
    /* Keeps track of and injects application state. */
    WPKCrashTypeApplicationState   = 0x80,
    
    /* Keeps track of zombies, and injects the last zombie NSException. */
    WPKCrashTypeZombie             = 0x100,
};


typedef NSString *_Nullable(^WPKCrashWritenCallback)(const char* crashUUID, WPKCrashType crashType, NSException *_Nullable exception);

typedef NSString *_Nullable(^WPKOOMWritenCallback)(void);

typedef void (^OnInactiveMonitorFindCallback)(void);

@class  WPKThreadBlockChecker;
@protocol WPKThreadBlockCheckerDelegate;

@interface WPKSetup : NSObject

/**
 *  调试日志开关
 *
 *  @param enable 设置为YES会输出debug log (默认为NO)
 */
+ (void)enableDebugLog:(BOOL)enable;

/**
 *  初始化啄木鸟SDK
 *
 *  @param appName 啄木鸟应用分配的应用唯一标识
 */
+ (void)startWithAppName:(NSString *)appName;


/**
 *  初始化啄木鸟SDK
 *  @param appName 啄木鸟应用分配的应用唯一标识
 *  @param buildData 自定义build号 (流水号, 用于兼容啄木鸟有流水号的app.)
 */
+ (void)startWithAppName:(NSString *)appName buildData:(NSString *)buildData;


/**
 *  初始化啄木鸟SDK
 *
 *  @param appName 啄木鸟应用分配的应用唯一标识
 *  @param applicationGroupIdentifier 设置 App Group Identifier (如有使用 App Extension SDK，请务必设置该值)
 */
+ (void)startWithAppName:(NSString *)appName applicationGroupIdentifier:(NSString *)applicationGroupIdentifier;


/**
 *  初始化啄木鸟SDK
 *
 *  @param appName 啄木鸟应用分配的应用唯一标识
 *  @param applicationGroupIdentifier 设置 App Group Identifier (如有使用 App Extension SDK，请务必设置该值)
 */
+ (void)startWithAppName:(NSString *)appName buildData:(NSString *)buildData applicationGroupIdentifier:(NSString *)applicationGroupIdentifier;


/**
 *  设置用户标识
 *
 *  @param userId 用户标识, 推荐使用idfa, 如果外部不传入, 默认使用啄木鸟生成的userid(非idfa)
 */
+ (void)setUserIdentifier:(NSString *)userId;

/**
 * 设置用户utdid
 *
 * @param utdid （可选）
 *
 */

+ (void)setUTDID:(NSString *)utdid;

/**
 *  设置用户自定义数据，随崩溃信息上报
 */
+ (void)setUserInfo:(NSDictionary *)userInfo;

/**
 * 设置自定义URL
 */

+ (void)setPageURL:(NSString *)URL;

/**
 * 设置自定义buildData
 */

+ (void)setBuildData:(NSString *)buildData;

/**
 *  设置自定义版本号 (需要在start的方法前调用)
 */
+ (void)setAppVersion:(NSString *)appVersion;

/**
 *  设置App渠道 (需要在start的方法前调用)
 */
+ (void)setAppChannel:(NSString *)channel;


/**
 *  获取用户自定义数据
 */
+ (NSDictionary *)userInfo;


/**
 *  上传崩溃到服务器
 */
+ (void)sendAllReports;


/**
  使用啄木鸟的国际集群, 国际版app可以选择启动此开关
  默认为NO
 */
+ (void)useIntlServices:(BOOL)isIntl;

/**
 是否在上传日志前使用默认算法加密崩溃日志(必须在sendAllReports发送日志前调用)
 默认为YES
 */
+ (void)setIsEncryptLog:(BOOL)encryptLog;

/**
 是否在上传前压缩崩溃日志
 默认为YES
 */
+ (void)setCompressLog:(BOOL)compressLog;


/**
 app崩溃时的回调,日志"已经"落盘
 这个回调中, 可以在一些写文件之类其他操作.
*/
+ (void)setCrashWritenCallback:(WPKCrashWritenCallback)callback;

/**
 上次启动是否有崩溃 (需要调用start后调用)
 */
+ (BOOL)crashedLastLaunch;


/**
 连续崩溃次数  (需要调用start后调用)
 */
+ (NSInteger)continuousCrashCount;


/**
 重置SDK记录的崩溃次数  (需要调用start后调用)
 因为各方对连续崩溃的定义不一样, 例如连续N次都是启动5s内崩溃, 还是连续N次启动10s内崩溃, 所以连续崩溃次数可以由业务方在适当时机去重置  (正常退出的情况, SDK也会重置)
 */
+ (void)resetContinuousCrashCount;


/**
 * SDK忽略对 SIGPIPE 的处理，默认 NO  (需要调用start前调用)
 */
+ (void)setIgnoreSignalPIPE:(BOOL)ignore;


/**
*  SDK设置需要过滤模块后, 遇到这些模块崩溃时, Crash将不会上传
*  例如某条Crash, 当前崩溃线程的堆栈
*  0   MyLib                               0x0000000181e3ad8c 0x0000000181000000 + 228
*  1   libobjc.A.dylib                     0x0000000180ff45ec 0x0000000180000000 + 56
*  如果设置了 [WPKSetup setFilterModules:@[@"MyLib"]]; 崩溃线程里面堆栈中, 任意一条堆栈包含了MyLib, 都会被SDK忽略
*/
+ (void)setFilterModules:(NSArray<NSString *> *)modules;


/**
 上次启动是否有内存崩溃,并且生成日志 (需要调用start后调用)
 */
+ (BOOL)CheckOOMLastLaunch;

/**
 内存崩溃是否使用上次运行时记录的userInfo (需要调用start后调用)
 */
+ (void)setOOMUseLastUserInfo:(BOOL)use;

/**
 内存崩溃记录是回调 (需要调用start后调用)
 */
+ (void)setOOMWritenCallback:(WPKOOMWritenCallback)callback;


/**
 上次退出状态是否在后台 (需要调用start后调用)
 */
+ (BOOL)isLastRunningStateBackground;

/**
 启用cxa_throw 方案，规避第三方SDK也实现了__cxa_throw()导致CPP堆栈为空的问题(需要调用start后调用)
 */
+ (void)enableSwapOfCxaThrow;

/**
  开启卡顿检测，获取对象后，调用startWithConfig开始监控
 */
+ (WPKThreadBlockChecker *)threadBlockCheckerWithDelegate:(id<WPKThreadBlockCheckerDelegate>)delegate;

// 上报自定义日志
+ (void) reportScriptException:(NSString*) logType
                        reason:(NSString*) reason
                    stackTrace:(NSArray*) stackTrace
              terminateProgram:(BOOL) terminateProgram;

// 是否调用旧的异常处理函数，默认是YES
+ (void) enableCallOriginalHandler: (BOOL) enable;

// 当前的异常监控是否都正常激活
+ (BOOL) isWPKReporterActive;

// 激活itrace的异常处理
+ (void) activeWPKReporter;

// 停用当前激活的异常处理器
+ (void) disableWPKReporter;

// 设置crashsdk定时自检的周期，默认是1分钟，如果设置为0，则关闭自检策略
// 该方法必须在start前调用
+ (void) setWPKReporterMonitorIntervalSecs: (uint) intervalSecs;

+ (void) setOnInactiveMonitorFindCallback: (OnInactiveMonitorFindCallback) onInactiveMonitorFind;
@end

NS_ASSUME_NONNULL_END
