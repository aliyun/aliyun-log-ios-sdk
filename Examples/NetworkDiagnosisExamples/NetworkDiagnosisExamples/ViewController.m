//
// Copyright 2023 aliyun-sls Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ViewController.h"
#import <AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.h>

@interface ViewController ()
@property(nonatomic, strong) NSString *accessKeyId;
@property(nonatomic, strong) NSString *accessKeySecret;
@property(nonatomic, strong) NSString *secretKey;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.accessKeyId = @"";
    self.accessKeySecret = @"";
    self.secretKey = @"";
}

/// 初始化SDK
- (IBAction)initSDK:(id)sender  {
    SLSCredentials *credentials = [SLSCredentials credentials];
    // endpoint和project不支持动态更新，请在初始化SDK时指定
    credentials.endpoint = @"https://cn-beijing.log.aliyuncs.com";
    credentials.project = @"mobile-demo-beijing-b";

    // AccessKey建议通过STS方式获取，参考下面的文档：
    // https://help.aliyun.com/zh/sls/user-guide/build-a-service-to-upload-logs-from-mobile-apps-to-log-service
    // AccessKey在初始化时可以先不填，后续通过[[SLSCocoa sharedInstance] setCredentials:credentials];方法可以更新，参考后面的updateSDK方法实现
    credentials.accessKeyId = self.accessKeyId;
    credentials.accessKeySecret = self.accessKeySecret;
//    credentials.securityToken = @"<your accessKey securityToken>"; // 仅当AccessKey是通过STS服务获取时需要

    SLSNetworkDiagnosisCredentials *networkCredentials = [credentials createNetworkDiagnosisCredentials];
    //secretKey不支持动态更新，请在初始化时设置。
    networkCredentials.secretKey = self.secretKey;
    
    // （可选）设置业务扩展字段。仅对新产生的探测数据生效。
    // 不支持动态更新，请在SDK初始化时设置。
    [networkCredentials putExtension:@"custom_value" forKey:@"custom_key"];

    [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
          configuration.enableNetworkDiagnosis = YES;
    }];
    
    // （可选）设置设备ID，可在任何时机调用，仅对新产生的探测数据生效。
    [SLSUtdid setUtdid:@"<your device id"];
    
    // （可选）配置用户信息，可在任何时机调用。仅对新产生的探测数据生效。
    SLSUserInfo *userInfo = [SLSUserInfo userInfo];
    userInfo.uid = @"<your user id>";
    userInfo.channel = @"<your user channel";
    [userInfo addExt:@"ext_value" key:@"ext_key"];
    [[SLSCocoa sharedInstance] setUserInfo:userInfo];
    
}

///动态更新SDK参数，当前支持更新AccessKey
- (IBAction)updateSDK:(id)sender {
    SLSCredentials *credentials = [SLSCredentials credentials];
    credentials.accessKeyId = @"<your new accessKeyId>";
    credentials.accessKeySecret = @"<your new accessKeySecret>";
    credentials.securityToken = @"<your new accessKey securityToken>";
    
    [[SLSCocoa sharedInstance] setCredentials:credentials];
}

/// 隐私合规方式初始化SDK
- (IBAction)preInit:(id)sender {
    SLSCredentials *credentials = [SLSCredentials credentials];
    // endpoint和project不支持动态更新，请在初始化SDK时指定
    credentials.endpoint = @"https://cn-beijing.log.aliyuncs.com";
    credentials.project = @"mobile-demo-beijing-b";

    // AccessKey建议通过STS方式获取，参考下面的文档：
    // https://help.aliyun.com/zh/sls/user-guide/build-a-service-to-upload-logs-from-mobile-apps-to-log-service
    // AccessKey在初始化时可以先不填，后续通过[[SLSCocoa sharedInstance] setCredentials:credentials];方法可以更新，参考后面的updateSDK方法实现
    credentials.accessKeyId = self.accessKeyId;
    credentials.accessKeySecret = self.accessKeySecret;

    SLSNetworkDiagnosisCredentials *networkCredentials = [credentials createNetworkDiagnosisCredentials];
    //secretKey不支持动态更新，请在初始化时指定
    networkCredentials.secretKey = self.secretKey;
    
    // （可选）设置业务扩展字段。仅对新产生的探测数据生效。
    // 不支持动态更新，请在SDK初始化时设置。
    [networkCredentials putExtension:@"custom_value" forKey:@"custom_key"];

    // 用户接受隐私协议之前，先调用preInit完成SDK初始化。
    [[SLSCocoa sharedInstance] preInit:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
            configuration.enableNetworkDiagnosis = YES;
    }];
    
    // 用户接受隐私协议之后，再调用initialize完成SDK的完整初始化。
    [[SLSCocoa sharedInstance] initialize:credentials configuration:^(SLSConfiguration * _Nonnull configuration) {
          configuration.enableNetworkDiagnosis = YES;
    }];
    
    // （可选）设置设备ID，可在任何时机调用，仅对新产生的探测数据生效。
    [SLSUtdid setUtdid:@"<your device id"];
    
    // （可选）配置用户信息，可在任何时机调用。仅对新产生的探测数据生效。
    SLSUserInfo *userInfo = [SLSUserInfo userInfo];
    userInfo.uid = @"<your user id>";
    userInfo.channel = @"<your user channel";
    [userInfo addExt:@"ext_value" key:@"ext_key"];
    [[SLSCocoa sharedInstance] setUserInfo:userInfo];
}


