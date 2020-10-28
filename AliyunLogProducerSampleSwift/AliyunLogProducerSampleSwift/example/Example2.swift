//
//  Example2.swift
//  AliyunLogProducerSampleSwift
//
//  Created by lichao on 2020/10/28.
//  Copyright © 2020 lichao. All rights reserved.
//

import UIKit
import AliyunLogProducer
/**
    开启离线缓存
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

        client = LogProducerClient(logProducerConfig:config)
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


