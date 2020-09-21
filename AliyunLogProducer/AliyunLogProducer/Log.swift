//
//  Log.swift
//  AliyunLogProducer
//
//  Created by lichao on 2020/8/25.
//  Copyright © 2020 lichao. All rights reserved.
//

import Foundation

open class Log : NSObject{
    public var content:[String:String] = [:]
    
    @objc
    public override init(){
    }
    
    /**
     add content to log.
    
     - parameter key: String
     - parameter value: String
    */
    @objc
    open func PutContent(_ key:String, value:String){
        content[key] = value
    }
}
