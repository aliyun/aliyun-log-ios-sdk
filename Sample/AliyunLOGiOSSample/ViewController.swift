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
        
        /**
         通过EndPoint、accessKeyID、accessKeySecret 构建日志服务客户端
         @endPoint: 服务访问入口，参见 https://help.aliyun.com/document_detail/29008.html
         */
        let myClient = try! LOGClient(endPoint: "",
                                      accessKeyID: "",
                                      accessKeySecret: "",
                                      projectName:"")
        while(true)
        {
       
        /* 创建logGroup */
        let logGroup = LogGroup(topic: "mTopic",source: "mSource")
        
            /* 存入一条log */
            let log1 = Log()
                try! log1.PutContent("k11", value: "v11")
                try! log1.PutContent("k12", value: "v12")
                try! log1.PutContent("k13", value: "v13")
         logGroup.PutLog(log1)
            
            /* 存入一条log */
            let log2 = Log()
            try! log2.PutContent("k21", value: "v21")
            try! log2.PutContent("k22", value: "v22")
            try! log2.PutContent("k23", value: "v23")
        logGroup.PutLog(log2)
       
        
        /* Post log */
        myClient.PostLog(logGroup,logStoreName: "")
            
        sleep(1);
        }
    }
}

