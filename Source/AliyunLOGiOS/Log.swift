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
        mContent[KEY_TIME] = Int(NSDate().timeIntervalSince1970)
    }
    public func PutTime(time:Int32)throws{
        guard Int(NSDate().timeIntervalSince1970)<Int(time) else{
            throw LogError.IllegalValueTime
        }
        mContent[KEY_TIME] = NSNumber(int: time)
    }
    public func PutContent(key:String,value:String)throws{
        guard !key.isEmpty else{
            throw LogError.NullKey
        }
        guard !value.isEmpty else{
            throw LogError.NullValue
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