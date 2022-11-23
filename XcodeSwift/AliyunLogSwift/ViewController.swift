//
//  ViewController.swift
//  AliyunLogSwift
//
//  Created by gordon on 2021/12/17.
//

import UIKit
import AliyunLogProducer
import Combine

class ViewController: UIViewController {
    fileprivate var client:     LogProducerClient!
    var cancellables = Set<AnyCancellable>()
    var index: Int = 0
    
    var x : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let utils = DemoUtils.shared
        let file = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let path = file! + "/log.dat"
        
        let config = LogProducerConfig(endpoint:utils.endpoint, project:utils.project, logstore:utils.logstore, accessKeyID:utils.accessKeyId, accessKeySecret:utils.accessKeySecret)!
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
        
        //网络连接超时时间，整数，单位秒，默认为10
        config.setConnectTimeoutSec(10)
        //日志发送超时时间，整数，单位秒，默认为15
        config.setSendTimeoutSec(10)
        //flusher线程销毁最大等待时间，整数，单位秒，默认为1
        config.setDestroyFlusherWaitSec(2)
        //sender线程池销毁最大等待时间，整数，单位秒，默认为1
        config.setDestroySenderWaitSec(2)
        //数据上传时的压缩类型，默认为LZ4压缩， 0 不压缩，1 LZ4压缩， 默认为1
        config.setCompressType(1)
        //设备时间与标准时间之差，值为标准时间-设备时间，一般此种情况用户客户端设备时间不同步的场景
        //整数，单位秒，默认为0；比如当前设备时间为1607064208, 标准时间为1607064308，则值设置为 1607064308 - 1607064208 = 100
        config.setNtpTimeOffset(1)
        //日志时间与本机时间之差，超过该大小后会根据 `drop_delay_log` 选项进行处理。
        //一般此种情况只会在设置persistent的情况下出现，即设备下线后，超过几天/数月启动，发送退出前未发出的日志
        //整数，单位秒，默认为7*24*3600，即7天
        config.setMaxLogDelayTime(7*24*3600)
        //对于超过 `max_log_delay_time` 日志的处理策略
        //0 不丢弃，把日志时间修改为当前时间; 1 丢弃，默认为 1 （丢弃）
        config.setDropDelayLog(1)
        //是否丢弃鉴权失败的日志，0 不丢弃，1丢弃
        //整数，默认为 0，即不丢弃
        config.setDropUnauthorizedLog(0)
        //注册 获取服务器时间 的函数
        config.setGetTimeUnixFunc({ () -> UInt32 in
            let time = Date().timeIntervalSince1970
            return UInt32(time);
        })
        
