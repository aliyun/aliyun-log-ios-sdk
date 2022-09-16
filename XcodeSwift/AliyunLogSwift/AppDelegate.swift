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
        networkDiagnosisCredentials.secretKey = "eyJhbGl5dW5fdWlkIjoiMTY1NDIxODk2NTM0MzA1MCIsImlwYV9hcHBfaWQiOiJmTmFGUGNBbWd4RXRlcFVwTUZ6WnZYIiwic2VjX2tleSI6IjJhMWM3NzU5MDBmZjY5YTRkMmQ3ZDE3NDk5MmMwYjU5Y2VhMTU3NTFiOGI1NGU4YjMzYjQxNTVmYzVhOTQ2YTBjMjJiNmE3YTNkZDJmNjRmOWUzMmM3N2I4Yzk2Y2YzYThmMDM3OTgwOGIzNzljZjI1ODgyM2UxM2ZmMjNlYjBjIiwic2lnbiI6IjUwYjQ2Y2EzZjJjZGM1MGJhMTZhY2Y3ZmU0OGRjNzZmMmRkYjVjYTZmOWIxYTQ1NTY1ZTkwZGViZGM0MjI5YTBlYzBiMzAwMzhlYTY0MmNmNGM2ZWMyOWNkMzNmZTBlYjFiYzlmMWYzZTU4ZDczNDUxNjJiYmNjMzA2ZTJhMTBlIn0=";
        networkDiagnosisCredentials.siteId = "cn";
        networkDiagnosisCredentials.putExtension("value", forKey: "key")
        networkDiagnosisCredentials.endpoint = "https://cn-hangzhou.log.aliyuncs.com"
        networkDiagnosisCredentials.project = "yuanbo-test-2"
        
        let tracerCredentials = credentials.createTrace()
        tracerCredentials.endpoint = "https://cn-beijing.log.aliyuncs.com";
        tracerCredentials.project = "qs-demos";
        tracerCredentials.logstore = "sls-mall-traces";
        
        SLSCocoa.sharedInstance().initialize(credentials) { configuration in
            configuration.spanProvider = SpanProvider()
            configuration.enableTrace = true
            configuration.enableInstrumentNSURLSession = true
//            configuration.spanProvider = SpanProvider()
        }
        
        SLSCocoa.sharedInstance().registerCredentialsCallback { feature, result in
            NSLog("feature: %s, result: %s", feature, result);
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

