//
//  LogError.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/8/16.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
public enum LogError: ErrorType{
    case NullEndPoint
    case NullAKID
    case NullAKSecret
    case NullToken
    case IllegalValueTime
    case NullKey
    case NullValue
    case Null
    case NullProjectName
    case NullLogStoreName
    case WrongURL
}