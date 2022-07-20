//
//  CrashExampController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/21.
//

#import "CrashExampController.h"
#include "CppExceptionFaker.hpp"
#import "SLSCocoa.h"
#import "SLSCrashReporter.h"

@interface CrashExampController ()
@property(nonatomic, strong) NSLock *lock;

@end

@implementation CrashExampController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"崩溃监控";
    [self initViews];
    [self initCrash];
    
    self.lock = [[NSLock alloc] init];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat cellWidth = SLCellWidth * 1.4;
    
    CGFloat lx = ((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2);
    CGFloat rx = ((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2);
    UIFont *font = [UIFont systemFontOfSize:13];;
    
    [self createButton:@"Mach Crash" andAction:@selector(onMachCrash) andX:lx andY:0 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"ObjC NSException" andAction:@selector(onObjCCrashFakeBtnClick) andX:rx andY:0 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"ObjC DeadLock" andAction:@selector(onOjbCDeadLockFakeBtnClick) andX:lx andY:SLCellHeight + SLPadding andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"CPP Abort Crash" andAction:@selector(onCppAbortExceptionFakeBtnClick) andX:rx andY:SLCellHeight + SLPadding andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"CPP exit Crash（不可捕获）" andAction:@selector(onCppExitExceptionFakeBtnClick) andX:lx andY:(SLCellHeight + SLPadding) * 2 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"CPP NPE Crash" andAction:@selector(onCppNPExceptionFakeBtnClick) andX:rx andY:(SLCellHeight + SLPadding) * 2 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"CPP Custom Exception" andAction:@selector(onCppCustomExceptionFakeBtnClick) andX:lx andY:(SLCellHeight + SLPadding) * 3 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"CPP WildPointer Crash" andAction:@selector(onCppWildPointerExceptionFakeBtnClick) andX:rx andY:(SLCellHeight + SLPadding) * 3 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"Signal FPE" andAction:@selector(onSignalFPECrashBtnClick) andX:lx andY:(SLCellHeight + SLPadding) * 4 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"Signal SIGILL" andAction:@selector(onSignalILLCrashBtnClick) andX:rx andY:(SLCellHeight + SLPadding) * 4 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"Signal SIGINT" andAction:@selector(onSignalINTCrashBtnClick) andX:lx andY:(SLCellHeight + SLPadding) * 5 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"Signal SIGEGV" andAction:@selector(onSignalSEGVCrashBtnClick) andX:rx andY:(SLCellHeight + SLPadding) * 5 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"Signal SIGTRAP" andAction:@selector(onSignalTrapCrashBtnClick) andX:lx andY:(SLCellHeight + SLPadding) * 6 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"Signal SIGBUS" andAction:@selector(onSignalBusCrashBtnClick) andX:rx andY:(SLCellHeight + SLPadding) * 6 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"Signal SIGSYS" andAction:@selector(onSignalSysCrashBtnClick) andX:lx andY:(SLCellHeight + SLPadding) * 7 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    [self createButton:@"Signal SIGPIPE" andAction:@selector(onSignalPipeCrashBtnClick) andX:rx andY:(SLCellHeight + SLPadding) * 7 andWidth:cellWidth andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"Custom Log" andAction:@selector(onCustomLog) andX:lx andY:(SLCellHeight + SLPadding) * 8 andWidth:(SLScreenW - lx * 4) andHeight:SLCellHeight andFont: font];
    
    [self createButton:@"动态更新" andAction:@selector(updateConfiguration) andX:lx andY:(SLCellHeight + SLPadding) * 9 andWidth:(SLScreenW - lx * 4) andHeight:SLCellHeight andFont: font];
}

- (void) initCrash {
    DemoUtils *utils = [DemoUtils sharedInstance];
//    SLSConfig *config = [[SLSConfig alloc] init];
//    // 正式发布时建议关闭
//    [config setDebuggable:YES];
//
//    [config setEndpoint: [utils endpoint]];
//    [config setAccessKeyId: [utils accessKeyId]];
//    [config setAccessKeySecret: [utils accessKeySecret]];
//    [config setPluginAppId: [utils pluginAppId]];
//    [config setPluginLogproject: [utils project]];
//
//    [config setUserId:@"test_userid"];
//    [config setChannel:@"test_channel"];
//    [config addCustomWithKey:@"customKey" andValue:@"testValue"];
    
//    SLSAdapter *slsAdapter = [SLSAdapter sharedInstance];
////    [slsAdapter addPlugin:[[SLSCrashReporterPlugin alloc]init]];
////    [slsAdapter addPlugin:[[SLSTracePlugin alloc] init]];
//    [slsAdapter initWithSLSConfig:config];
    
    SLSCredentials *credentials = [SLSCredentials credentials];
    credentials.endpoint = @"https://cn-hangzhou.log.aliyuncs.com";
    credentials.project = @"yuanbo-test-1";
    credentials.accessKeyId = utils.accessKeyId;
    credentials.accessKeySecret = utils.accessKeySecret;
    credentials.instanceId = @"yuanbo-test-1111";
    
    [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
        configuration.enableCrashReporter = YES;
    }];
    
}

- (void) updateConfiguration {
//    SLSConfig *config = [[SLSConfig alloc] init];
//    config.userId = @"test_uuuid";
//
//    SLSAdapter *adapter = [SLSAdapter sharedInstance];
//    [adapter updateConfig:config];
//    DemoUtils *utils = [DemoUtils sharedInstance];
//    [adapter resetSecurityToken:utils.accessKeyId secret:utils.accessKeySecret token:nil];
    
    
    SLSCredentials *credentials = [SLSCredentials credentials];
    credentials.instanceId = @"yuanbo-test-1111";
    credentials.accessKeyId = [DemoUtils sharedInstance].accessKeyId;
    credentials.accessKeySecret = [DemoUtils sharedInstance].accessKeySecret;
    [[SLSCocoa sharedInstance] setCredentials:credentials];
}

# pragma Mach Crash
- (void) onMachCrash {
    SLSLogV(@"********** Make a Mach Crash[BAD MEM ACCESS] now. **********");
    *((int *)(0x1234)) = 122;
}

# pragma ObjC Crash
- (void) onObjCCrashFakeBtnClick {
    SLSLogV(@"********** Make a Objc NSException now. **********");
    
    NSException* ex = [[NSException alloc]initWithName:@"FakeObjCException" reason:@"fake objective-c exception" userInfo:nil];
    
    @throw(ex);
}

- (void) onOjbCDeadLockFakeBtnClick {
    SLSLogV(@"********** Make a Objc DeadLock now. **********");
    [self.lock lock];
    [self update];
    [self.lock unlock];
}

- (void)update {
    [self.lock lock];
    SLSLogV(@"11111");
    [self.lock unlock];
}

# pragma CPP Crash
- (void) onCppAbortExceptionFakeBtnClick {
    SLSLogV(@"********** Make a Cpp Crash[abort] now. **********");
    makeAbortException();
}

- (void) onCppExitExceptionFakeBtnClick {
    SLSLogV(@"********** Make a Cpp Crash[exit 0] now. **********");
    makeExitException();
}

- (void) onCppNPExceptionFakeBtnClick {
    SLSLogV(@"********** Make a Cpp Crash[Null Pointer] now. **********");
    makeNullPointException();
}

- (void) onCppCustomExceptionFakeBtnClick {
    SLSLogV(@"********** Make a Cpp Crash[custom exception] now. **********");
    makeCustomException();
}

- (void) onCppWildPointerExceptionFakeBtnClick {
    SLSLogV(@"********** Make a Cpp Crash[Wild Pointer] now. **********");
    makeWildPointerException();
}

#pragma Signal Crash
#pragma signal_fpe 错误的算术运算,如除以零
- (void) onSignalFPECrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[FPE] now. **********");
    
    // SIGFPE
    int a = 1, b = 0, c;
    c = a / b;
}

