//
//  ViewController.m
//  tvOS
//
//  Created by gordon on 2022/3/14.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)click:(id)sender {
    [self performSelector:@selector(die_die)];
}

@end
