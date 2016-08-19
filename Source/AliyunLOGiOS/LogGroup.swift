//
//  LOGLogGroup.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/30.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
public class LogGroup:NSObject{
    private var mTopic:String
    private var mSource:String
    private var mContent = [[String:AnyObject]]()
    
    public init(topic:String,source:String){
        mTopic = topic
        mSource = source
    }
    public func PutTopic(topic:String){
        mTopic = topic
    }
    public func PutSource(source:String){
        mSource = source
    }
    public func PutLog(log:Log){
        mContent.append(log.GetContent())
    }
    
    public func GetJsonPackage() -> String{
        do {
            var package:[String:AnyObject] = [:]
            package[KEY_TOPIC] = mTopic
            package[KEY_SOURCE] = mSource
            package[KEY_LOGS] = mContent
            let JsonPackage = String(data:try NSJSONSerialization.dataWithJSONObject(package, options:NSJSONWritingOptions.PrettyPrinted), encoding: NSUTF8StringEncoding)!
            return JsonPackage
            
        }catch _ as NSError {
            fatalError("Fail to serialize data.")
        }
        return String()
    }

}