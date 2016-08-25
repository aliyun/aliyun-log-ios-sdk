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
    private var mContent = [[String:AnyObject]]()
    
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
        mContent.append(log.GetContent())
    }
    
    public func GetJsonPackage() -> String{
        do {
            var package:[String:AnyObject] = [:]
            package["__topic__"] = mTopic
            package["__source__"] = mSource
            package["__logs__"] = mContent
            let JsonPackage = String(data:try JSONSerialization.data(withJSONObject: package, options:JSONSerialization.WritingOptions.prettyPrinted), encoding: String.Encoding.utf8)!
            return JsonPackage
            
        }catch _ as NSError {
            fatalError("Fail to serialize data.")
        }
        return ""
    }
    
}
