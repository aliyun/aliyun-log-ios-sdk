//
//  ViewController.swift
//  AliyunLogProducerSampleSwift
//
//  Created by lichao on 2020/10/15.
//

import UIKit
import AliyunLogProducer

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
        // 指定sts token 创建config，过期之前调用ResetSecurityToken重置token
//        let config = LogProducerConfig(endpoint:endpoint, project:project, logstore:logstore, accessKeyID:accesskeyid, accessKeySecret:accesskeysecret, securityToken:securityToken)
        
        // 设置主题
        config.setTopic("test_topic")
        // 设置tag信息，此tag会附加在每条日志上
        config.addTag("test", value:"test_tag")
        // 每个缓存的日志包的大小上限，取值为1~5242880，单位为字节。默认为1024 * 1024
        config.setPacketLogBytes(1024*1024)
        // 每个缓存的日志包中包含日志数量的最大值，取值为1~4096，默认为1024
        config.setPacketLogCount(1024)
        // 被缓存日志的发送超时时间，如果缓存超时，则会被立即发送，单位为毫秒，默认为3000
        config.setPacketTimeout(3000)
        // 单个Producer Client实例可以使用的内存的上限，超出缓存时add_log接口会立即返回失败
        // 默认为64 * 1024 * 1024
        config.setMaxBufferLimit(64*1024*1024)
        // 发送线程数，默认为1
        config.setSendThreadCount(1)
        
        // 1 开启断点续传功能， 0 关闭
        // 每次发送前会把日志保存到本地的binlog文件，只有发送成功才会删除，保证日志上传At Least Once
        config.setPersistent(1)
        // 持久化的文件名，需要保证文件所在的文件夹已创建。
        config.setPersistentFilePath(path)
        // 是否每次AddLog强制刷新，高可靠性场景建议打开
        config.setPersistentForceFlush(1)
        // 持久化文件滚动个数，建议设置成10。
        config.setPersistentMaxFileCount(10)
        // 每个持久化文件的大小，建议设置成1-10M
        config.setPersistentMaxFileSize(1024*1024)
        // 本地最多缓存的日志数，不建议超过1M，通常设置为65536即可
        config.setPersistentMaxLogCount(65536)
        let callbackFunc: on_log_producer_send_done_function = {config_name,result,log_bytes,compressed_bytes,req_id,error_message,raw_buffer,user_param in
            let res = LogProducerResult(rawValue: Int(result))
//            print(res!)
//            let req = String(cString: req_id!)
//            print(req)
//            print(log_bytes)
//            print(compressed_bytes)
        }
        client = LogProducerClient(logProducerConfig:config, callback:callbackFunc)
//        client = LogProducerClient(logProducerConfig:config)
    }

    @IBAction func test(_ sender: UIButton) {
//        sendOneLog()
        sendMulLog(200)
    }
    
    func sendOneLog() {
        sendOneLog1()
        let log = getOneLog()
        log.putContent("index", value:String(x))
        x = x + 1
        let res = client?.add(log, flush:1)
        print(res!)
    }
    
    func sendOneLog1() {
        let config1 = LogProducerConfig(endpoint:endpoint, project:project, logstore:logstore, accessKeyID:accesskeyid, accessKeySecret:accesskeysecret)!;
        config1.setTopic("test_topic1")
        let client1 = LogProducerClient(logProducerConfig:config1)!
        let log = getOneLog()
        log.putContent("index", value:String(x))
        x = x + 1
        _ = client1.add(log, flush:1)
    }
    
    func sendMulLog(_ num :Int) {
        while true {
            let time1 = Date().timeIntervalSince1970
            for _ in 0..<num {
                let log = self.getOneLog()
                let res = self.client?.add(log)
            }
            let time2 = Date().timeIntervalSince1970
            if time2 - time1 < 1 {
                do {
                    usleep(useconds_t((1 - (time2 - time1)) * 1000000))
                }
            }
        }
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
        log.putContent("random_val", value:getRandomVal())
        return log
    }
    
    func getRandomVal() -> String {
        let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var ranStr = ""
        let len = Int(arc4random_uniform(1000))
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}
