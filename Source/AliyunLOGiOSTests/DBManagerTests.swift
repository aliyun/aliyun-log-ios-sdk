//
//  DBManagerTests.swift
//  AliyunLOGiOSTests
//
//  Created by huaixu on 2018/6/8.
//  Copyright © 2018年 wangjwchn. All rights reserved.
//

import XCTest
import AliyunLOGiOS

class DBManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        let manager = DBManager.defaultManager()
        do {
            try FileManager.default.removeItem(atPath: manager.dbPath()!)
        } catch {
            print("fail to remote sqlite,error:\(error.localizedDescription)")
        }
    }
    
    func testDBOperations() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let manager = DBManager.defaultManager()
        let timestamp = Date.timeIntervalBetween1970AndReferenceDate
        manager.insertRecords(endpoint: "endpoint", project: "project", logstore: "logstore", log: "log", timestamp: timestamp)
        
        let fetchResult = manager.fetchRecords()
        XCTAssertTrue(fetchResult.count == 1)
        
        manager.deleteRecord(record: ["id": "1"])
        let fs = manager.fetchRecords()
        XCTAssertTrue(fs.count == 0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
