//
//  LOGLogGroup.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/30.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
public class LogGroup:NSObject{
    private var mTopic:String = ""
    private var mSource:String = ""
    private var mLog = [Log]()
    public init(topic:String,source:String){
        mTopic = topic
        mSource = source
    }
    public func PutTopic(_ topic:String){
        mTopic = topic
    }
    public func PutSource(_ source:String){
        mSource = source
    }
    public func PutLog(_ log:Log){
        mLog.append(log)
    }
    
    public func GetProtoBufPackage()->[UInt8]{
        var LogGroup = [UInt8]()
        for log in mLog{
            LogGroup += EncodingLog(log: log)
        }
        LogGroup += EncodingString(field_number: 3,value: mTopic);
        LogGroup += EncodingString(field_number: 4,value: mSource);
        return LogGroup
    }
    
    public func EncodingLog(log:Log)->[UInt8]{
        var value = EncodingNumber(field_number:1,value:log.GetTime())
        for cont in log.GetContent(){
            let content =  EncodingContent(cont:cont)
            value += EncodingMessage(field_number: 2, value: content)
        }
        return EncodingMessage(field_number: 1, value: value)
    }
    
    public func EncodingContent(cont:(String,AnyObject))->[UInt8]{

        return EncodingString(field_number:1,value: cont.0) +
            EncodingString(field_number:2,value: cont.1 as! String)
    }

    public func EncodingMessage(field_number:Int,value:[UInt8])->[UInt8]{
        var key = [UInt8]()
        key.append(UInt8((field_number << 3) | 2))
        let length = VarInt(value: UInt32(value.count))
        return key + length + value
    }
    
    public func EncodingNumber(field_number:Int,value:UInt32)->[UInt8]{
        var key = [UInt8]()
        key.append(UInt8((field_number << 3) | 0))
        let valueArray = VarInt(value: value)
        return key + valueArray
    }
    public func EncodingString(field_number:Int,value:String)->[UInt8]{
        var key = [UInt8]()
        key.append(UInt8((field_number << 3) | 2))
        let valueArray: [UInt8] = Array(value.utf8)
        let length = VarInt(value: UInt32(valueArray.count))
        return key + length + valueArray
    }
    
    public func VarInt(value:UInt32)->[UInt8]{
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
