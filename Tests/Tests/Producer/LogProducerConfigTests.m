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
	

#import "BaseTestCase.h"
#import "AliyunLogProducer/AliyunLogProducer.h"



QuickSpecBegin(LogProducerConfigTests)

__block LogProducerConfig *config;
beforeEach(^{
    config = [[LogProducerConfig alloc] initWithEndpoint:@"" project:@"" logstore:@""];
});

describe(@"setEndpoint", ^{
    it(@"has endpoint", ^{
        [config setEndpoint:@"cn-hangzhou.log.aliyuncs.com"];
        expect([config getEndpoint]).to(equal(@"https://cn-hangzhou.log.aliyuncs.com"));
    });
});

describe(@"setProject", ^{
    it(@"has project", ^{
        [config setProject:@"test_project"];
        expect([config getProject]).to(equal(@"test_project"));
    });
});

describe(@"setLogStore", ^{
    it(@"has logStore", ^{
        [config setLogstore:@"my_logstore"];
        expect([config getLogStore]).to(equal(@"my_logstore"));
    });
});

QuickSpecEnd
