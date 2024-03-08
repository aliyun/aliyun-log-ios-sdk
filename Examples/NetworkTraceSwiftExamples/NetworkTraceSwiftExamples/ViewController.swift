//
// Copyright 2023 aliyun-sls Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import UIKit
import AliyunLogOTelCommon
import AliyunLogOtlpExporter
import AliyunLogNetworkDiagnosis
import URLSessionInstrumentation
import OpenTelemetryApi
import OpenTelemetrySdk

class ViewController: UIViewController {
    
    let accessKeyId = ""
    let accessKeySecret = ""
    let secretKey = ""
    var tracer:Tracer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func initSDK(_ sender: Any) {
        let credentials = SLSCredentials()
        credentials.endpoint = "https://cn-beijing.log.aliyuncs.com"
        credentials.project = "mobile-demo-beijing-b"
        
        credentials.accessKeyId = self.accessKeyId
        credentials.accessKeySecret = self.accessKeySecret
        
        let networkDiagnosisCredentials = credentials.createNetworkDiagnosisCredentials()
        networkDiagnosisCredentials.secretKey = self.secretKey
        
        SLSCocoa.sharedInstance().initialize(credentials) { configuration in
            configuration.enableNetworkDiagnosis = true
        }
        
        SLSCocoa.sharedInstance().registerCredentialsCallback { feature, result in
            
        }
        
        initTraceSDK()
    }
    
    func initTraceSDK() {
        ConfigurationManager.shared.setProvider(
            accessKeyProvider: { scope in
                if ("ipa" == scope) {
                    return AccessKey.`init`(
                        accessKeyId: self.accessKeyId,
                        accessKeySecret: self.accessKeySecret
                    )
                } else if ("trace" == scope) {
                    return AccessKey.`init`(
                        accessKeyId: self.accessKeyId,
                        accessKeySecret: self.accessKeySecret
                    )
                }
                
                return nil
            },
            workspaceProvider: {scope in
                //                if ("trace" == scope) {
                //                    return Workspace.`init`(
                //                        endpoint: "htt"
                //                    )
                //                }
                return nil
            }
        )
        
        let exporter = OtlpSLSSpanExporter.builder("trace")
            .setEndpoint("https://cn-beijing.log.aliyuncs.com")
            .setProject("mobile-demo-beijing-b")
            .setLogstore("yuanbo-development-traces")
            .setAccessKey(accessKeyId: self.accessKeyId, accessKeySecret: self.accessKeySecret)
            .build()
        
        let ipaExporter = NetworkDiagnosisHelper.exporter()
        
        let spanExporters = MultiSpanExporter(spanExporters: [exporter, ipaExporter])
        let spanProcessor = BatchSpanProcessor(spanExporter: spanExporters)
        let tracerProviderBuilder = TracerProviderBuilder()
            .add(spanProcessor: spanProcessor)
            .with(resource: Resource(attributes: [
                ResourceAttributes.serviceName.rawValue: AttributeValue.string("ios-trace")
            ]))
        OpenTelemetry.registerTracerProvider(tracerProvider: tracerProviderBuilder.build())
    }
    
    @IBAction func demo(_ sender: Any) {
        if nil == tracer {
            tracer = OpenTelemetry.instance.tracerProvider.get(instrumentationName: "connect", instrumentationVersion: "1.0.0")
        }
        
        if let startSpan = tracer?.spanBuilder(spanName: "开始连接游戏").startSpan() {
            OpenTelemetry.instance.contextProvider.setActiveSpan(startSpan)
            connectProxy()
            startSpan.end()
        }
    }
    
    func connectProxy() {
        if let connectSpan = tracer?.spanBuilder(spanName: "连接网关").startSpan() {
            OpenTelemetry.instance.contextProvider.setActiveSpan(connectSpan)
            let _ = connectProxy(line: "主线路")
            connectSpan.end()
        }
        
    }
    
    func connectProxy(line: String) -> Bool {
        if let proxySpan = tracer?.spanBuilder(spanName: "连接网关")
            .setAttribute(key: "proxy_name", value: line)
            .startSpan() {
            OpenTelemetry.instance.contextProvider.setActiveSpan(proxySpan)
            
            let request = SLSTcpPingRequest()
            request.domain = "www.aliyun.com"
            request.port = 8888
            SLSNetworkDiagnosis.sharedInstance().tcpPing2(request)
            
            proxySpan.end()
        }
        return false
    }
}

