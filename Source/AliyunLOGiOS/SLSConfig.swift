//
//  SLSConfig.swift
//  AliyunLOGiOS
//
//  Created by huaixu on 2018/6/5.
//  Copyright © 2018年 wangjwchn. All rights reserved.
//

import Foundation

open class SLSConfig: NSObject {
    @objc
    public enum SLSConnectionType: Int{
        case wifi
        case wifiOrwwan
    }
    /// 是否开启离线缓存日志功能,默认不开启
    fileprivate var mCachable: Bool = false;
    
    
    /// 离线日志的发送时机,默认是只在wifi网络状况下发送
    fileprivate var mConnectType: SLSConnectionType;
    
    open var isCachable: Bool {
        return mCachable
    }
    
    open var connectType: SLSConnectionType {
        return mConnectType
    }
    
    public init(connectType: SLSConnectionType = .wifi, cachable: Bool = false) {
        mCachable = cachable
        mConnectType = connectType
    }
}
