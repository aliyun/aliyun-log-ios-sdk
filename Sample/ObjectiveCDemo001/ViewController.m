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
    
    
    NSString * ENDPOINT = @"http://cn-hangzhou.log.aliyuncs.com";
    NSString * PROJECTNAME = @"******";
    NSString * LOGSTORENAME = @"******";
    
    //        移动端是不安全环境，不建议直接使用阿里云主账号ak，sk的方式。建议使用STS方式。具体参见 https://help.aliyun.com/document_detail/62681.html
    //        注意：只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。
    //        通过主账号AK，SK使用日志服务
    
    //    NSString * AK = @"******";
    //    NSString * SK = @"******";
    //    LOGClient * client = [[LOGClient alloc] initWithEndPoint:ENDPOINT accessKeyID:AK accessKeySecret:SK projectName:PROJECTNAME];
    
    //通过STS使用日志服务,如果是Objective-C工程的话，需要设置Build Settings -- Embedded Content Contains Swift Code 为 Yes
    //更多请参见 https://help.aliyun.com/document_detail/62681.html
    NSString * STS_AK = @"******";
    NSString * STS_SK = @"******";
    NSString * STS_TOKEN = nil;
    
    SLSConfig *clientConfig = [[SLSConfig alloc] initWithConnectType:SLSConnectionTypeWifi cachable:YES];
    
    LOGClient * client = [[LOGClient alloc] initWithEndPoint:ENDPOINT accessKeyID:STS_AK accessKeySecret:STS_SK projectName:PROJECTNAME token:nil config:clientConfig];
    
    //  log调试开关
    client.mIsLogEnable = true;
    
    Log * loginfo = [[Log alloc] init];
    [loginfo PutContent:@"key001" value:@"value001"];
    
    LogGroup * group = [[LogGroup alloc] initWithTopic:@"topic" source:@"object-c"];
    [group PutLog:loginfo];
    
    [client PostLog:group logStoreName:LOGSTORENAME call:^(NSURLResponse *response,NSError *error) {
        if (error) {
            NSLog(@"直接发送失败%@", error);
        } else {
            NSLog(@"直接发送成功");
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
