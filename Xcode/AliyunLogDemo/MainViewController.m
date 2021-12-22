//
//  MainViewController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/18.
//

#import "MainViewController.h"
#import "ViewController.h"
#import "ProducerExampleController.h"
#import "ProducerExampleNoCacheController.h"
#import "ProducerExampleDynamicController.h"
#import "ProducerExampleClientsController.h"
#import "ProducerExampleImmediateController.h"
#import "CrashExampController.h"
#import "ProducerExampleDestroyController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"SLS iOS Demo";
    [self.navigationController.navigationBar setBackgroundColor:[UIColor systemBlueColor]];

    UIColor * color = [UIColor whiteColor];
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self initViews];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createButton:@"基本配置" andAction:@selector(gotoGeneralPage) andX: 0 andY: 0];
    [self createButton:@"没有缓存" andAction:@selector(gotoNoCachePage) andX: SLCellWidth + SLPadding andY: 0];
    [self createButton:@"动态配置" andAction:@selector(gotoDynamicPage) andX: (SLCellWidth + SLPadding) * 2 andY: 0];
    
    [self createButton:@"多个实例" andAction:@selector(gotoClientsPage) andX: 0 andY: SLCellHeight + 10];
    [self createButton:@"立即发送" andAction:@selector(gotoImediatePage) andX: SLCellWidth + SLPadding andY:  SLCellHeight + 10];
    [self createButton:@"销毁配置" andAction:@selector(gotoDestroyPage) andX: (SLCellWidth + SLPadding) * 2 andY: SLCellHeight + 10];
    
    
    [self createButton:@"崩溃监控" andAction:@selector(gotoCrashMockPage) andX: 0 andY: (SLCellHeight + 30) * 2];
    [self createButton:@"trace" andAction:@selector(gotoNoCachePage) andX: SLCellWidth + SLPadding andY:  (SLCellHeight + 30) * 2];
    
}

- (void) gotoGeneralPage {
    [self gotoPageWithPage:[[ProducerExampleController alloc] init]];
}

- (void) gotoNoCachePage {
    [self gotoPageWithPage:[[ProducerExampleNoCacheController alloc] init]];
}

- (void) gotoDynamicPage {
    [self gotoPageWithPage:[[ProducerExampleDynamicController alloc] init]];
}

- (void) gotoClientsPage {
    [self gotoPageWithPage:[[ProducerExampleClientsController alloc] init]];
}

- (void) gotoImediatePage {
    [self gotoPageWithPage:[[ProducerExampleImmediateController alloc] init]];
}

- (void) gotoDestroyPage {
    [self gotoPageWithPage:[[ProducerExampleDestroyController alloc] init]];
}

- (void) gotoCrashMockPage {
    [self gotoPageWithPage:[[CrashExampController alloc] init]];
}

- (void) gotoPageWithPage: (ViewController *) controller {
    [self.navigationController pushViewController:controller animated:YES];
}

@end
