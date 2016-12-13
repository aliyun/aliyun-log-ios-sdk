//
//  LogError.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/8/16.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

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
}
