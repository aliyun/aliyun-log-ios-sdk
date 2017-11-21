//
//  SLSLog.swift
//  AliyunLOGiOS
//
//  Created by 王铮 on 2017/11/21.
//  Copyright © 2017年 wangjwchn. All rights reserved.
//

import Foundation

public class SLSLog {
    
    static private var level: LogLevel = .none
    
    public enum LogLevel: Int {
        case error = 0
        case none = 1
        case debug = 3
    }
    
    public class func setLogLevel(level: LogLevel) {
        self.level = level
    }
    
    public class func logDebug(_ items: Any..., separator: String = " ") {
        if self.level.rawValue >= LogLevel.debug.rawValue {
            print("Debug: ", terminator: separator)
            items.forEach({ (item) in
                debugPrint(item, terminator: separator)
            })
            print()
        }
    }
    
    public class func logError(_ items: Any..., separator: String = " ") {
        if self.level.rawValue >= LogLevel.error.rawValue {
            print("Error: ", terminator: separator)
            items.forEach({ (item) in
                debugPrint(item, terminator: separator)
            })
            print()
        }
    }
}
