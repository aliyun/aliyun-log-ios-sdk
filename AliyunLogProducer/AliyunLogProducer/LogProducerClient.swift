//
//  LogProducerClient.swift
//  AliyunLogProducer
//
//  Created by lichao on 2020/8/25.
//  Copyright © 2020 lichao. All rights reserved.
//

import Foundation

public var LogProducerCallbackQueue = Queue<LogProducerCallbackResult>(100)

open class LogProducerClient: NSObject {
    
    fileprivate var producer: OpaquePointer!
    fileprivate var client: UnsafeMutablePointer<log_producer_client>!

    @objc
    public init(logProducerConfig:LogProducerConfig){
        if logProducerConfig.IsGlobalCallbackEnable {
            let callback: on_log_producer_send_done_function = {config_name,result,log_bytes,compressed_bytes,req_id,error_message,raw_buffer,user_param in
                let logProducerResult = LogProducerResult(result)
                let reqId = req_id == nil ? "":String(cString: req_id!)
                let errorMessage = error_message == nil ? "" : String(cString: error_message!)
                let logProducerCallbackResult = LogProducerCallbackResult(logProducerResult, reqId, errorMessage, log_bytes, compressed_bytes)
                LogProducerCallbackQueue.enqueue(logProducerCallbackResult)
            }
            producer = create_log_producer(logProducerConfig.logProducerConfig, callback, nil)
        } else {
            producer = create_log_producer(logProducerConfig.logProducerConfig, nil, nil)
        }
        client = get_log_producer_client(producer, nil);
    }
    
    @objc
    public init(logProducerConfig:LogProducerConfig, callback:@escaping on_log_producer_send_done_function){
        producer = create_log_producer(logProducerConfig.logProducerConfig, callback, nil)
        client = get_log_producer_client(producer, nil);
    }
    
    /**
     add log to producer.

     - parameter log: Log
    */
    @objc
    open func AddLog(_ log: Log) -> LogProducerResult? {
        return AddLog(log, flush:0)
    }
    
    /**
     add log to producer.
    
     - parameter log Log
     - parameter flush: Int32 if this log info need to send right, 1 mean flush and 0 means NO
    */
    @objc
    open func AddLog(_ log: Log, flush: Int32) -> LogProducerResult? {
        if client == nil {
            return LogProducerResult(LogProducerEnum.LOG_PRODUCER_INVALID.rawValue)
        }
        let logContents = log.content
        let pairCount = logContents.count
        
        var keyArray = [String]()
        var valueArray = [String]()
        
        var keyCountArray = [Int]()
        var valueCountArray = [Int]()
        
        for logContent in logContents {
            let keyCount = logContent.key.lengthOfBytes(using: String.Encoding.utf8);
            let valueCount = logContent.value.lengthOfBytes(using: String.Encoding.utf8);
            
            keyCountArray.append(keyCount)
            valueCountArray.append(valueCount)
            
            keyArray.append(logContent.key)
            valueArray.append(logContent.value)
        }
        var keyPointerArrayPointer = keyArray.map { strdup($0) }
        var valuePointerArrayPointer = valueArray.map { strdup($0) }
        
        let res = log_producer_client_add_log_with_len(client, Int32(pairCount), &keyPointerArrayPointer, &keyCountArray, &valuePointerArrayPointer, &valueCountArray, flush)
        
        keyPointerArrayPointer.forEach() { free($0) }
        valuePointerArrayPointer.forEach() { free($0) }
        
        return LogProducerResult(res)
    }
    
    @objc
    open func DestroyLogProducer() {
        destroy_log_producer(producer);
    }
    
    deinit {
        self.DestroyLogProducer()
    }
}
