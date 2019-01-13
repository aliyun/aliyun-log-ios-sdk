//
//  ViewController.swift
//  AliyunLOGiOSSample
//
//  Created by 王佳玮 on 16/8/1.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import UIKit
import AliyunLOGiOS



class ViewController: UIViewController {
    fileprivate var mClient: LOGClient?
    fileprivate let endpoint = "https://cn-hangzhou.log.aliyuncs.com";  // 更多关于endpoint的信息请参考https://help.aliyun.com/document_detail/29008.html
    fileprivate let project = "******"
    fileprivate let store = "******"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化client
        setupSLSClient()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func insertRecordsToDB() {
        let dm = DBManager.defaultManager()
        for _ in 1...10000 {
            dm.insertRecords(endpoint: "cn-hangzhou.log.aliyuncs.com", project: "aliyun-log-huaixu", logstore: "test", log: "{\n  \"__source__\" : \"swift\",\n  \"__logs__\" : [\n    {\n      \"__time__\" : 1528470458,\n      \"swift-key\" : \"swift-value\"\n    }\n  ],\n  \"__topic__\" : \"mTopic\"\n}", timestamp: Date.timeIntervalBetween1970AndReferenceDate)
        }
    }
    
    func setupSLSClient() {
        // 初始化配置信息
        let cf = SLSConfig(connectType: .wifi, cachable: true)
        
//        通过主账号AK，SK使用日志服务。
//        注意：移动端是不安全环境，请勿直接使用阿里云主账号ak，sk的方式。建议使用STS方式。只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。
        let ALIYUN_AK = "******"
        let ALIYUN_SK = "******"
        mClient = LOGClient(endPoint: endpoint,
                            accessKeyID: ALIYUN_AK,
                            accessKeySecret: ALIYUN_SK,
                            projectName: project,
                            token: nil,
                            config: cf)
        
//                通过STS使用日志服务,具体参见 https://help.aliyun.com/document_detail/62681.html
//                let STS_AK = "******"
//                let STS_SK = "******"
//                let STS_TOKEM = "******"
//
//                mClient = LOGClient(endPoint: endpoint,
//                                    accessKeyID: STS_AK,
//                                    accessKeySecret: STS_SK,
//                                    token: STS_TOKEM,
//                                    projectName: project,
//                                    config: cf)
        //打开调试开关
        mClient?.mIsLogEnable = true
    }
    
    func createLogAndSend() {
        struct SomeStructure {
            static var flag = 1
            
        }
        SomeStructure.flag += 1
        /* 创建logGroup */
        let logGroup = LogGroup(topic: "test-topic",source: "test-source")
        
        /* 存入一条log */
        let log1 = Log()
        log1.PutContent("log-content-key-(\(SomeStructure.flag)", value: "log-content-value-(\(SomeStructure.flag)")
        logGroup.PutLog(log1)
        
        /* Post log */
        mClient?.PostLog(logGroup,logStoreName: store){ response, error in
            //当前回调是在异步线程中，在主线程中同步UI
            if error != nil {
                // handle response however you want
                print("直接发送失败,error : \(String(describing: error?.localizedDescription))")
            }else{
                print("直接发送成功")
            }
        }
    }
    
    /// 发送日志
    @IBAction func sendLogAction(_ sender: Any) {
        for _ in 1...100 {
            createLogAndSend()
        }

    }
}