- (IBAction)ping:(id)sender {
    SLSPingRequest *request = [[SLSPingRequest alloc] init];
    // 必填参数：
    // 域名
    request.domain = @"www.aliyun.com";
    
    // 可选参数:
    // context id，在探测结果回调中会返回该值
    request.context = @"context id";
    // 探测任务是否支持并发，默认为串行
    request.parallel = YES;
    // 探测超时时间, 默认2000ms
    request.timeout = 3000;
    // 最大探测次数，默认10次
    request.maxTimes = 10;
    // 探测包大小，默认64
    request.size = 64;
    // 探测扩展参数
    request.extention = @{
        @"ext_key": @"ext_value"
    };
    
    [[SLSNetworkDiagnosis sharedInstance] ping2: request callback:^(SLSResponse * _Nonnull response) {
        NSLog(@"ping result type: %@", response.type);
        NSLog(@"ping result context: %@", response.context);
        NSLog(@"ping result content: %@", response.content);
        NSLog(@"ping result error: %@", response.error);
    }];
}

- (IBAction)tcpping:(id)sender {
    SLSTcpPingRequest *request = [[SLSTcpPingRequest alloc] init];
    // 必填参数：
    // 域名
    request.domain = @"www.aliyun.com";
    request.port = 80;
    
    // 可选参数:
    // context id，在探测结果回调中会返回该值
    request.context = @"context id";
    // 探测超时时间, 默认2000ms
    request.timeout = 3000;
    // 最大探测次数，默认10次
    request.maxTimes = 10;
    // 探测包大小，默认64
    request.size = 64;
    // 探测扩展参数
    request.extention = @{
        @"ext_key": @"ext_value"
    };
    
    [[SLSNetworkDiagnosis sharedInstance] tcpPing2: request callback:^(SLSResponse * _Nonnull response) {
        NSLog(@"tcp ping result type: %@", response.type);
        NSLog(@"tcp ping result context: %@", response.context);
        NSLog(@"tcp ping result content: %@", response.content);
        NSLog(@"tcp ping result error: %@", response.error);
    }];
    
}

- (IBAction)dns:(id)sender {
    SLSDnsRequest *request = [[SLSDnsRequest alloc] init];
    // 必填参数：
    // 域名
    request.domain = @"www.aliyun.com";
    
    // 可选参数:
    // context id，在探测结果回调中会返回该值
    request.context = @"context id";
    // IP类型，取值为：
    // IPv4：A
    // IPv6：AAAA
    // 默认为A，即IPv4
    request.type = @"A";
    // 域名解析服务，默认为nil
    request.nameServer = @"114.114.114.114";
    // 探测超时时间, 默认2000ms
    request.timeout = 3000;
    // 最大探测次数，默认10次
    request.maxTimes = 10;
    // 探测包大小，默认64
    request.size = 64;
    // 探测扩展参数
    request.extention = @{
        @"ext_key": @"ext_value"
    };
    
    [[SLSNetworkDiagnosis sharedInstance] dns2:request callback:^(SLSResponse * _Nonnull response) {
        NSLog(@"dns result type: %@", response.type);
        NSLog(@"dns result context: %@", response.context);
        NSLog(@"dns result content: %@", response.content);
        NSLog(@"dns result error: %@", response.error);
    }];
    
}

- (IBAction)mtr:(id)sender {
    SLSMtrRequest *request = [[SLSMtrRequest alloc] init];
    // 必填参数：
    // 域名
    request.domain = @"www.aliyun.com";
    
    // 可选参数:
    // context id，在探测结果回调中会返回该值
    request.context = @"context id";
    // 探测任务是否支持并发，默认为串行
    request.parallel = YES;
    // 最大ttl，默认为30
    request.maxTTL = 30;
    // 最大path，默认为1
    request.maxPaths = 1;
    // 探测协议，取值为：
    // 全部：SLS_MTR_PROROCOL_ALL
    // ICMP：SLS_MTR_PROROCOL_ICMP
    // UDP：SLS_MTR_PROROCOL_UDP
    // 默认为SLS_MTR_PROROCOL_ALL
    request.protocol = SLS_MTR_PROROCOL_ICMP;
    // 探测超时时间, 默认2000ms
    request.timeout = 3000;
    // 最大探测次数，默认10次
    request.maxTimes = 10;
    // 探测包大小，默认64
    request.size = 64;
    // 探测扩展参数
    request.extention = @{
        @"ext_key": @"ext_value"
    };
    
    [[SLSNetworkDiagnosis sharedInstance] mtr2:request callback:^(SLSResponse * _Nonnull response) {
        NSLog(@"mtr result type: %@", response.type);
        NSLog(@"mtr result context: %@", response.context);
        NSLog(@"mtr result content: %@", response.content);
        NSLog(@"mtr result error: %@", response.error);
    }];
}

- (IBAction)http:(id)sender {
    SLSHttpRequest *request = [[SLSHttpRequest alloc] init];
    // 必填参数：
    // 域名
    request.domain = @"https://www.aliyun.com";
    
    // 可选参数:
    // context id，在探测结果回调中会返回该值
    request.context = @"context id";
    // 探测超时时间, 默认2000ms
    request.timeout = 3000;
    // 下载内容大小限制，默认为不限制
    request.downloadBytesLimit = 1024;
    // 是否只请求header，默认为YES
    request.headerOnly = YES;
    // 探测扩展参数
    request.extention = @{
        @"ext_key": @"ext_value"
    };
    
    [[SLSNetworkDiagnosis sharedInstance] http2:request callback:^(SLSResponse * _Nonnull response) {
        NSLog(@"http result type: %@", response.type);
        NSLog(@"http result context: %@", response.context);
        NSLog(@"http result content: %@", response.content);
        NSLog(@"http result error: %@", response.error);
    }];
}

@end
