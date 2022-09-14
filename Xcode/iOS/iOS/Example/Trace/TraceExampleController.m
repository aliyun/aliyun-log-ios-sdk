//
//  TraceExampleController.m
//  AliyunLogDemo
//
//  Created by gordon on 2022/1/10.
//

#import "TraceExampleController.h"

//@interface Setter : NSObject  <TelemetrySetter>
//@end
//
//@implementation Setter
//- (void)set:(NSMutableDictionary * _Nonnull)dict :(NSString * _Nonnull)key :(NSString * _Nonnull)value {
//    [dict setObject:value forKey:key];
//}
//@end

@interface TraceExampleController ()
@property(nonatomic, strong) UITextView *statusTextView;
@property(nonatomic, strong) LogProducerConfig *config;
@property(nonatomic, strong) LogProducerClient *client;

@end

@implementation TraceExampleController

static TraceExampleController *selfClzz;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selfClzz = self;
    self.title = @"基础配置";
    [self initViews];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLabel:@"参数: " andX:0 andY:0];

    DemoUtils *utils = [DemoUtils sharedInstance];
    NSString *parameters = [NSString stringWithFormat:@"endpoint: %@\nproject: %@\nlogstore:%@\naccessKeyId: %@\naccesskeySecret: %@\n",
                            utils.endpoint,
                            utils.project,
                            utils.logstore,
                            utils.accessKeyId,
                            utils.accessKeySecret];

    UILabel *label = [self createLabel:parameters andX:0 andY:SLCellHeight andWidth:SLScreenW - SLPadding * 2 andHeight:SLCellHeight * 5];
    label.numberOfLines = 0;
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentLeft;

    [self createLabel:@"状态: " andX:0 andY:SLCellHeight * 5];

    self.statusTextView = [self createTextView:@"" andX:0 andY:SLCellHeight * 6 andWidth:(SLScreenW - SLPadding * 2) andHeight:(SLCellHeight * 4)];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    self.statusTextView.layoutManager.allowsNonContiguousLayout = NO;
    [self.statusTextView setEditable:NO];
    [self.statusTextView setContentOffset:CGPointMake(0, 0)];

    CGFloat lx = ((SLScreenW - SLPadding * 2) / 4 - SLCellWidth / 2);
    CGFloat rx = ((SLScreenW - SLPadding * 2) / 4 * 3 - SLCellWidth / 2);

    [self createButton:@"启动引擎" andAction:@selector(engineStart) andX:lx andY:SLCellHeight * 11];
    [self createButton:@"打开空调" andAction:@selector(airConditionerOpen) andX:rx andY:SLCellHeight * 11];
    
//    [self createButton:@"inject" andAction:@selector(inject) andX:lx andY:SLCellHeight * 12 + SLPadding];
//    [SLSURLSessionInstrumentation registerInstrumentationDelegate:self];
}

- (NSDictionary<NSString *,NSString *> *)injectCustomeHeaders {
    return @{};
}

- (BOOL)shouldInstrument:(NSURLRequest *)request {
    return request;
}

- (void) updateStatus: (NSString *)append {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status = [NSString stringWithFormat:@"%@\n> %@", self.statusTextView.text, append];
        [self.statusTextView setText:status];
        [self.statusTextView scrollRangeToVisible:NSMakeRange(self->_statusTextView.text.length, 1)];
    });
}

- (void) engineStart {
    [self performSelectorInBackground:@selector(startEngine) withObject:nil];
}

- (void) startEngine {
    [SLSTracer withinSpan:@"执行启动引擎操作" block:^{
        [self connectPower];
        [[SLSTracer startSpan:@"启动引擎"] end];
        // todo 上报状态
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://sls-mall.caa227ac081f24f1a8556f33d69b96c99.cn-beijing.alicontainer.com/catalogue"]];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request] resume];
//        [SLSURLSession sendSynchronousRequest:[NSURLRequest requestWithURL:@""] returningResponse:(NSURLResponse * _Nullable __autoreleasing * _Nullable) error:(NSError *__autoreleasing  _Nullable * _Nullable)];
    }];
}

