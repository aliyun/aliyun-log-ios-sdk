//
//  CacheManager.swift
//  AliyunLOGiOS
//
//  Created by huaixu on 2018/6/7.
//  Copyright © 2018年 wangjwchn. All rights reserved.
//

import Foundation



/// 本地缓存日志的管理器。在实例化时会开启定时器,网络状态监控器。每隔30秒会判断是否达到发送的网络条件,如果是的话,则从缓存中读取30条记录,然后批量上传。同时还会判断本地数据库文件是否达到大小上限(默认是30M,大于30M时从数据库中删除最先加入到数据库中的2000条记录) 此时处于上传中状态。当所有在group中的请求都结束时,才重置为可用状态。
open class CacheCheckManager: NSObject {
    fileprivate var gcdTimer: DispatchSourceTimer?     // gcd定时器
    fileprivate var manager: NetworkReachabilityManager?    // 网络连接监听管理器
    fileprivate var pending: Bool = false   // 是否正在发送缓存中的数据
    fileprivate var group: DispatchGroup?   // 用于管理批量发送的group
    fileprivate weak var mClient: LOGClient?   // 用于发送缓存中日志的client
    fileprivate var mTimeInterval: Int
    fileprivate var mFetchCount: Int
    
    
    public init(timeInterval: Int = 30, client: LOGClient, fetchCount: Int = 30) {
        manager = NetworkReachabilityManager(host: "www.aliyun.com")
        group = DispatchGroup.init()
        mTimeInterval = timeInterval
        mClient = client
        mFetchCount = fetchCount
    }
    
    open func startCacheCheck() {
        manager?.startListening()
        startMonitor()
    }
    
    open func stopMonitor(){
        gcdTimer?.cancel()
        gcdTimer = nil
    }
    
    deinit {
        stopMonitor()
    }
    
    open func startMonitor() {
        let queue = DispatchQueue(label: "com.aliyun.sls.gcdTimer", attributes: .concurrent)
        
        gcdTimer?.cancel()        // cancel previous timer if any
        
        gcdTimer = DispatchSource.makeTimerSource(queue: queue)
        
        gcdTimer?.schedule(deadline: .now(), repeating: .seconds(mTimeInterval))
        
        gcdTimer?.setEventHandler { [weak self] in // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
            self?.postLogsFromDB()
        }
        
        gcdTimer?.resume()
    }
    
    private func postLogsFromDB() {
        guard (manager?.isReachable)! else {
            return
        }
        
        let shouldPostViaWiFi = (mClient?.mConfig.connectType == .wifi && (manager?.isReachableOnEthernetOrWiFi)!)
        let shouldPost = (mClient?.mConfig.connectType == .wifiOrwwan && (manager?.isReachable)!)
        
        if shouldPostViaWiFi || shouldPost {
            DispatchQueue.global().async {
                let logs = DBManager.defaultManager().fetchRecords(limit: 30)
                guard logs.count > 0 && !self.pending  else {
                    return
                }
                
                for log in logs {
                    if let record = log as? NSDictionary {
                        let id = record.value(forKey: SLS_TABLE_COLUMN_NAME.id.rawValue) as! UInt64
                        let endpoint = record.value(forKey: SLS_TABLE_COLUMN_NAME.endpoint.rawValue) as! String
                        let project = record.value(forKey: SLS_TABLE_COLUMN_NAME.project.rawValue) as! String
                        let logstore = record.value(forKey: SLS_TABLE_COLUMN_NAME.logstore.rawValue) as! String
                        let msg = record.value(forKey: SLS_TABLE_COLUMN_NAME.log.rawValue) as! String
                        
                        if (self.mClient?.mEndPoint == endpoint && self.mClient?.mProject == project) {
                            self.group?.enter()
                            self.pending = true;
                            self.mClient?.PostLogInCache(logstore: logstore, logMsg: msg, call: {[weak self] (result, error) in
                                self?.group?.leave()
                                if error != nil {
                                    print("缓存日志发送失败,error:\(String(describing: error))")
                                } else {
                                    print("缓存日志发送成功)")
                                    DBManager.defaultManager().deleteRecord(record: ["id": id])
                                }
                            })
                        }
                    }
                }
            }
            
            group?.notify(queue: DispatchQueue.global(), execute: { [weak self] in
                self?.pending = false
            });
            
            DBManager.defaultManager().checkDBSize()
        }
    }
}
