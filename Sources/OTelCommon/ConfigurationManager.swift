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
public class Workspace: NSObject {
    public var endpoint: String?
    public var project: String?
    public var instanceId: String?
    
    @objc
    public static func `init`(endpoint: String? = nil, project: String? = nil, instanceId: String? = nil) -> Workspace {
        let resourceConfiguration = Workspace()
        resourceConfiguration.endpoint = endpoint
        resourceConfiguration.project = project
        resourceConfiguration.instanceId = instanceId
        
        return resourceConfiguration
    }
}

@objcMembers
public class Environment: NSObject {
    public var env: String?
    public var uid: String?
    public var utdid: String?
    public var channel: String?
    
    @objc
    public static func `init`(env: String? = nil, uid: String? = nil, utdid: String? = nil, channel: String? = nil) -> Environment {
        let configuration = Environment()
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
    public func setProvider(accessKeyProvider: ((String) -> AccessKey?)? = nil,
                            workspaceProvider: ((String) -> Workspace?)? = nil,
                            environmentProvider: ((String) -> Environment?)? = nil) {
        self.accessKeyProvider = accessKeyProvider
        self.workspaceProvider = workspaceProvider
        self.environmentProvider = environmentProvider
    }
    
    public var accessKeyProvider: ((String) -> AccessKey?)?
    public var workspaceProvider: ((String) -> Workspace?)?
    public var environmentProvider: ((String) -> Environment?)?
}