- (void) connectPower {
    [SLSTracer withinSpan:@"1：接通电源" block:^{
        [NSThread sleepForTimeInterval: 2.0];
    }];
    [SLSTracer withinSpan:@"1.1: 电气系统自检" block:^{
        [SLSTracer withinSpan:@"1.1.1: 电池电压检查" block:^{
            [NSThread sleepForTimeInterval:2.0];
        }];
        [SLSTracer withinSpan:@"1.1.2: 电气信号检查" block:^{
            [NSThread sleepForTimeInterval:2.0];
        }];
    }];
}

- (void) airConditionerOpen {
//    [self performSelectorInBackground:@selector(openAirConditioner) withObject:nil];
//    [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(openAirConditioner) object:nil] start];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self openAirConditioner];
//    });
    [self pthread_test];
}

- (void) pthread_test {
    THREAD t;
    THREAD_INIT(t, pthread_fun, NULL);
}

void * pthread_fun(void * params) {
    [selfClzz openAirConditioner];
    return NULL;
}

- (void) openAirConditioner {
    [self updateStatus:[NSString stringWithFormat:@"current thread: %@", [NSThread currentThread]]];
    [SLSTracer withinSpan:@"执行开空调操作" block:^{
        [SLSTracer withinSpan:@"1: 接通电源" block:^{
            [NSThread sleepForTimeInterval:2.0];
        }];
        [SLSTracer withinSpan:@"2. 电气系统自检" block:^{
            [SLSTracer withinSpan:@"2.1 电池检查" block:^{
                [[SLSTracer startSpan:@"电池电压检查"] end];
                [NSThread sleepForTimeInterval:2.0];
                
                SLSSpan *span = [SLSTracer startSpan:@"电池电流检查"];
                [span setStatusCode:ERROR];
                [span setStatusMessage:@"电池电流检查异常"];
                [span end];
                [NSThread sleepForTimeInterval:2.0];
                
                [[SLSTracer startSpan:@"电池温度检查"] end];
                
            }];
            [SLSTracer withinSpan:@"2.2 电气信息检查" block:^{
                [NSThread sleepForTimeInterval:2.0];
            }];
        }];
        [SLSTracer withinSpan:@"3. 启动风扇" block:^{
            [NSThread sleepForTimeInterval:2.0];
        }];
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://sls-mall.caa227ac081f24f1a8556f33d69b96c99.cn-beijing.alicontainer.com/catalogue"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
        }] resume];
    }];
    
}

- (void) connetAirPower {
    
}

//- (void) trace {
//    [SLSTracer withinSpan:@"开空调：子步骤1：电气系统检查" active:YES parent:nil block:^{
//        [SLSTracer withinSpan:@"开空调：1.1 电池检查" active:YES parent:nil block:^{
//            [[SLSTracer startSpan:@"电池电压检查"] end];
//            [[SLSTracer startSpan:@"电池电流检查"] end];
//        }];
//        [[SLSTracer startSpan:@"span name"] end];
//    }];
//}

- (void) inject {
//    TelemetrySDK *sdk = [TelemetrySDK instance];
//    TelemetrySpan *span = [[[sdk getTracer:@"demo"] spanBuilderWithSpanName:@"test-inject"] startSpan];
//
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [[sdk activeTextMapPropagator] injectWithContext:span.context carrier:dict setter:[[Setter alloc] init]];
//    [span setAttributeWithKey:@"inject-traceparent" value:[[TelemetryAttributeValue alloc] initWithStringValue:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil] encoding:NSUTF8StringEncoding]]];
//    [span end];
//
//    [self updateStatus:@"span 和 traceparent header 进行关联，用于前后端打通"];
}

@end
