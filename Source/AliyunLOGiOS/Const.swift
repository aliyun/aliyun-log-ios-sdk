//
//  Const.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/8/18.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation

let KEY_HOST = "Host"
let KEY_TIME = "__time__"
let KEY_TOPIC = "__topic__"
let KEY_SOURCE = "__source__"
let KEY_LOGS = "__logs__"

let KEY_DATE = "Date"

let KEY_CONTENT_LENGTH = "Content-Length"
let KEY_CONTENT_MD5 = "Content-MD5"
let KEY_CONTENT_TYPE = "Content-Type"

let KEY_LOG_APIVERSION = "x-log-apiversion"
let KEY_LOG_BODYRAWSIZE = "x-log-bodyrawsize"
let KEY_LOG_COMPRESSTYPE = "x-log-compresstype"
let KEY_LOG_SIGNATUREMETHOD = "x-log-signaturemethod"

let KEY_ACS_SECURITY_TOKEN = "x-acs-security-token"
let KEY_AUTHORIZATION = "Authorization"

let POST_VALUE_LOG_APIVERSION = "0.6.0"
let POST_VALUE_LOG_COMPRESSTYPE = "deflate"
let POST_VALUE_LOG_CONTENTTYPE = "application/json"
let POST_VALUE_LOG_SIGNATUREMETHOD = "hmac-sha1"


let POST_METHOD_NAME = "POST"

let TOKEN_EXPIRE_TIME = 60 * 15 //15min

let sls_documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first

enum SLS_TABLE_COLUMN_NAME: String {
    case id = "id"
    case endpoint = "endpoint"
    case project = "project"
    case logstore = "logstore"
    case log = "log"
    case timestamp = "timestamp"
}
