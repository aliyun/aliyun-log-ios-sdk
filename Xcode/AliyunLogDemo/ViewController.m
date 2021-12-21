//
//  ViewController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/17.
//

#import "ViewController.h"
#import "DemoUtils.h"
#import <AliyunLogProducer/LogProducerClient+Bricks.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIButton *) createButton: (NSString *) title andAction: (SEL) action andX: (CGFloat) x andY: (CGFloat) y {
    return [self createButton:title andAction:action andX:x andY:y andWidth:SLCellWidth andHeight:SLCellHeight];
}

- (UIButton *) createButton: (NSString *) title andAction: (SEL) action andX: (CGFloat) x andY: (CGFloat) y andWidth: (CGFloat) width andHeight: (CGFloat) height {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SLPadding + x, SLNavBarAndStatusBarHeight + SLPadding * 2 + y, width, height)];
    button.backgroundColor = [UIColor systemBlueColor];
    button.layer.cornerRadius = 4;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    
    return button;
}

- (UILabel *) createLabel: (NSString *)title andX: (CGFloat) x andY: (CGFloat) y {
    return [self createLabel:title andX:x andY:y andWidth:SLCellWidth andHeight:SLCellHeight];
}

- (UILabel *) createLabel: (NSString *) title andX: (CGFloat) x andY: (CGFloat) y andWidth: (CGFloat) width andHeight: (CGFloat) height {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SLPadding + x, SLNavBarAndStatusBarHeight + SLPadding * 2 + y, width, height)];
    label.backgroundColor = [UIColor whiteColor];
    [label setTextColor:[UIColor blackColor]];
    [label setText: title];
    
    [self.view addSubview:label];
    
    return label;
}

- (UITextView *) createTextView: (NSString *) text andX: (CGFloat) x andY: (CGFloat) y andWidth: (CGFloat) width andHeight: (CGFloat) height {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(SLPadding + x, SLNavBarAndStatusBarHeight + SLPadding * 2 + y, width, height)];
    textView.backgroundColor = [UIColor whiteColor];
    [textView setTextColor:[UIColor blackColor]];
    [textView setText:text];
    
    [self.view addSubview:textView];
    return textView;
}

@end
