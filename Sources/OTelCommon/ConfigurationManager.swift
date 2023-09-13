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
public class AccessKeyConfiguration: NSObject {
    public var accessKeyId: String?
    public var accessKeySecret: String?
    public var accessKeySecuritToken: String?
    
    @objc
    public static func `init`(accessKeyId: String? = nil, accessKeySecret: String? = nil, accessKeySecuritToken: String? = nil) -> AccessKeyConfiguration {
        let accessKeyConfiguration = AccessKeyConfiguration()
        accessKeyConfiguration.accessKeyId = accessKeyId
        accessKeyConfiguration.accessKeySecret = accessKeySecret
        accessKeyConfiguration.accessKeySecuritToken = accessKeySecuritToken
        
        return accessKeyConfiguration
    }
}

@objcMembers
public class ResourceConfiguration: NSObject {
    public var endpoint: String?
    public var project: String?
    public var instanceId: String?
    
    @objc
    public static func `init`(endpoint: String? = nil, project: String? = nil, instanceId: String? = nil) -> ResourceConfiguration {
        let resourceConfiguration = ResourceConfiguration()
        resourceConfiguration.endpoint = endpoint
        resourceConfiguration.project = project
        resourceConfiguration.instanceId = instanceId
        
        return resourceConfiguration
    }
}

public class ConfigurationManager: NSObject {
    @objc
    public static var shared = ConfigurationManager()
    private override init() {}
    
    @objc
    public func setDelegate(delegateAccessKey: ((String) -> AccessKeyConfiguration?)? = nil, delegateResource: ((String) -> ResourceConfiguration?)? = nil) {
        self.delegateAccessKey = delegateAccessKey
        self.delegateResource = delegateResource
    }
    
    public var delegateAccessKey: ((String) -> AccessKeyConfiguration?)?
    public var delegateResource: ((String) -> ResourceConfiguration?)?
}
