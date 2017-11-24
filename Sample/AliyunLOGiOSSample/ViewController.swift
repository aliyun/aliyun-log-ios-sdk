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
        LogTest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func LogTest(){
    
        let ENDPOINT = "cn-qingdao.log.aliyuncs.com"
        let PROJECTNAME = "zhuoqinsls001"
        let LOGSTORENAME = "zhuoqinsls001-logstore001"
        
//        移动端是不安全环境，不建议直接使用阿里云主账号ak，sk的方式。建议使用STS方式。具体参见 https://help.aliyun.com/document_detail/62643.html
//        注意：只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。
//        通过主账号AK，SK使用日志服务
        let ALIYUN_AK = "LTAIdJcQW6Uap6c"
        let ALIYUN_SK = "ssnJED1Ro4inSpE2NF71bGZD6IEbN1"
        
        let myClient = LOGClient(endPoint: ENDPOINT,
                                      accessKeyID: ALIYUN_AK,
                                      accessKeySecret: ALIYUN_SK,
                                      projectName:PROJECTNAME)
        
//        通过STS使用日志服务
//        let STS_AK = "******"
//        let STS_SK = "******"
//        let STS_TOKEM = "******"
//        
//        let myClient = LOGClient(endPoint: ENDPOINT,
//                                      accessKeyID: STS_AK,
//                                      accessKeySecret: STS_SK,
//                                      token:STS_TOKEM,
//                                      projectName:PROJECTNAME)
        //打开调试开关
        myClient.mIsLogEnable = true

        /* 创建logGroup */
        let logGroup = LogGroup(topic: "mTopic",source: "swift")
        
        /* 存入一条log */
        let log1 = Log()
        log1.PutContent("swift-key", value: "swift-value")
        logGroup.PutLog(log1)
        
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

