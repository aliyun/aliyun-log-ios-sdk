//
//  LOGLogGroup.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/30.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
open class LogGroup:NSObject{
    fileprivate var mTopic:String = ""
    fileprivate var mSource:String = ""
    fileprivate var mLog = [Log]()
    public init(topic:String,source:String){
        mTopic = topic
        mSource = source
    }
    open func PutTopic(_ topic:String){
        mTopic = topic
    }
    open func PutSource(_ source:String){
        mSource = source
    }
    open func PutLog(_ log:Log){
        mLog.append(log)
    }
    
    open func GetProtoBufPackage()->[UInt8]{
        var LogGroup = [UInt8]()
        for log in mLog{
            LogGroup += EncodingLog(log)
        }
        LogGroup += EncodingString(3,value: mTopic);
        LogGroup += EncodingString(4,value: mSource);
        return LogGroup
    }
    
    open func EncodingLog(_ log:Log)->[UInt8]{
        var value = EncodingNumber(1,value:log.GetTime())
        for cont in log.GetContent(){
            let content =  EncodingContent(cont)
            value += EncodingMessage(2, value: content)
        }
        return EncodingMessage(1, value: value)
    }
    
    open func EncodingContent(_ cont:(String,AnyObject))->[UInt8]{

        return EncodingString(1,value: cont.0) +
            EncodingString(2,value: cont.1 as! String)
    }

    open func EncodingMessage(_ field_number:Int,value:[UInt8])->[UInt8]{
        var key = [UInt8]()
        key.append(UInt8((field_number << 3) | 2))
        let length = VarInt(UInt32(value.count))
        return key + length + value
    }
    
    open func EncodingNumber(_ field_number:Int,value:UInt32)->[UInt8]{
        var key = [UInt8]()
        key.append(UInt8((field_number << 3) | 0))
        let valueArray = VarInt(value)
        return key + valueArray
    }
    open func EncodingString(_ field_number:Int,value:String)->[UInt8]{
        var key = [UInt8]()
        key.append(UInt8((field_number << 3) | 2))
        let valueArray: [UInt8] = Array(value.utf8)
        let length = VarInt(UInt32(valueArray.count))
        return key + length + valueArray
    }
    
    open func VarInt(_ value:UInt32)->[UInt8]{
        var value = value
        var data = [UInt8]()
        repeat{
            data.append((UInt8)((value & 0x7F) | 0x80))
            value >>= 7
        } while (value != 0);
        data.append(data.removeLast()&(0x7F));
        return data
    }
}