        let callbackFunc: on_log_producer_send_done_function = {config_name,result,log_bytes,compressed_bytes,req_id,error_message,raw_buffer,user_param in
            let res = LogProducerResult(rawValue: Int(result))
//            print(res!)
//            let reqId = req_id == nil ? "":String(cString: req_id!)
//            print(reqId)
//            let errorMessage = error_message == nil ? "" : String(cString: error_message!)
//            print(errorMessage)
//            print(log_bytes)
//            print(compressed_bytes)
        }
        client = LogProducerClient(logProducerConfig:config, callback:callbackFunc)
//        client = LogProducerClient(logProducerConfig:config)
//        DispatchQueue.global().async {
//            Thread.sleep(forTimeInterval: 3.0)
//            SLSTracer.spanBuilder("for test in async, should independent").build().end()
//        }
    }
    
    func sendOneLog() {
        let log = getOneLog()
//        log.putContent("index", value:String(x))
        x = x + 1
        let res = client?.add(log, flush:1)
        print(res!)
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
        let logTime = Date().timeIntervalSince1970
        log.setTime(useconds_t(logTime))
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

    @IBAction func sendLog(_ sender: Any) {
        sendOneLog()
    }
    
    
    @IBAction func mockCrash(_ sender: Any) {
        let numbers = [0]
        let _ = numbers[1]
    }
    
    @IBAction func simpleTrace(_ sender: Any) {
        // single span with SpanBuilder
        SLSTracer.spanBuilder("span builder")
            .setService("iOS")
            .addAttributes([SLSAttribute.of("attr_key", value: "attr_value")])
            .addResource(SLSResource.of("res_key", value: "res_value"))
            .build()
            .end()
        
        
        // single span
        var span = SLSTracer.startSpan("span 1")
        span.addAttributes([SLSAttribute.of("attr_key", value: "attr_value")])
        span.end()

        // span with children
        span = SLSTracer.startSpan("span with children", active: true)
        SLSTracer.startSpan("child span 1").end()
        SLSTracer.startSpan("child span 2").end()
        span.end()

        // span with function block
        SLSTracer.withinSpan("span with func block") {
            SLSTracer.startSpan("span within block 1").end()
            SLSTracer.withinSpan("nested span with func block") {
                SLSTracer.startSpan("nested span 1").end()
                SLSTracer.startSpan("nested span 2").end()
            }
//            var array = [String]()
//            array.remove(at: 10)
            SLSTracer.startSpan("span within block 2").end()
        }
        
        // http request with traceid
        SLSTracer.withinSpan("span with http request func") {
            URLSession.shared.dataTask(with: URL.init(string: "http://sls-mall.caa227ac081f24f1a8556f33d69b96c99.cn-beijing.alicontainer.com/catalogue")!).resume()
        }
    }
    
    @IBAction func startEngine(_ sender: Any) {
        let root = SLSTracer.spanBuilder("执行启动引擎操作").setActive(true).build()
        self.connectPower("启动引擎")
        loadReportStatus().sink { _ in
            root.end()
        } receiveValue: { ret in
            print("load report status result: \(ret)")
        }
        .store(in: &cancellables)
    }
    
    func connectPower(_ source: String) {
        SLSTracer.withinSpan("\(source) 1. 接通电源") {
//            Thread.sleep(forTimeInterval: 1.0)
        }
        
    
        SLSTracer.withinSpan("\(source) 1.1. 电气系统自检") {
            SLSTracer.withinSpan("\(source) 1.1.1. 电池电压检查") {
//                Thread.sleep(forTimeInterval: 1.0)
//                        Task.sleep(2)
            }
            
            SLSTracer.withinSpan("\(source) 1.1.2. 电气信号检查") {
//                Thread.sleep(forTimeInterval: 1.0)
//                        Task.sleep(2.0)
            }
        }
    }
    
    
    @IBAction func openAirConditioner(_ sender: Any) {
        index += 1;
        let root = SLSTracer.spanBuilder("打开空调-\(index)").setActive(true).build()

        connectPower("打开空调-\(index)")

        loadReportStatus().sink { _ in
            
        } receiveValue: { ret in
            print("load report status result: \(ret)")
        }
        .store(in: &cancellables)
        root.end()

//        SLSTracer.withinSpan("打开空调-\(self.index)") {
//            self.connectPower("打开空调-\(self.index)")
//
//            self.loadReportStatus().sink { _ in
//
//            } receiveValue: { ret in
//                print("load report status result: \(ret)")
//            }
//            .store(in: &self.cancellables)
//        }
    }
    
    
    func loadReportStatus() -> Future<Bool, Error> {
        let a = Future<Bool, Error> { promise in
            self.getReportStatus { result in
                if case let .failure(error) = result {
                    print("Failed to report status, result: \(error.localizedDescription)")
                }
                promise(result)
                
            }
        }
        
//        return a.eraseToAnyPublisher()
        return a
    }
    
    func getReportStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
//        Task.detached {
//            do {
//                let result = try await self.reportStatus()
//                completion(.success(result))
//            } catch {
//                completion(.failure(error))
//            }
//        }
        Task {
            do {
                let result = try await self.reportStatus()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func reportStatus() async throws -> Bool {
        var urlRequest = URLRequest(url: URL.init(string: "http://sls-mall.caa227ac081f24f1a8556f33d69b96c99.cn-beijing.alicontainer.com/catalogue")!)
        urlRequest.httpMethod = "GET"
        
        try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            fatalError("Error while fetching data")
        }
        
        return true
    }
    
    
    @IBAction func eventAndExceptionDemo(_ sender: Any) {
        
        SLSTracer.startSpan("span with event")
            .addEvent("event name")
            .end()
        SLSTracer.startSpan("span with event and attribute")
            .addEvent("event name with attribute", attributes: [
                SLSAttribute.of("attr_key", value: "attr_value"),
                SLSAttribute.of("attr_key2", value: "attr_value2")
            ])
            .end()
        
        SLSTracer.startSpan("span with exception")
            .recordException(NSException(name: NSExceptionName("mock exception name"), reason: "mock exception reason"))
            .end()
        SLSTracer.startSpan("span with exception and attribute")
            .recordException(NSException(name: NSExceptionName("mock exception name"), reason: "mock exception reason"), attributes: [
                SLSAttribute.of("attr_key", value: "attr_value"),
                SLSAttribute.of("attr_key2", value: "attr_value2")
            ])
            .end()
        
    }
    
}

