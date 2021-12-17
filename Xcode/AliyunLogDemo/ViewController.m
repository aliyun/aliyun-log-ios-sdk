//
//  ViewController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/17.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)sendLog:(id)sender {
    
}
- (IBAction)mockCrash:(id)sender {
    [self performSelector:@selector(die_die)];
}


@end
