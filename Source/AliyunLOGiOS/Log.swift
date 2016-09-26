//
//  Log.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/29.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
open class Log:NSObject{
    fileprivate var mContent:[String:AnyObject] = [:]
    fileprivate var mTime:UInt32
    public override init(){
        mTime = UInt32(Date().timeIntervalSince1970)
    }
    open func PutTime(_ time:UInt32)throws{
        guard Int(Date().timeIntervalSince1970)<Int(time) else{
            throw LogError.illegalValueTime
        }
        mTime = time
    }
    open func PutContent(_ key:String,value:String)throws{
        guard key != "" else{
            throw LogError.nullKey
        }
        guard value != "" else{
            throw LogError.nullValue
        }
        mContent[key] = value as AnyObject?
    }
    open func GetTime()->UInt32{
        return mTime
    }
    open func GetContent()->[String:AnyObject]{
        return mContent
    }
    open func GetContentConut()->Int{
        return mContent.count
    }
}
