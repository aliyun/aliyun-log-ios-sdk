//
//  LogProducerClient.swift
//  AliyunLogProducer
//
//  Created by lichao on 2020/8/25.
//  Copyright © 2020 lichao. All rights reserved.
//

import Foundation

open class LogProducerConfig: NSObject {
    
    fileprivate var config: UnsafeMutablePointer<log_producer_config>!
    
    fileprivate var mGlobalCallbackEnable: Bool = true
    
    @objc
    public convenience init(endpoint:String,project:String,logstore:String,accessKeyID:String,accessKeySecret:String) {
        self.init(endpoint: endpoint, project: project, logstore: logstore, accessKeyID: accessKeyID, accessKeySecret: accessKeySecret, isDebugEnabled: false);
    }
    
    @objc
    public convenience init(endpoint:String,project:String,logstore:String,accessKeyID:String,accessKeySecret:String,isDebugEnabled:Bool) {
        self.init(endpoint, project, logstore, isDebugEnabled);
        log_producer_config_set_access_id(config, accessKeyID);
        log_producer_config_set_access_key(config, accessKeySecret);
    }
    
    @objc
    public convenience init(endpoint:String,project:String,logstore:String,accessKeyID:String,accessKeySecret:String, securityToken:String) {
        self.init(endpoint: endpoint, project: project, logstore: logstore,accessKeyID: accessKeyID, accessKeySecret: accessKeySecret, securityToken: securityToken, isDebugEnabled: false);
    }

    @objc
    public convenience init(endpoint:String,project:String,logstore:String,accessKeyID:String,accessKeySecret:String, securityToken:String, isDebugEnabled:Bool) {
        self.init(endpoint, project, logstore, isDebugEnabled);
        log_producer_config_reset_security_token(config, accessKeyID, accessKeySecret, securityToken);
    }
    
    init(_ endpoint:String,_ project:String,_ logstore:String,_ isDebugEnabled:Bool) {
        if(isDebugEnabled) {
            aos_log_set_level(AOS_LOG_DEBUG);
        }
        config = create_log_producer_config();

        log_producer_config_set_endpoint(config, endpoint);
        log_producer_config_set_project(config, project);
        log_producer_config_set_logstore(config, logstore);

        log_producer_config_set_packet_timeout(config, 3000);
        log_producer_config_set_packet_log_count(config, 1024);
        log_producer_config_set_packet_log_bytes(config, 1024*1024);
        log_producer_config_set_send_thread_count(config, 1);
    }
    
    @objc
    open func SetTopic(_ topic:String){
        log_producer_config_set_topic(config, topic);
    }
    
    @objc
    open func AddTag(_ key:String, value:String){
        log_producer_config_add_tag(config, key, value);
    }
    
    @objc
    open func SetPacketLogBytes(_ num:Int32){
        log_producer_config_set_packet_log_bytes(config, num);
    }
    
    @objc
    open func SetPacketLogCount(_ num:Int32){
        log_producer_config_set_packet_log_count(config, num);
    }
    
    @objc
    open func SetPacketTimeout(_ num:Int32){
        log_producer_config_set_packet_timeout(config, num);
    }
    
    @objc
    open func SetMaxBufferLimit(_ num:Int64){
        log_producer_config_set_max_buffer_limit(config, num);
    }
    
    @objc
    open func SetSendThreadCount(_ num:Int32){
        log_producer_config_set_send_thread_count(config, num);
    }
    
    @objc
    open func SetPersistent(_ num:Int32){
        log_producer_config_set_persistent(config, num);
    }
    
    @objc
    open func SetPersistentFilePath(_ path:String){
        log_producer_config_set_persistent_file_path(config, path);
    }
    
    @objc
    open func SetPersistentForceFlush(_ num:Int32){
        log_producer_config_set_persistent_force_flush(config, num);
    }
    
    @objc
    open func SetPersistentMaxFileCount(_ num:Int32){
        log_producer_config_set_persistent_max_file_count(config, num);
    }
    
    @objc
    open func SetPersistentMaxFileSize(_ num:Int32){
        log_producer_config_set_persistent_max_file_size(config, num);
    }
    
    @objc
    open func SetPersistentMaxLogCount(_ num:Int32){
        log_producer_config_set_persistent_max_log_count(config, num);
    }
    
    @objc
    open func ResetSecurityToken(_ accessKeyID:String, accessKeySecret:String, securityToken:String){
        log_producer_config_reset_security_token(config, accessKeyID, accessKeySecret, securityToken);
    }
    
    @objc
    open func IsGlobalCallbackEnable(_ isGlobalCallbackEnable:Bool){
        mGlobalCallbackEnable = isGlobalCallbackEnable;
    }
    
    @objc
    open var IsGlobalCallbackEnable : Bool {
        return mGlobalCallbackEnable;
    }
    
    @objc
    open var logProducerConfig: UnsafeMutablePointer<log_producer_config>! {
        return config;
    }
}