# pragma SIGILL 无效的程序映像,如无效指令
- (void) onSignalILLCrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[SIGILL] now. **********");
    raise(SIGILL);
}

# pragma SIGINT 外部中断,通常由用户发起
- (void) onSignalINTCrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[SIGINT] now. **********");
    raise(SIGINT);
}

# pragma SIGSEGV 无效的内存访问
- (void) onSignalSEGVCrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[SIGSEGV] now. **********");
    raise(SIGSEGV);
}

# pragma SIGBUS 总线异常
- (void) onSignalBusCrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[SIGBUS] now. **********");
    raise(SIGBUS);
}

# pragma SIGTRAP
- (void) onSignalTrapCrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[SIGTRAP] now. **********");
    raise(SIGTRAP);
}

# pragma SIGPIPE
- (void) onSignalPipeCrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[SIGPIPE] now. **********");
    raise(SIGPIPE);
}

# pragma SIGSYS
- (void) onSignalSysCrashBtnClick {
    SLSLogV(@"********** Make a Signal Crash[SIGSYS] now. **********");
    raise(SIGSYS);
}

- (void) onCustomLog {
    SLSLogV(@"********** Make a Custom Log now. **********");
//    [[SLSAdapter sharedInstance] reportCustomEvent:@"Clicked" properties:@{
//        @"view_pos": @1,
//        @"view_content": @"click test"
//    }];
    
    [[SLSCrashReporter sharedInstance] addCustomError:@"Clicked" properties:@{
        @"view_pos": @"1",
        @"view_content": @"click test"
    }];
}

- (void) crash {
    
}

@end
