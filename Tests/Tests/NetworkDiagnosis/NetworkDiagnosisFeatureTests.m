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


#import <XCTest/XCTest.h>
#import "OCMock.h"

#import "SLSNetworkDiagnosisFeature.h"

#import "AliNetworkDiagnosis/AliDns.h"
#import "AliNetworkDiagnosis/AliHttpPing.h"
#import "AliNetworkDiagnosis/AliMTR.h"
#import "AliNetworkDiagnosis/AliPing.h"
#import "AliNetworkDiagnosis/AliTcpPing.h"
#import "AliNetworkDiagnosis/AliNetworkDiagnosis.h"

@interface NetworkDiagnosisFeatureTests : XCTestCase
@property(nonatomic, strong) SLSNetworkDiagnosisFeature *feature;
@end

@implementation NetworkDiagnosisFeatureTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _feature = [[SLSNetworkDiagnosisFeature alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark -- http
- (void)test_networkDiagnosis$http {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliHttpPingConfig __block *config;
    [[diagnosis expect] http:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    [_feature http:@"www.aliyun.com"];
    
    XCTAssertEqualObjects(config.url, @"www.aliyun.com");
}

- (void) test_networkDiagnosis$http$credentials {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliHttpPingConfig __block *config;
    [[diagnosis expect] http:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:NULL certificates:NULL persistence:NSURLCredentialPersistenceForSession];
    
    [_feature http:@"www.aliyun.com" callback:^(NSString * _Nonnull result) {
        return;
    } credential:^NSURLCredential * _Nullable(NSString * _Nonnull url) {
        return credential;
    }];
    
    XCTAssertEqualObjects(config.url, @"www.aliyun.com");
    XCTAssertEqual(config.clientCredential, credential);
}

- (void) test_networkDiagnosis$http2 {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliHttpPingConfig __block *config;
    [[diagnosis expect] http:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    SLSHttpRequest *request = [[SLSHttpRequest alloc] init];
    request.domain = @"www.aliyun.com";
    
    [_feature http2:request];
    
    XCTAssertEqualObjects(config.url, request.domain);
    XCTAssertNil(config.clientCredential);
}

- (void) test_networkDiagnosis$http2$credential {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliHttpPingConfig __block *config;
    [[diagnosis expect] http:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    SLSHttpRequest *request = [[SLSHttpRequest alloc] init];
    request.domain = @"www.aliyun.com";
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:NULL certificates:NULL persistence:NSURLCredentialPersistenceForSession];
    request.credential = ^NSURLCredential * _Nullable(NSString * _Nonnull url) {
        return credential;
    };
    
    [_feature http2:request];
    
    XCTAssertEqualObjects(config.url, request.domain);
    XCTAssertEqual(config.clientCredential, credential);
}

#pragma mark -- ping tests
- (void) test_networkDiagnosis$ping {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliPingConfig __block *config;
    [[diagnosis expect] ping:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature ping:@"www.aliyun.com"];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
}

- (void) test_networkDiagnosis$ping$size {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliPingConfig __block *config;
    [[diagnosis expect] ping:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature ping:@"www.aliyun.com" size:1024 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.size, 1024);
}


- (void) test_networkDiagnosis$ping$size$maxTimes$timeout {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliPingConfig __block *config;
    [[diagnosis expect] ping:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature ping:@"www.aliyun.com" size:1024 maxTimes:10 timeout:20 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.size, 1024);
    XCTAssertEqual(config.count, 10);
    XCTAssertEqual(config.timeout, 20);
}

- (void) test_networkDiagnosis$ping$maxTimes$timeout {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliPingConfig __block *config;
    [[diagnosis expect] ping:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature ping:@"www.aliyun.com" maxTimes:10 timeout:20 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.count, 10);
    XCTAssertEqual(config.timeout, 20);
}

#pragma mark -- tcp ping
- (void) test_networkDiagnosis$tcpping$domain$port {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliTcpPingConfig __block *config;
    [[diagnosis expect] tcpPing:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature tcpPing:@"www.aliyun.com" port:88];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.port, 88);
}

- (void) test_networkDiagnosis$tcpping$domain$port$maxTimes {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliTcpPingConfig __block *config;
    [[diagnosis expect] tcpPing:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature tcpPing:@"www.aliyun.com" port:88 maxTimes:33 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.port, 88);
    XCTAssertEqual(config.count, 33);
}

- (void) test_networkDiagnosis$tcpping$domain$port$maxTimes$timeout {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliTcpPingConfig __block *config;
    [[diagnosis expect] tcpPing:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature tcpPing:@"www.aliyun.com" port:88 maxTimes:33 timeout:10 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.port, 88);
    XCTAssertEqual(config.count, 33);
    XCTAssertEqual(config.timeout, 10);
}

- (void) test_networkDiagnosis$tcpping2$request {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliTcpPingConfig __block *config;
    [[diagnosis expect] tcpPing:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    SLSTcpPingRequest *request = [[SLSTcpPingRequest alloc] init];
    request.domain = @"www.aliyun.com";
    request.port = 88;
    request.maxTimes = 33;
    request.timeout = 10;
    request.context = @"test";
    
    [_feature tcpPing2:request];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.port, 88);
    XCTAssertEqual(config.count, 33);
    XCTAssertEqual(config.timeout, 10);
    XCTAssertEqualObjects(config.context, @"test");
}

- (void) test_networkDiagnosis$mtr$domain {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliMTRConfig __block *config;
    [[diagnosis expect] mtr:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature mtr:@"www.aliyun.com"];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
}

- (void) test_networkDiagnosis$mtr$domain$maxTTL {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliMTRConfig __block *config;
    [[diagnosis expect] mtr:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature mtr:@"www.aliyun.com" maxTTL:11 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.maxTtl, 11);
}

- (void) test_networkDiagnosis$mtr$domain$maxTTL$maxPaths {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliMTRConfig __block *config;
    [[diagnosis expect] mtr:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature mtr:@"www.aliyun.com" maxTTL:11 maxPaths:5 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.maxTtl, 11);
    XCTAssertEqual(config.maxPaths, 5);
}

- (void) test_networkDiagnosis$mtr$domain$maxTTL$maxPaths$maxTimes {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliMTRConfig __block *config;
    [[diagnosis expect] mtr:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature mtr:@"www.aliyun.com" maxTTL:11 maxPaths:5 maxTimes:4 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.maxTtl, 11);
    XCTAssertEqual(config.maxPaths, 5);
    XCTAssertEqual(config.maxTimesEachIP, 4);
}

- (void) test_networkDiagnosis$mtr$domain$maxTTL$maxPaths$maxTimes$timeout {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliMTRConfig __block *config;
    [[diagnosis expect] mtr:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    [_feature mtr:@"www.aliyun.com" maxTTL:11 maxPaths:5 maxTimes:4 timeout: 39 callback:nil];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.maxTtl, 11);
    XCTAssertEqual(config.maxPaths, 5);
    XCTAssertEqual(config.maxTimesEachIP, 4);
    XCTAssertEqual(config.timeout, 39);
}

- (void) test_networkDiagnosis$mtr2$request {
    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
    AliMTRConfig __block *config;
    [[diagnosis expect] mtr:[OCMArg checkWithBlock:^BOOL(id obj) {
        config = obj;
        return YES;
    }]];
    [_feature setDiagnosis:diagnosis];
    
    SLSMtrRequest *request = [[SLSMtrRequest alloc] init];
    request.domain = @"www.aliyun.com";
    request.maxTTL = 11;
    request.maxPaths = 5;
    request.maxTimes = 4;
    request.timeout = 39;
    
    [_feature mtr2:request];
    
    XCTAssertEqualObjects(config.host, @"www.aliyun.com");
    XCTAssertEqual(config.maxTtl, 11);
    XCTAssertEqual(config.maxPaths, 5);
    XCTAssertEqual(config.maxTimesEachIP, 4);
    XCTAssertEqual(config.timeout, 39);
}

//- (void) test_networkDiagnosis$dns$domain {
//    id diagnosis = [OCMockObject mockForClass:[NetSpeedDiagnosis class]];
//    AliDnsConfig __block *config;
//    [[diagnosis expect] dns:[OCMArg checkWithBlock:^BOOL(id obj) {
//        config = obj;
//        return YES;
//    }]];
//    [_feature setDiagnosis:diagnosis];
//    
//    
//    [_feature dns:@"www.aliyun.com"];
//    
//    XCTAssertEqualObjects(config.src, @"www.aliyun.com");
//}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
