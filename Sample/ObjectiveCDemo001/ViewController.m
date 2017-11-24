//
//  ViewController.m
//  ObjectiveCDemo001
//
//  Created by 王铮 on 2017/11/22.
//  Copyright © 2017年 wangjwchn. All rights reserved.
//

#import "ViewController.h"
@import AliyunLOGiOS;

@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * ENDPOINT = @"******";
    NSString * PROJECTNAME = @"******";
    NSString * LOGSTORENAME = @"******";
    
    //        移动端是不安全环境，不建议直接使用阿里云主账号ak，sk的方式。建议使用STS方式。具体参见 https://help.aliyun.com/document_detail/62643.html
    //        注意：只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。
    //        通过主账号AK，SK使用日志服务
    
    //    NSString * AK = @"******";
    //    NSString * SK = @"******";
    //    LOGClient * client = [[LOGClient alloc] initWithEndPoint:ENDPOINT accessKeyID:AK accessKeySecret:SK projectName:PROJECTNAME];
    
    //通过STS使用日志服务
    NSString * STS_AK = @"******";
    NSString * STS_SK = @"******";
    NSString * STS_TOKEN = @"******";
    
    LOGClient * client = [[LOGClient alloc] initWithEndPoint:ENDPOINT accessKeyID:STS_AK accessKeySecret:STS_SK token:STS_TOKEN projectName:PROJECTNAME];
    
    //  log调试开关
    client.mIsLogEnable = true;
    
    Log * loginfo = [[Log alloc] init];
    [loginfo PutContent:@"key001" value:@"value001"];
    
    LogGroup * group = [[LogGroup alloc] initWithTopic:@"topic" source:@"object-c"];
    [group PutLog:loginfo];
    
    [client PostLog:group logStoreName:LOGSTORENAME call:^(NSURLResponse *response,NSError *error) {
        NSLog(@"response %@", [response debugDescription]);
        NSLog(@"error %@",[error debugDescription]);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
