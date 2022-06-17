//
//  iOSTests.m
//  iOSTests
//
//  Created by gordon on 2022/6/17.
//

#import <XCTest/XCTest.h>
#import <AliyunLogProducer/AliyunLogProducer.h>
#import "Log+Test.h"

@interface iOSTests : XCTestCase
//@property(nonatomic, strong) LogProducerConfig *config;
//@property(nonatomic, strong) LogProducerClient *client;
@property(nonatomic, strong) Log *log;
@end

@implementation iOSTests
//- (void) PutContent: (NSString *) key value: (NSString *) value;
//- (void) putContent: (NSString *) key value: (NSString *) value;
//- (void) putContent: (NSString *) key intValue: (int) value;
//- (void) putContent: (NSString *) key longValue: (long) value;
//- (void) putContent: (NSString *) key longlongValue: (long long) value;
//- (void) putContent: (NSString *) key floatValue: (float) value;
//- (void) putContent: (NSString *) key doubleValue: (double) value;
//- (void) putContent: (NSString *) key boolValue: (BOOL) value;
//- (BOOL) putContent: (NSData *) value;
//- (BOOL) putContent: (NSString *) key dataValue: (NSData *) value;
//- (BOOL) putContent: (NSString *) key arrayValue: (NSArray *) value;
//- (BOOL) putContent: (NSString *) key dictValue: (NSDictionary *) value;
//- (BOOL) putContents: (NSDictionary *) dict;

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _log = [Log log];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void) test_log$PutContent$value {
    [_log PutContent:@"stringValue" value:@"stringValue"];
    XCTAssertEqual(_log.getContent[@"stringValue"], @"stringValue", "string value not stringValue");
    [_log remove:@"stringValue"];
    
    [_log PutContent:@"stringValue" value:nil];
    XCTAssertNil(_log.getContent[@"stringValue"], "string value not nil");
    
    [_log PutContent:@"stringValue" value:@""];
    XCTAssertEqual(_log.getContent[@"stringValue"], @"", "string value not \"\"");
}

- (void) test_log$putContent$intValue {
    [_log putContent:@"int" intValue:1];
    
    XCTAssertEqual([_log.getContent objectForKey:@"int"], [NSNumber numberWithInt:1].stringValue, "int value not 1.");
    [_log remove:@"int"];
}

- (void) test_log$putContent {
    [_log clear];
    
    // nsdata is json
    NSDictionary *dict = @{
        @"key": @"value"
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    [_log putContent:data];
    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
    XCTAssertTrue([_log.getContent[@"key"] isEqualToString:@"value"], @"value is not equal to %@", _log.getContent[@"key"]);
    [_log clear];
    
    // nsdata is json array
    NSArray *array = @[
        @"array"
    ];
    data = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
    [_log putContent:data];
    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]], @"value is not equal to %@", _log.getContent[@"data"]);
    [_log clear];
    
    
    // nsdata is nsstring
    data = [@"value" dataUsingEncoding:NSUTF8StringEncoding];
    [_log putContent:data];
    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:@"value"], @"value is not equal to %@", _log.getContent[@"data"]);
    [_log clear];
    
    // nsdata is nsnull
    //    data = [NSNull null];
}

- (void) test_log$putContent$dataValue {
    [_log clear];
    // nsdata is nsstring
    NSData *data = [@"dataValue" dataUsingEncoding:NSUTF8StringEncoding];
    [_log putContent:@"data" dataValue:data];
    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:@"dataValue"], @"value is not equal to %@", _log.getContent[@"data"]);
    [_log clear];
    
    // nsdata is json
    NSDictionary *dict = @{
        @"key": @"value"
    };
    
    data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    [_log putContent:data];
    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
    XCTAssertTrue([_log.getContent[@"key"] isEqualToString:@"value"], @"value is not equal to %@", _log.getContent[@"key"]);
    [_log clear];
    
    // nsdata is json array
    NSArray *array = @[
        @"array"
    ];
    data = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
    [_log putContent:data];
    XCTAssertEqual(_log.getContent.count, 1, "dict count not 1.");
    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]], @"value is not equal to %@", _log.getContent[@"data"]);
    [_log clear];
}


- (void) test_log$putContent$dictValue {
    [_log clear];
    NSDictionary *dict = @{
        @"key1": @"value1",
        @"key2": @1,
        @"key3": @1.0f,
        @"key4": @1L,
        @"key5": @{
            @"1key": @"1value",
            @"2key": @[]
        },
        @"key6": @[@"array"]
    };
    [_log putContent:nil dictValue:dict];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    
    [_log putContent:[NSNull null] dictValue:dict];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    
    
    [_log putContent:@"data" dictValue:nil];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    
    [_log putContent:@"data" dictValue:[NSNull null]];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    

    [_log putContent:@"data" dictValue:dict];
    XCTAssertTrue(_log.getContent.count == 1, @"dict count not %d.", 1);
    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc]
                                                             initWithData:[NSJSONSerialization dataWithJSONObject:dict
                                                                                                          options:kNilOptions
                                                                                                            error:nil
                                                                          ]
                                                             encoding:NSUTF8StringEncoding
                                                            ]],
                  @"value not equal to %@", _log.getContent[@"data"]);
    [_log clear];
    
    dict = @{
        @"key1": [NSNull null],
    };
    BOOL ret = [_log putContent:@"data" dictValue:dict];
    XCTAssertTrue(NO == ret, @"NSNull insert sucess");
    [_log clear];
}

- (void) test_log$putContent$arrayValue {
    [_log clear];
    
    NSArray *array = @[
        @"array"
    ];
    [_log putContent:nil arrayValue:array];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    
    [_log putContent:[NSNull null] arrayValue:array];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    
    
    [_log putContent:@"data" arrayValue:nil];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    
    [_log putContent:@"data" arrayValue:[NSNull null]];
    XCTAssertTrue(_log.getContent.count == 0, @"dict count not %d.", 0);
    [_log clear];
    
    [_log putContent:@"data" dictValue:array];
    XCTAssertTrue(_log.getContent.count == 1, @"dict count not %d.", 1);
    XCTAssertTrue([_log.getContent[@"data"] isEqualToString:[[NSString alloc]
                                                             initWithData:[NSJSONSerialization dataWithJSONObject:array
                                                                                                          options:kNilOptions
                                                                                                            error:nil
                                                                          ]
                                                             encoding:NSUTF8StringEncoding
                                                            ]],
                  @"value not equal to %@", _log.getContent[@"data"]);
    [_log clear];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
