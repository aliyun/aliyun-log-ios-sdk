//
//  LogError.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/8/16.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//  Edited by zhuoqin 17/11/20

import Foundation

public enum LogError: Error{
    case nullEndPoint
    case nullAKID
    case nullAKSecret
    case nullToken
    case illegalValueTime
    case nullKey
    case nullValue
    case null
    case nullProjectName
    case nullLogStoreName
    case wrongURL
    //添加服务器返回的错误信息，对外暴露requestID
    case ServiceError(errorCode:String, errorMessage:String, requesetID:String)
}
