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
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk) && canImport(AliyunLogOtlpExporter)
import OpenTelemetryApi
import OpenTelemetrySdk
import AliyunLogOtlpExporter
#endif

public class NetworkDiagnosisHelper : NSObject {
    static var endpoint: String?
    static var project: String?
    static var logstore: String?
    
    @objc
    public static func updateWorkspace(_ endpoint: String?, project: String?, logstore: String?) {
        self.endpoint = endpoint
        self.project = project
        self.logstore = logstore
    }
    
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk) && canImport(AliyunLogOtlpExporter)
    @objc
    public static func exporter() -> OtlpSLSSpanExporter {
        return OtlpSLSSpanExporter.builder("ipa")
            .setEndpoint(endpoint ?? "")
            .setProject(project ?? "")
            .setLogstore("ipa-\(logstore ?? "")-raw")
            .build()
    }
#else
    @objc
    public static func exporter() -> NSObject? {
        return nil
    }
#endif
    
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk) && canImport(AliyunLogOtlpExporter)
    public static func setupTrace(_ builder: inout TracerProviderBuilder) {
        let exporter = OtlpSLSSpanExporter.builder("ipa")
            .setEndpoint(endpoint ?? "")
            .setProject(project ?? "")
            .setLogstore("ipa-\(logstore ?? "")-raw")
            .build()
        let spanProcessor = BatchSpanProcessor(spanExporter: exporter)
        
        _ = builder.add(spanProcessor: spanProcessor)
    }
#else
    public static func setupTrace(_ builder: inout NSObject) {
        
    }
#endif
}
