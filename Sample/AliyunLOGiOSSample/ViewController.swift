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
    fileprivate let endpoint = "http://cn-hangzhou.log.aliyuncs.com";  // 更多关于endpoint的信息请参考https://help.aliyun.com/document_detail/29008.html
    fileprivate let project = "projectname"
    fileprivate let store = "storename"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化client
        setupSLSClient()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setupSLSClient() {
        
//        通过主账号AK，SK使用日志服务。
//        注意：移动端是不安全环境，请勿直接使用阿里云主账号ak，sk的方式。建议使用STS方式。只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。
        let ALIYUN_AK = "aliyun_ak"
        let ALIYUN_SK = "aliyun_sk"
        mClient = LOGClient(endPoint: endpoint,
                            accessKeyID: ALIYUN_AK,
                            accessKeySecret: ALIYUN_SK,
                            projectName: project,
                            token: nil)
        
//                通过STS使用日志服务,具体参见 https://help.aliyun.com/document_detail/62681.html
//                let STS_AK = "******"
//                let STS_SK = "******"
//                let STS_TOKEM = "******"
//
//                mClient = LOGClient(endPoint: endpoint,
//                                    accessKeyID: STS_AK,
//                                    accessKeySecret: STS_SK,
//                                    token: STS_TOKEM,
//                                    projectName: project)
        //打开调试开关
        mClient?.mIsLogEnable = false
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
                print("直接发送失败,error : \(String(describing: error?.localizedDescription)) time : \(Date().timeIntervalSince1970)")
            }else{
                print("直接发送成功 time : \(Date().timeIntervalSince1970)")
            }
        }
    }
    
    /// 发送日志
    @IBAction func sendLogAction(_ sender: Any) {
        //性能测试，1000个请求
        for i in 0..<1000 {
            createLogAndSend()
        }
    }
}

