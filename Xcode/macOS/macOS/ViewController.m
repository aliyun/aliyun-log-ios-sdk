//
//  ViewController.m
//  macOS
//
//  Created by gordon on 2022/3/9.
//

#import "ViewController.h"
#import <AliyunLogProducer/AliyunLogProducer.h>
#import "DemoUtils.h"

@interface ViewController ()
@property(nonatomic, strong) LogProducerClient *client;
@property(nonatomic, strong) LogProducerConfig *config;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _config = [[LogProducerConfig alloc] initWithEndpoint:[DemoUtils sharedInstance].endpoint project:[DemoUtils sharedInstance].project logstore:[DemoUtils sharedInstance].logstore];
    _client = [[LogProducerClient alloc] initWithLogProducerConfig:_config];
//    [_client setEnableTrack:YES];

    // Do any additional setup after loading the view.
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)onSend:(id)sender {
    Log *log = [[Log alloc] init];
    [log PutContent:@"key" value:@"value"];
    
    [_client AddLog:log];
}

- (IBAction)onCrash:(id)sender {
    [self performSelector:@selector(die_die)];
}

@end
