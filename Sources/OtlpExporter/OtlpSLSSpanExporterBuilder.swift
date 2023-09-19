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

open class OtlpSLSSpanExporterBuilder {
    let scope: String
    var endpoint: String?
    var project: String?
    var logstore: String?
    var accessKeyId: String?
    var accessKeySecret: String?
    var accessKeyToken: String?
    var isPersistentFlush: Bool = false
    
    public init(_ scope: String) {
        self.scope = scope
    }
    
    open func setEndpoint(_ endpoint: String?) -> OtlpSLSSpanExporterBuilder {
        self.endpoint = endpoint
        return self
    }
    
    open func setProject(_ project: String?) -> OtlpSLSSpanExporterBuilder {
        self.project = project
        return self
    }
    
    open func setLogstore(_ logstore: String?) -> OtlpSLSSpanExporterBuilder {
        self.logstore = logstore
        return self
    }
    
    open func setAccessKey(accessKeyId: String?, accessKeySecret: String?, accessKeyToken: String? = nil) -> OtlpSLSSpanExporterBuilder {
        self.accessKeyId = accessKeyId
        self.accessKeySecret = accessKeySecret
        self.accessKeyToken = accessKeyToken
        return self
    }
    
    open func setPersistentFlush(_ isPersistentFlush: Bool) -> OtlpSLSSpanExporterBuilder {
        self.isPersistentFlush = isPersistentFlush
        return self
    }
    
    open func build() -> OtlpSLSSpanExporter {
        return OtlpSLSSpanExporter(scope, isPersistentFlush, endpoint, project, logstore, accessKeyId, accessKeySecret, accessKeyToken)
    }
}
