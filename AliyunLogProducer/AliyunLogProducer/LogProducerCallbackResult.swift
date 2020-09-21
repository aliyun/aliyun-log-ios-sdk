//
//  LogProducerCallbackResult.swift
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/4.
//  Copyright © 2020 lichao. All rights reserved.
//

import Foundation

open class LogProducerCallbackResult : NSObject{
    public var logProducerResult:LogProducerResult
    public var reqId:String
    public var errorMessage:String
    public var logBytes:Int
    public var compressedBytes:Int
    
    public init(_ logProducerResult:LogProducerResult, _ reqId:String, _ errorMessage:String, _ logBytes:Int, _ compressedBytes:Int){
        self.logProducerResult = logProducerResult
        self.reqId = reqId
        self.errorMessage = errorMessage
        self.logBytes = logBytes
        self.compressedBytes = compressedBytes
    }
}
