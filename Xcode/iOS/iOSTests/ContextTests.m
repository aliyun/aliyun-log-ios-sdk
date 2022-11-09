//
//  ContextTests.m
//  iOSTests
//
//  Created by gordon on 2022/11/9.
//

#import <XCTest/XCTest.h>
#import <AliyunLogProducer/AliyunLogProducer-Swift.h>

@interface ContextTests : XCTestCase
@property(nonatomic, strong) ActivityContextManager *contextManager;
@end

@implementation ContextTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _contextManager = [[ActivityContextManager alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSimple {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSString *parent = @"parent";
    [_contextManager setCurrentContextValueForKey:@"context" value:parent];
    XCTAssertEqual(parent, [_contextManager getCurrentContextValueForKey:@"context"]);
    
    NSString *child1 = @"child1";
    [_contextManager setCurrentContextValueForKey:@"context" value:child1];
    XCTAssertEqual(child1, [_contextManager getCurrentContextValueForKey:@"context"]);
    [_contextManager removeContextValueForKey:@"context" value:child1];
    
    XCTAssertEqual(parent, [_contextManager getCurrentContextValueForKey:@"context"]);
    [_contextManager removeContextValueForKey:@"context" value:parent];
    
    XCTAssertNil([_contextManager getCurrentContextValueForKey:@"context"]);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
