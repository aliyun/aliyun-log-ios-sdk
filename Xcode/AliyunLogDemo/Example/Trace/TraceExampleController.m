//
//  TraceExampleController.m
//  AliyunLogDemo
//
//  Created by gordon on 2022/1/10.
//

#import "TraceExampleController.h"

@interface Setter : NSObject  <TelemetrySetter>
@end

@implementation Setter
- (void)set:(NSMutableDictionary * _Nonnull)dict :(NSString * _Nonnull)key :(NSString * _Nonnull)value {
    [dict setObject:value forKey:key];
}
@end

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
    [self initTrace];
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

    [self createButton:@"span" andAction:@selector(span) andX:lx andY:SLCellHeight * 11];
    [self createButton:@"trace" andAction:@selector(trace) andX:rx andY:SLCellHeight * 11];
    
    [self createButton:@"inject" andAction:@selector(inject) andX:lx andY:SLCellHeight * 12 + SLPadding];
}

- (void) updateStatus: (NSString *)append {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status = [NSString stringWithFormat:@"%@\n> %@", self.statusTextView.text, append];
        [self.statusTextView setText:status];
        [self.statusTextView scrollRangeToVisible:NSMakeRange(self->_statusTextView.text.length, 1)];
    });
}

- (void) span {
    TelemetrySDK *sdk = [TelemetrySDK instance];
    [[[[sdk getTracer:@"demo"] spanBuilderWithSpanName:@"test"] startSpan] end];
    [self updateStatus:@"单个 span 节点"];
}

- (void) trace {
    TelemetrySDK *sdk = [TelemetrySDK instance];
    TelemetryTracer *tracer = [sdk getTracer:@"demo"];
    TelemetrySpan *span = [[tracer spanBuilderWithSpanName:@"test"] startSpan];
    
    TelemetrySpan *span2 = [[[tracer spanBuilderWithSpanName:@"test2"] setParent:span] startSpan];
    [span2 end];
    
    TelemetrySpan *span3 = [[[tracer spanBuilderWithSpanName:@"test2"] setParent:span] startSpan];
    [span3 end];
    
    [span end];
    [self updateStatus:@"多个 span 进行关联"];
}

- (void) inject {
    TelemetrySDK *sdk = [TelemetrySDK instance];
    TelemetrySpan *span = [[[sdk getTracer:@"demo"] spanBuilderWithSpanName:@"test"] startSpan];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [[sdk activeTextMapPropagator] injectWithContext:span.context carrier:dict setter:[[Setter alloc] init]];
    [span setAttributeWithKey:@"inject-traceparent" value:[[TelemetryAttributeValue alloc] initWithStringValue:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil] encoding:NSUTF8StringEncoding]]];
    [span end];
    
    [self updateStatus:@"span 和 traceparent header 进行关联，用于前后端打通"];
}

- (void) initTrace {
    DemoUtils *utils = [DemoUtils sharedInstance];
    SLSConfig *config = [[SLSConfig alloc] init];
    // 正式发布时建议关闭
    [config setDebuggable:YES];

//    [config setEndpoint: [utils endpoint]];
//    [config setPluginLogproject: [utils project]];
//    [config setPluginLogstore:[utils logstore]];
    [config setAccessKeyId: [utils accessKeyId]];
    [config setAccessKeySecret: [utils accessKeySecret]];
    [config setPluginAppId: [utils pluginAppId]];
    [config setEndpoint:@"https://cn-beijing.log.aliyuncs.com"];
    [config setPluginLogproject:@"qs-demos"];
    [config setPluginLogstore:@"sls-mall-traces"];
//    [config setTraceEndpoint:@"https://cn-beijing.log.aliyuncs.com"];
//    [config setTraceLogproject:@"qs-demos"];
//    [config setTraceLogstore:@"sls-mall-traces"];

    [config setUserId:@"test_userid"];
    [config setChannel:@"test_channel"];
    [config addCustomWithKey:@"customKey" andValue:@"testValue"];

    SLSAdapter *slsAdapter = [SLSAdapter sharedInstance];
    [slsAdapter addPlugin:[[SLSTracePlugin alloc]init]];
    [slsAdapter initWithSLSConfig:config];
}

@end
