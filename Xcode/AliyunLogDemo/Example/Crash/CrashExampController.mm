//
//  CrashExampController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/21.
//

#import "CrashExampController.h"
#include "CppExceptionFaker.hpp"

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
    
    [self createButton:@"Mach Crash" andAction:@selector(onMachCrash) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:0 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"ObjC NSException" andAction:@selector(onObjCCrashFakeBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:0 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"ObjC DeadLock" andAction:@selector(onOjbCDeadLockFakeBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:SLCellHeight + SLPadding andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"CPP Abort Crash" andAction:@selector(onCppAbortExceptionFakeBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:SLCellHeight + SLPadding andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"CPP exit Crash（不可捕获）" andAction:@selector(onCppExitExceptionFakeBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 2 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"CPP NPE Crash" andAction:@selector(onCppNPExceptionFakeBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 2 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"CPP Custom Exception" andAction:@selector(onCppCustomExceptionFakeBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 3 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"CPP WildPointer Crash" andAction:@selector(onCppWildPointerExceptionFakeBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 3 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"Signal FPE" andAction:@selector(onSignalFPECrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 4 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"Signal SIGILL" andAction:@selector(onSignalILLCrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 4 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"Signal SIGINT" andAction:@selector(onSignalINTCrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 5 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"Signal SIGEGV" andAction:@selector(onSignalSEGVCrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 5 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"Signal SIGTRAP" andAction:@selector(onSignalTrapCrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 6 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"Signal SIGBUS" andAction:@selector(onSignalBusCrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 6 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"Signal SIGSYS" andAction:@selector(onSignalSysCrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 7 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    [self createButton:@"Signal SIGPIPE" andAction:@selector(onSignalPipeCrashBtnClick) andX:((SLScreenW - SLPadding * 2) / 4 * 3 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 7 andWidth:cellWidth andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
    
    [self createButton:@"Custom Log" andAction:@selector(onCustomLog) andX:((SLScreenW - SLPadding * 2) / 4 - cellWidth / 2) andY:(SLCellHeight + SLPadding) * 8 andWidth:cellWidth * 2 andHeight:SLCellHeight].font = [UIFont systemFontOfSize: 13];
}

- (void) initCrash {
    DemoUtils *utils = [DemoUtils sharedInstance];
    SLSConfig *config = [[SLSConfig alloc] init];
    // 正式发布时建议关闭
    [config setDebuggable:YES];
    
    [config setEndpoint: [utils endpoint]];
    [config setAccessKeyId: [utils accessKeyId]];
    [config setAccessKeySecret: [utils accessKeySecret]];
    [config setPluginAppId: [utils pluginAppId]];
    [config setPluginLogproject: [utils project]];
    
    [config setUserId:@"test_userid"];
    [config setChannel:@"test_channel"];
    [config addCustomWithKey:@"customKey" andValue:@"testValue"];
    
    SLSAdapter *slsAdapter = [SLSAdapter sharedInstance];
    [slsAdapter addPlugin:[[SLSCrashReporterPlugin alloc]init]];
//    [slsAdapter addPlugin:[[SLSTracePlugin alloc] init]];
    [slsAdapter initWithSLSConfig:config];
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
    [[SLSAdapter sharedInstance] reportCustomEvent:@"Clicked" properties:@{
        @"view_pos": @1,
        @"view_content": @"click test"
    }];
}

- (void) crash {
    
}

@end
