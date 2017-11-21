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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WriteTest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func WriteTest(){
        
        //可以调试打印输出，分不同的级别
        SLSLog.setLogLevel(level: SLSLog.LogLevel.none)
        
        
        let ENDPOINT = "cn-qingdao.log.aliyuncs.com"
        let PROJECTNAME = "zhuoqinsls001"
        let LOGSTORENAME = "zhuoqinsls001-logstore001"
        

        
//        移动端是不安全环境，不建议直接使用阿里云主账号ak，sk的方式。建议使用STS方式。具体参见 https://help.aliyun.com/document_detail/60899.html
//        注意：只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。
//        通过主账号AK，SK使用日志服务
//        let ALIYUN_AK = "******"
//        let ALIYUN_SK = "******"
//        let myClient = try! LOGClient(endPoint: ENDPOINT,
//                                      accessKeyID: ALIYUN_AK,
//                                      accessKeySecret: ALIYUN_SK,
//                                      projectName:PROJECTNAME)
        
//        通过STS使用日志服务
        let STS_AK = "******"
        let STS_SK = "******"
        let STS_TOKEM = "******"
        
    
        let myClient = try! LOGClient(endPoint: ENDPOINT,
                                      accessKeyID: STS_AK,
                                      accessKeySecret: STS_SK,
                                      token:STS_TOKEM,
                                      projectName:PROJECTNAME)

        /* 创建logGroup */
        let logGroup = LogGroup(topic: "mTopic",source: "mSource")
        
        /* 存入一条log */
        let log1 = Log()
        try! log1.PutContent("K11", value: "V11")
        try! log1.PutContent("K12", value: "V12")
        try! log1.PutContent("K13", value: "V13")
        logGroup.PutLog(log1)
        
        /* 存入一条log */
        let log2 = Log()
        try! log2.PutContent("K21", value: "V21")
        try! log2.PutContent("K22", value: "V22")
        try! log2.PutContent("K23", value: "V23")
        logGroup.PutLog(log2)
        
        /* Post log */
        myClient.PostLog(logGroup,logStoreName: LOGSTORENAME){ response, error in
            //当前回调是在异步线程中，在主线程中同步UI
            if let err = error {
                // handle response however you want
                debugPrint(" err : \(err) \n")
//                DispatchQueue.main.async {
//                    ...
//                }
            }else{
                debugPrint(" response : ",(String(describing: response)) )
//                DispatchQueue.main.async {
//                    ...
//                }
            }
        }

    }
}

