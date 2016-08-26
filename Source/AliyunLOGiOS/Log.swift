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
    private var mTime:UInt32
    public override init(){
        mTime = UInt32(Date().timeIntervalSince1970)
    }
    public func PutTime(_ time:UInt32)throws{
        guard Int(Date().timeIntervalSince1970)<Int(time) else{
            throw LogError.illegalValueTime
        }
        mTime = time
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
    public func GetTime()->UInt32{
        return mTime
    }
    public func GetContent()->[String:AnyObject]{
        return mContent
    }
    public func GetContentConut()->Int{
        return mContent.count
    }
}
