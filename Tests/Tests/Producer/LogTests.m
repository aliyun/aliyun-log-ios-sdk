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
	

//#import <XCTest/XCTest.h>
#import "BaseTestCase.h"
//#import "AliyunLogProducer.h"
//#import "AliyunLogProducer/AliyunLogProducer.h"
#import "AliyunLogProducer/AliyunLogProducer.h"
#import "Log+Test.h"


//@interface LogTests : BaseTestCase
////@property(nonatomic, strong) LogProducerConfig *config;
////@property(nonatomic, strong) LogProducerClient *client;
//@property(nonatomic, strong) Log *log;
//@end
//
//@implementation LogTests
QuickSpecBegin(LogTests)

__block Log *_log = nil;
beforeEach(^{
    _log = [Log log];
});

describe(@"putContent:value", ^{
    afterEach(^{
        [_log clear];
    });
    
    it(@"put stringValue", ^{
        [_log putContent:@"stringValue" value:@"stringValue"];
        expect(_log.getContent[@"stringValue"]).to(equal(@"stringValue"));
    });
    
    it(@"put stringValue with nil", ^{
        [_log putContent:@"stringValue" value:nil];
        expect(_log.getContent[@"stringValue"]).to(beNil());
    });
    
    it(@"put stringValue with empty", ^{
        [_log putContent:@"stringValue" value:@""];
        expect(_log.getContent[@"stringValue"]).to(equal(@""));
    });

    it(@"put stringValue with NSNull", ^{
        [_log putContent:@"stringValue" value:[NSNull null]];
        expect(_log.getContent[@"stringValue"]).to(beNil());
    });
});

describe(@"putContent:intValue", ^{
    it(@"put intValue", ^{
        [_log putContent:@"int" intValue:121];
        expect([_log.getContent[@"int"] intValue]).to(equal(121));
    });
});


//- (void) test_log$putContent {
//    [_log clear];
//
//    // nsdata is json
//    NSDictionary *dict = @{
//        @"key": @"value"
//    };
//
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
//    [_log putContent:data];
//    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
//    XCTAssertTrue([_log.getContent[@"key"] isEqualToString:@"value"], @"value is not equal to %@", _log.getContent[@"key"]);
//    [_log clear];
//
//    // nsdata is json array
//    NSArray *array = @[
//        @"array"
//    ];
//    data = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
//    [_log putContent:data];
//    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]], @"value is not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//
//
//    // nsdata is nsstring
//    data = [@"value" dataUsingEncoding:NSUTF8StringEncoding];
//    [_log putContent:data];
//    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:@"value"], @"value is not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//
//    // nsdata is nsnull
//    data = [NSNull null];
//    [_log putContent:data];
//    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:@"null"], @"value is not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//}
//
//- (void) test_log$putContent$dataValue {
//    [_log clear];
//    // nsdata is nsstring
//    NSData *data = [@"dataValue" dataUsingEncoding:NSUTF8StringEncoding];
//    [_log putContent:@"data" dataValue:data];
//    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:@"dataValue"], @"value is not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//
//    // nsdata is json
//    NSDictionary *dict = @{
//        @"key": @"value"
//    };
//
//    data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
//    [_log putContent:@"data" dataValue:data];
//    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]], @"value is not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//
//    // nsdata is json array
//    NSArray *array = @[
//        @"array"
//    ];
//    data = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
//    [_log putContent:@"data" dataValue:data];[_log putContent:data];
//    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]], @"value is not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//}
//
//
//- (void) test_log$putContent$dictValue {
//    [_log clear];
//    NSDictionary *dict = @{
//        @"key1": @"value1",
//        @"key2": @1,
//        @"key3": @1.0f,
//        @"key4": @1L,
//        @"key5": @{
//            @"1key": @"1value",
//            @"2key": @[]
//        },
//        @"key6": @[@"array"]
//    };
//    [_log putContent:nil dictValue:dict];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//    [_log putContent:[NSNull null] dictValue:dict];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//
//    [_log putContent:@"data" dictValue:nil];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//    [_log putContent:@"data" dictValue:[NSNull null]];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//
//    [_log putContent:@"data" dictValue:dict];
//    XCTAssertTrue(_log.getContent.count == 1, @"dict count not %d.", 1);
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc]
//                                                             initWithData:[NSJSONSerialization dataWithJSONObject:dict
//                                                                                                          options:kNilOptions
//                                                                                                            error:nil
//                                                                          ]
//                                                             encoding:NSUTF8StringEncoding
//                                                            ]],
//                  @"value not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//
//    dict = @{
//        @"key1": [NSNull null],
//    };
//    BOOL ret = [_log putContent:@"data" dictValue:dict];
//    XCTAssertTrue(YES == ret, @"NSNull insert sucess");
//    [_log clear];
//}
//
//- (void) test_log$putContent$arrayValue {
//    [_log clear];
//
//    NSArray *array = @[
//        @"array"
//    ];
//    [_log putContent:nil arrayValue:array];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//    [_log putContent:[NSNull null] arrayValue:array];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//
//    [_log putContent:@"data" arrayValue:nil];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//    [_log putContent:@"data" arrayValue:[NSNull null]];
//    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
//    [_log clear];
//
//    [_log putContent:@"data" dictValue:array];
//    XCTAssertTrue(_log.getContent.count == 1, @"dict count not %d.", 1);
//    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc]
//                                                             initWithData:[NSJSONSerialization dataWithJSONObject:array
//                                                                                                          options:kNilOptions
//                                                                                                            error:nil
//                                                                          ]
//                                                             encoding:NSUTF8StringEncoding
//                                                            ]],
//                  @"value not equal to %@", _log.getContent[@"data"]);
//    [_log clear];
//}
//
//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

//@end
QuickSpecEnd
