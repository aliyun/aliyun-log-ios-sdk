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
import OpenTelemetryApi
import OpenTelemetrySdk
import AliyunLogOtlpExporter
//import AliyunLogCore
import UIKit
import AliyunLogOTelCommon

internal class CrashReporterOTel {
    let SCOPE: String = "uem"
    
    static var tracerProvider: TracerProvider?
    
    public init() {
        
    }
    
    func initOtel() {
        let otlpSLSExporter = OtlpSLSSpanExporter.builder()
            .setEndpoint(ConfigurationManager.shared.delegateResource?(SCOPE)?.endpoint ?? "")
            .setProject(ConfigurationManager.shared.delegateResource?(SCOPE)?.project ?? "")
            .setLogstore(ConfigurationManager.shared.delegateResource?(SCOPE)?.instanceId ?? "")
            .setAccessKey(accessKeyId: ConfigurationManager.shared.delegateAccessKey?(SCOPE)?.accessKeyId,
                          accessKeySecret: ConfigurationManager.shared.delegateAccessKey?(SCOPE)?.accessKeySecret,
                          ConfigurationManager.shared.delegateAccessKey?(SCOPE)?.accessKeySecuritToken
            )
            .build()
        let spanExporters = MultiSpanExporter(spanExporters: [otlpSLSExporter])
        let spanProcessor = BatchSpanProcessor(spanExporter: spanExporters)
        
        var appName: String? = ""
        var appVersion: String? = ""
        var appVersionCode: String? = ""
        if let infoDictionary = Bundle.main.infoDictionary {
            appName = infoDictionary["CFBundleDisplayName"] as? String ?? infoDictionary["CFBundleName"] as? String
            appVersion = infoDictionary["CFBundleShortVersionString"] as? String
            appVersionCode = infoDictionary["CFBundleVersion"] as? String
        }
        
        CrashReporterOTel.tracerProvider = TracerProviderBuilder()
            .add(spanProcessor: spanProcessor)
            .with(resource: Resource()
                .merging(other: Resource(attributes: [
                    ResourceAttributes.deviceId.rawValue: AttributeValue.string(Utdid.getUtdid()),
                    ResourceAttributes.deviceManufacturer.rawValue: AttributeValue.string("Apple"),
                    ResourceAttributes.deviceModelName.rawValue: AttributeValue.string(DeviceUtils.getDeviceModel()),
                    ResourceAttributes.deviceModelIdentifier.rawValue: AttributeValue.string(DeviceUtils.getDeviceModelIdentifier()),
                    "device.resolution": AttributeValue.string(DeviceUtils.getResolution()),
                    "app.version": AttributeValue.string(appVersion ?? ""),
                    "app.versionCode": AttributeValue.string(appVersionCode ?? ""),
                    "app.name": AttributeValue.string(appName ?? ""),
                    ResourceAttributes.osName.rawValue: AttributeValue.string("iOS"),
                    ResourceAttributes.osType.rawValue: AttributeValue.string("darwin"),
                    ResourceAttributes.osVersion.rawValue: AttributeValue.string(UIDevice.current.systemVersion),
                    ResourceAttributes.osDescription.rawValue: AttributeValue.string("Apple Darwin"),
                    ResourceAttributes.hostName.rawValue: AttributeValue.string(ProcessInfo.processInfo.hostName),
                    ResourceAttributes.hostArch.rawValue: AttributeValue.string(DeviceUtils.getCPUArch()),
                    "uem.data.type": AttributeValue.string("iOS"),
                    "uem.sdk.version": AttributeValue.string("")
                ]))
            )
            .build()
        
    }
    
    static func spanBuilder(_ spanName: String) -> SpanBuilder? {
        CrashReporterOTel.tracerProvider?
            .get(instrumentationName: "CrashReporter", instrumentationVersion: "0.1.0")
            .spanBuilder(spanName: spanName)
    }
}
