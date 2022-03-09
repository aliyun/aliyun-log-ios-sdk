//
//  ViewController.m
//  macOS
//
//  Created by gordon on 2022/3/9.
//

#import "ViewController.h"
#import <AliyunLogProducer/AliyunLogProducer.h>
#import "DemoUtils.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onCrash:(id)sender {
    [self performSelector:@selector(die_die)];
}

@end
