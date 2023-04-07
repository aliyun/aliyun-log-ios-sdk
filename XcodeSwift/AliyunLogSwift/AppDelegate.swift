//
//  AppDelegate.swift
//  AliyunLogSwift
//
//  Created by gordon on 2021/12/17.
//

import UIKit
import AliyunLogProducer

@objc class SpanProvider : NSObject, SLSSpanProviderProtocol {
    func provideResource() -> SLSResource {
        return SLSResource.of("res_from_swift_key", value: "swift_valu");
    }
    
    func provideAttribute() -> [SLSAttribute] {
        return [SLSAttribute.of("attr_from _swift_key", value: "swift_value")];
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let utils = DemoUtils.shared
        
        let dict = ProcessInfo.processInfo.environment
        if (dict["PCONFIG_ENABLE"] != nil) {
            utils.endpoint = dict["PEND_POINT"] ?? ""
            utils.project = dict["PLOG_PROJECT"] ?? ""
            utils.logstore = dict["PLOG_STORE"] ?? ""
            utils.pluginAppId = dict["PPLUGIN_APPID"] ?? ""
            utils.accessKeyId = dict["PACCESS_KEYID"] ?? ""
            utils.accessKeySecret = dict["PACCESS_KEY_SECRET"] ?? ""
            utils.secKey = dict["PNETWORK_SECKEY"] ?? ""
        }
        
//        SLSLogV("endpoint: %@", utils.endpoint)
//        SLSLogV("project: %@", utils.project)
//        SLSLogV("logstore: %@", utils.logstore)
//        SLSLogV("pluginAppId: %@", utils.pluginAppId)
//        SLSLogV("accessKeyId: %@", utils.accessKeyId)
//        SLSLogV("accessKeySecret: %@", utils.accessKeySecret)
        
        let credentials = SLSCredentials()
        credentials.endpoint = "https://cn-hangzhou.log.aliyuncs.com"
        credentials.project = "yuanbo-test-1"
        credentials.accessKeyId = utils.accessKeyId
        credentials.accessKeySecret = utils.accessKeySecret
        credentials.instanceId = "ios-dev-ea64"
        
        let networkDiagnosisCredentials = credentials.createNetworkDiagnosisCredentials()
        networkDiagnosisCredentials.secretKey = utils.secKey;
        networkDiagnosisCredentials.siteId = "cn";
        networkDiagnosisCredentials.putExtension("value", forKey: "key")
        networkDiagnosisCredentials.endpoint = "https://cn-hangzhou.log.aliyuncs.com"
        networkDiagnosisCredentials.project = "zaiyun-test5"
        
        let tracerCredentials = credentials.createTraceCredentials()
        tracerCredentials.instanceId = "sls-mall"
        tracerCredentials.endpoint = "https://cn-beijing.log.aliyuncs.com"
        tracerCredentials.project = "qs-demos"
        
        SLSCocoa.sharedInstance().initialize(credentials) { configuration in
            configuration.spanProvider = SpanProvider()
            configuration.enableTrace = true
            configuration.enableNetworkDiagnosis = true
//            configuration.enableInstrumentNSURLSession = true
//            configuration.spanProvider = SpanProvider()
        }
        
//        URLSessionInstrumentation(configuration: URLSessionInstrumentationConfiguration(shouldInstrument: { req in
//            if (req.url?.host?.contains("log.aliyuncs.com") ?? false) == true {
//                return false
//            }
//            return true
//        }))
        
        SLSCocoa.sharedInstance().registerCredentialsCallback { feature, result in
            NSLog("feature: %@, result: %@", feature, result)
            
            if (result == "LogProducerParametersInvalid" || result == "LogProducerSendUnauthorized") {
                // 请求新的token，然后把新的token更新到sdk
                let credentials = SLSCredentials()
                credentials.accessKeyId = utils.accessKeyId
                credentials.accessKeySecret = utils.accessKeySecret
//                credentials.securityToken = utils.
                
                // 不要忘记更新到sdk
                SLSCocoa.sharedInstance().setCredentials(credentials)
            }
        }
        
        let diagnosis = SLSNetworkDiagnosis.sharedInstance()
//        let dnsRequest = SLSDnsRequest()
//        dnsRequest.domain = "www.aliyun.com"
//        dnsRequest.context = "dns-test"
//        diagnosis.dns2(dnsRequest) { response in
//            NSLog("dns result: %@", response.content)
//        }

//        let httpRequest = SLSHttpRequest()
//        httpRequest.domain = "https://www.aliyun.com"
//        httpRequest.context = "http-test"
//        diagnosis.http2(httpRequest) { response in
//            NSLog("http result: %@", response.content)
//        }

//        let pingRequest = SLSPingRequest()
//        pingRequest.domain = "www.aliyun.com"
//        pingRequest.context = "ping-test"
//        diagnosis.ping2(pingRequest) { response in
//            NSLog("ping result: %@", response.content)
//        }

//        let tcppingRequest = SLSTcpPingRequest()
//        tcppingRequest.domain = "www.aliyun.com"
//        tcppingRequest.port = 80
//        tcppingRequest.context = "tcpping-test"
//        diagnosis.tcpPing2(tcppingRequest) { response in
//            NSLog("tcpping result: %@", response.content)
//        }

        let mtrRequest = SLSMtrRequest()
        mtrRequest.domain = "www.aliyun.com"
        mtrRequest.context = "mtr-test"
        diagnosis.mtr2(mtrRequest) { response in
            NSLog("mtr result: %@", response.content)
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

