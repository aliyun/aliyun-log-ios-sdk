//
//  SwiftTests.swift
//  iOSTests
//
//  Created by gordon on 2022/11/23.
//

import XCTest
import Foundation
import AliyunLogProducer

class ContextSwiftTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
    func testInAsyncTask() async {
//        NSString *parent = @"parent";
//        [_contextManager setCurrentContextValueForKey:@"context" value:parent];
//        XCTAssertEqual(parent, [_contextManager getCurrentContextValueForKey:@"context"]);
//
//        NSString *child1 = @"child1";
//        [_contextManager setCurrentContextValueForKey:@"context" value:child1];
//        XCTAssertEqual(child1, [_contextManager getCurrentContextValueForKey:@"context"]);
//        [_contextManager removeContextValueForKey:@"context" value:child1];
//
//        XCTAssertEqual(parent, [_contextManager getCurrentContextValueForKey:@"context"]);
//        [_contextManager removeContextValueForKey:@"context" value:parent];
//
//        XCTAssertNil([_contextManager getCurrentContextValueForKey:@"context"]);
        
        let rootSpan: NSString = "root"
        
        let contextManager = ActivityContextManager()
        contextManager.setCurrentContextValue(forKey: "context", value: rootSpan)
        XCTAssertEqual(rootSpan, contextManager.getCurrentContextValue(forKey: "context") as! NSString)
        
        Task {
            XCTAssertEqual(rootSpan, contextManager.getCurrentContextValue(forKey: "context") as! NSString)
            
            contextManager.setCurrentContextValue(forKey: "context", value: "child1" as NSString)
            XCTAssertEqual("child1", contextManager.getCurrentContextValue(forKey: "context") as! NSString)
            
            Task {
                XCTAssertTrue("child1" as NSString === contextManager.getCurrentContextValue(forKey: "context") as! NSString)
                
                contextManager.setCurrentContextValue(forKey: "context", value: "child2" as NSString)
                XCTAssertEqual("child2", contextManager.getCurrentContextValue(forKey: "context") as! NSString)
            }
        }

        XCTAssertEqual(rootSpan, contextManager.getCurrentContextValue(forKey: "context") as! NSString)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
