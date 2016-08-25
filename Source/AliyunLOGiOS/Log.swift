//
//  Log.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/29.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
public class Log:NSObject{
    private var mContent:[String:AnyObject] = [:]
    public override init(){
        mContent["__time__"] = Int(Date().timeIntervalSince1970)
    }
    public func PutTime(_ time:Int32)throws{
        guard Int(Date().timeIntervalSince1970)<Int(time) else{
            throw LogError.illegalValueTime
        }
        mContent["__time__"] = NSNumber(value: time)
    }
    public func PutContent(_ key:String,value:String)throws{
        guard key != "" else{
            throw LogError.nullKey
        }
        guard value != "" else{
            throw LogError.nullValue
        }
        mContent[key] = value
    }
    public func GetContent()->[String:AnyObject]{
        return mContent
    }
    public func GetContentConut()->Int{
        return mContent.count
    }
}
