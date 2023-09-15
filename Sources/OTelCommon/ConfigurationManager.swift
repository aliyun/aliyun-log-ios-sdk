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


import Foundation

@objcMembers
public class AccessKey: NSObject {
    public var accessKeyId: String?
    public var accessKeySecret: String?
    public var accessKeySecuritToken: String?
    
    @objc
    public static func `init`(accessKeyId: String? = nil, accessKeySecret: String? = nil, accessKeySecuritToken: String? = nil) -> AccessKey {
        let accessKeyConfiguration = AccessKey()
        accessKeyConfiguration.accessKeyId = accessKeyId
        accessKeyConfiguration.accessKeySecret = accessKeySecret
        accessKeyConfiguration.accessKeySecuritToken = accessKeySecuritToken
        
        return accessKeyConfiguration
    }
}

@objcMembers
public class Resource: NSObject {
    public var endpoint: String?
    public var project: String?
    public var instanceId: String?
    
    @objc
    public static func `init`(endpoint: String? = nil, project: String? = nil, instanceId: String? = nil) -> Resource {
        let resourceConfiguration = Resource()
        resourceConfiguration.endpoint = endpoint
        resourceConfiguration.project = project
        resourceConfiguration.instanceId = instanceId
        
        return resourceConfiguration
    }
}

@objcMembers
public class Configuration: NSObject {
    public var env: String?
    public var uid: String?
    public var utdid: String?
    public var channel: String?
    
    @objc
    public static func `init`(env: String? = nil, uid: String? = nil, utdid: String? = nil, channel: String? = nil) -> Configuration {
        let configuration = Configuration()
        configuration.env = env
        configuration.uid = uid
        configuration.utdid = utdid
        configuration.channel = channel
        
        return configuration
    }
}

public class ConfigurationManager: NSObject {
    @objc
    public static var shared = ConfigurationManager()
    private override init() {}
    
    @objc
    public func setDelegate(delegateAccessKey: ((String) -> AccessKey?)? = nil,
                            delegateResource: ((String) -> Resource?)? = nil,
                            delegateConfiguration: ((String) -> Configuration?)? = nil) {
        self.delegateAccessKey = delegateAccessKey
        self.delegateResource = delegateResource
        self.delegateConfiguration = delegateConfiguration
    }
    
    public var delegateAccessKey: ((String) -> AccessKey?)?
    public var delegateResource: ((String) -> Resource?)?
    public var delegateConfiguration: ((String) -> Configuration?)?
}
