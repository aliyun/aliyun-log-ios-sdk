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
	

#import "BenchmarkViewController.h"
#import <AliyunLogProducer/AliyunLogProducer.h>
#import <mach/mach_time.h>

@interface BenchmarkViewController ()

@end



@implementation BenchmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
//    selfClzz = self;
    self.title = @"网络监控";
    [self initViews];
}

- (void) initViews {
    [self createButton:@"内存写 1条/s" andAction:@selector(benchmarkMemWrite1s) andX:0 andY:SLCellHeight * 1];
}

- (void) benchmarkMemWrite1s {
    LogProducerConfig *config = [[LogProducerConfig alloc] initWithEndpoint:@"" project:@"" logstore:@""];
    LogProducerClient *client = [[LogProducerClient alloc] initWithLogProducerConfig:config];
    
    for (int i = 0; i < 60; i ++) {
        uint64_t start = mach_absolute_time();
        bool succ = [client AddLog:[self oneLog]] == LogProducerOK;
        NSLog(@"add log ret: %d", succ);
        uint64_t end = mach_absolute_time();
        sleepNanoTime(start, end, 1000);
    }
}

- (Log *) oneLog {
    Log* log = [[Log alloc] init];

    [log PutContent:@"content_key_1" value:@"1abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+"];
    [log PutContent:@"content_key_2" value:@"2abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_3" value:@"3abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_4" value:@"4abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_5" value:@"5abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_6" value:@"6abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_7" value:@"7abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_8" value:@"8abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content_key_9" value:@"9abcdefghijklmnopqrstuvwxyz0123456789"];
    [log PutContent:@"content" value:@"中文"];

    return log;
}


void sleepNanoTime(uint64_t start, uint64_t end, uint64_t want) {
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    uint64_t diff = end * timebase.numer / timebase.denom - start * timebase.numer / timebase.denom;
    if (diff / 1000000 < want) {
        usleep((useconds_t)(want*1000 - diff / 1000));
    }
}

@end
