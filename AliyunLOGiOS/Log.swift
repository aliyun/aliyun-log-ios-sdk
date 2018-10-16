//
//  Log.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/29.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation

open class Log : NSObject{
    public var mContent:NSMutableDictionary = [:]
    public override init(){
        mContent[KEY_TIME] = Int(Date().timeIntervalSince1970) as AnyObject?
    }
    
    //    open func PutTime(_ time:Int32)throws{
    //        guard Int(Date().timeIntervalSince1970)<Int(time) else{
    //            throw LogError.illegalValueTime
    //        }
    //        mContent["__time__"] = NSNumber(value: time as Int32)
    //    }
    
    @objc open func PutTime(_ time:Int32){
        //        guard Int(Date().timeIntervalSince1970)<Int(time) else{
        //            throw LogError.illegalValueTime
        //        }
        mContent[KEY_TIME] = NSNumber(value: time as Int32)
    }
    
    //    open func PutContent(_ key:String,value:String)throws{
    //        guard key != "" else{
    //            throw LogError.nullKey
    //        }
    //        guard value != "" else{
    //            throw LogError.nullValue
    //        }
    //        mContent[key] = value as AnyObject?
    //    }
    
    @objc open func PutContent(_ key:String,value:String){
        //        guard key != "" else{
        //            throw LogError.nullKey
        //        }
        //        guard value != "" else{
        //            throw LogError.nullValue
        //        }
        mContent[key] = value as AnyObject?
    }
    
    //    open func GetContent()->[String:AnyObject]{
    //        return mContent
    //    }
    //    open func GetContentConut()->Int{
    //        return content.count
    //    }
}
