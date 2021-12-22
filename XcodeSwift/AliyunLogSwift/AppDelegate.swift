//
//  AppDelegate.swift
//  AliyunLogSwift
//
//  Created by gordon on 2021/12/17.
//

import UIKit
import AliyunLogProducer

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
        
        let config = SLSConfig()
        config.debuggable = true
        
        config.endpoint = utils.endpoint
        config.pluginLogproject = utils.project
        config.pluginAppId = utils.pluginAppId
        config.accessKeyId = utils.accessKeyId
        config.accessKeySecret = utils.accessKeySecret
        
        config.userId = "test_userid"
        config.channel = "test_channel"
        config.addCustom(withKey: "custom_key", andValue: "custom_value")
        
        let adapter = SLSAdapter.sharedInstance()
        adapter.add(SLSCrashReporterPlugin())
        adapter.initWith(config)
        
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

