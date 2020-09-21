//
//  LogProducerResult.swift
//  AliyunLogProducer
//
//  Created by lichao on 2020/8/31.
//  Copyright © 2020 lichao. All rights reserved.
//

import Foundation

enum LogProducerEnum: Int32 {
    case LOG_PRODUCER_OK = 0, LOG_PRODUCER_INVALID, LOG_PRODUCER_WRITE_ERROR, LOG_PRODUCER_DROP_ERROR, LOG_PRODUCER_SEND_NETWORK_ERROR, LOG_PRODUCER_SEND_QUOTA_ERROR, LOG_PRODUCER_SEND_UNAUTHORIZED, LOG_PRODUCER_SEND_SERVER_ERROR, LOG_PRODUCER_SEND_DISCARD_ERROR, LOG_PRODUCER_SEND_TIME_ERROR, LOG_PRODUCER_SEND_EXIT_BUFFERED, LOG_PRODUCER_PERSISTENT_ERROR = 99;
}

@objc
public class LogProducerResult: NSObject {
    fileprivate var logProducerEnum : LogProducerEnum?;
    
    public init(_ result:Int32){
        logProducerEnum = LogProducerEnum(rawValue: result)
    }
    
    @objc
    public func IsLogProducerResultOk() -> Bool {
        return logProducerEnum?.rawValue == 0
    }
    
    public override var description: String {
        return String(describing: logProducerEnum!);
    }

}
