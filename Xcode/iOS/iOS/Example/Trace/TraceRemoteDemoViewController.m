//
//  TraceRemoteDemoControllerViewController.m
//  iOS
//
//  Created by gordon on 2022/10/14.
//

#import "TraceRemoteDemoViewController.h"
#import "SLSURLSession.h"

@interface TraceRemoteDemoViewController ()
@property(nonatomic, strong) UITextView *consoleTextView;

@end

@implementation TraceRemoteDemoViewController
static TraceRemoteDemoViewController *selfClzz;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selfClzz = self;
    self.title = @"TraceDemo";
    [self initViews];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    _consoleTextView = [self createTextView:@"" andX:0 andY:0 andWidth:SLScreenW-SLPadding*2 andHeight:SLCellHeight*6];
    
    [self createButton:@"打开车机空调" action:@selector(sendOpenAirConditioner) row: 1 left: YES];
    [self createButton:@"车机启动空调" action:@selector(openAirConditioner) row: 1 left: NO];
    
}

- (UIButton *) createButton: (NSString *) name action: (SEL) action row: (int) row left: (BOOL) left {
    CGFloat width = SLCellWidth * 1.5;
    CGFloat lx = (SLScreenW - width * 2 - SLPadding * 2) / 4;
    CGFloat rx = width + lx * 3;
    
    return [self createButton:name andAction:action andX:left ? lx : rx andY:SLCellHeight * (6 + row) + SLPadding * row andWidth:width];
}

- (void) sendOpenAirConditioner {
    // log
    [_consoleTextView setText:@"打开车机空调"];
    
    [SLSTracer withinSpan:@"打开车机空调" block:^{
        [[SLSTracer startSpan:@"校验用户权限"] end];
        [SLSTracer withinSpan:@"发送指令 ==>> 打开空调" block:^{
            // http request
            NSError *error = nil;
            NSHTTPURLResponse *response = nil;
            [SLSURLSession sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://sls-mall.caa227ac081f24f1a8556f33d69b96c99.cn-beijing.alicontainer.com/catalogue"]]
                                                  returningResponse:&response
                                                              error:&error
            ];
            
            if (response) {
                NSDictionary *fields = [response allHeaderFields];
                NSString *traceId = [fields objectForKey:@"trace-id"];
                [self->_consoleTextView setText:traceId];
            }
        }];
    }];
}

- (void) openAirConditioner {
//    NSString *traceId = self->_consoleTextView.text;
    NSString *traceId = @"00000018361438910000001022299876";
    NSString *spanId = @"6c264809643e04e6";
//    [_consoleTextView setText:[NSString stringWithFormat:@"开始打开空调， traceId: %@", traceId]];
    
    SLSSpan *span = [SLSTracer startSpan:@"收到指令<<= 打开空调"];
    [span addLink:[SLSLink linkWithTraceId:traceId spanId:spanId], nil];
//    [span setTraceID:traceId];
//    [span setParentSpanID:spanId];
    [span end];
    
    [SLSTracer withinSpan:@"执行打开空调指令" active:YES parent:span block:^{
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
    }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
