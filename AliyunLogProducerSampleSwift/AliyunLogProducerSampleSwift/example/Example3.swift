//
//  Example3.swift
//  AliyunLogProducerSampleSwift
//
//  Created by lichao on 2020/10/28.
//  Copyright © 2020 lichao. All rights reserved.
//

import UIKit
import AliyunLogProducer
/**
    设置回调
 */
class ViewController: UIViewController {

    fileprivate var client:     LogProducerClient!

    fileprivate let endpoint = "https://cn-hangzhou.log.aliyuncs.com"
    fileprivate let project = "k8s-log-c783b4a12f29b44efa31f655a586bb243"
    fileprivate let logstore = "666"
    fileprivate let accesskeyid = ""
    fileprivate let accesskeysecret = ""
    
    var x : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let file = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let path = file! + "/log.dat"
        
        let config = LogProducerConfig(endpoint:endpoint, project:project, logstore:logstore, accessKeyID:accesskeyid, accessKeySecret:accesskeysecret)!
        
        let callbackFunc: on_log_producer_send_done_function = {config_name,result,log_bytes,compressed_bytes,req_id,error_message,raw_buffer,user_param in
            let res = LogProducerResult(rawValue: Int(result))
            print(res!)
            let reqId = req_id == nil ? "":String(cString: req_id!)
            print(reqId)
            let errorMessage = error_message == nil ? "" : String(cString: error_message!)
            print(errorMessage)
            print(log_bytes)
            print(compressed_bytes)
        }
        client = LogProducerClient(logProducerConfig:config, callback:callbackFunc)
    }

    @IBAction func test(_ sender: UIButton) {
        sendOneLog()
    }
    
    func sendOneLog() {
        sendOneLog1()
        let log = getOneLog()
        log.putContent("index", value:String(x))
        x = x + 1
        let res = client?.add(log, flush:1)
        print(res!)
    }
    
    func getOneLog() -> Log {
        let log = Log()
        log.putContent("content_key_1", value:"1abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_2", value:"2abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_3", value:"3abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_4", value:"4abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_5", value:"5abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_6", value:"6abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_7", value:"7abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_8", value:"8abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("content_key_9", value:"9abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+")
        log.putContent("random", value:String(arc4random()))
        log.putContent("content", value:"中文")
        return log
    }
}

