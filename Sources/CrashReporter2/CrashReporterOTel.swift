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
    static let VERSION: String = "0.1.0"
    static let SCOPE: String = "uem"
    
    static var tracerProvider: TracerProviderSdk?
    
    public init() {
        
    }
    
    func initOtel() {
        let scope = CrashReporterOTel.SCOPE
        let workspace = ConfigurationManager.shared.workspaceProvider?(scope)
        let accessKey = ConfigurationManager.shared.accessKeyProvider?(scope)
        let environment = ConfigurationManager.shared.environmentProvider?(scope)
        let otlpSLSExporter = OtlpSLSSpanExporter.builder(scope)
            .setEndpoint(workspace?.endpoint ?? "")
            .setProject(workspace?.project ?? "")
            .setLogstore("\(workspace?.instanceId ?? "")-uem-mobile-raw")
            .setPersistentFlush(true)
            .setAccessKey(
                accessKeyId: accessKey?.accessKeyId,
                accessKeySecret: accessKey?.accessKeySecret,
                accessKeyToken: accessKey?.accessKeySecuritToken
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
        
#if os(iOS)
        let osName = "iOS"
#elseif os(macOS)
        let osName = "macOS"
#elseif os(tvOS)
        let osName = "tvOS"
#elseif os(watchOS)
        let osName = "watchOS"
#else
        let osName = "unknown"
#endif
        
        let utdid = environment?.utdid ?? Utdid.getUtdid()
        
        CrashReporterOTel.tracerProvider = TracerProviderBuilder()
            .add(spanProcessor: spanProcessor)
            .with(resource: Resource()
                .merging(other: Resource(attributes: [
                    ResourceAttributes.serviceName.rawValue: AttributeValue.string("sls-cocoa"),
                    ResourceAttributes.deviceId.rawValue: AttributeValue.string(utdid),
                    ResourceAttributes.deviceManufacturer.rawValue: AttributeValue.string("Apple"),
                    ResourceAttributes.deviceModelName.rawValue: AttributeValue.string(DeviceUtils.getDeviceModel()),
                    ResourceAttributes.deviceModelIdentifier.rawValue: AttributeValue.string(DeviceUtils.getDeviceModelIdentifier()),
                    "device.screen": AttributeValue.string(DeviceUtils.getResolution()),
                    "app.version": AttributeValue.string(appVersion ?? ""),
                    "app.versionCode": AttributeValue.string(appVersionCode ?? ""),
                    "app.name": AttributeValue.string(appName ?? ""),
                    ResourceAttributes.osName.rawValue: AttributeValue.string(osName),
                    ResourceAttributes.osType.rawValue: AttributeValue.string("darwin"),
                    ResourceAttributes.osVersion.rawValue: AttributeValue.string(UIDevice.current.systemVersion),
                    ResourceAttributes.osDescription.rawValue: AttributeValue.string("Apple Darwin"),
                    ResourceAttributes.hostName.rawValue: AttributeValue.string(ProcessInfo.processInfo.hostName),
                    ResourceAttributes.hostArch.rawValue: AttributeValue.string(DeviceUtils.getCPUArch()),
                    "uem.data.type": AttributeValue.string(osName),
                    "uem.sdk.version": AttributeValue.string(CrashReporterOTel.VERSION),
                    "workspace": AttributeValue.string(workspace?.instanceId ?? ""),
                    "deployment.environment": AttributeValue.string(environment?.env ?? "default"),
                    "deployment.channel": AttributeValue.string(environment?.channel ?? "default")
                ]))
            )
            .build()
    }
    
    static func spanBuilder(_ spanName: String) -> SpanBuilder? {
        CrashReporterOTel.tracerProvider?
            .get(instrumentationName: "CrashReporter", instrumentationVersion: CrashReporterOTel.VERSION)
            .spanBuilder(spanName: spanName)
    }
    
    static func forceFlush() {
        CrashReporterOTel.tracerProvider?.forceFlush()
    }
}
