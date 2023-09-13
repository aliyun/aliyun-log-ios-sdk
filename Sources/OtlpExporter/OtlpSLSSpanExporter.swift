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
import AliyunLogProducer
import AliyunLogOTelCommon

open class OtlpSLSSpanExporter: NSObject, SpanExporter {
    let jsonEncoder = JSONEncoder()
    let scope: String
    var config: LogProducerConfig?
    var client: LogProducerClient?
    
    public static func builder(_ scope: String = "default") -> OtlpSLSSpanExporterBuilder {
        return OtlpSLSSpanExporterBuilder(scope)
    }
    
    public init(_ scope: String, _ endpoint: String?, _ project: String?, _ logstore: String?, _ accessKeyId: String?, _ accessKeySecret: String?, _ accessKeyToken: String?) {
        self.scope = scope
        super.init()
        self.initLogProducer(endpoint, project, logstore, accessKeyId, accessKeySecret, accessKeyToken)
        
    }
    
    func initLogProducer(_ endpoint: String?, _ project: String?, _ logstore: String?, _ accessKeyId: String?, _ accessKeySecret: String?, _ accessKeyToken: String?) {
        config = LogProducerConfig(endpoint: endpoint, project: project, logstore: logstore, accessKeyID: accessKeyId, accessKeySecret: accessKeySecret, securityToken: accessKeyToken)
        config?.setTopic(scope)
        config?.setPacketLogBytes(1024*1024)
        config?.setPacketLogCount(4096)
        config?.setPacketTimeout(3000)
        config?.setMaxBufferLimit(32*1024*1024)
        
//        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *Path = [[paths lastObject] stringByAppendingString:@"/log.dat"];
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths.last ?? "" + "/data"
        config?.setPersistent(1)
        config?.setPersistentFilePath(path)
        config?.setPersistentMaxFileCount(10)
        config?.setPersistentMaxFileSize(10*1024*1024)
        config?.setPersistentMaxLogCount(65536)
        
        config?.setDropDelayLog(1)
        config?.setDropUnauthorizedLog(0)
        
//        let selfPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        client = LogProducerClient(logProducerConfig: config, callback: { configName, resultCode, logBytes, compressedBytes, reqId, message, rawBuffer, userParams in
            guard let pointer = userParams else {
                return
            }
            
            let self_p = unsafeBitCast(pointer, to: OtlpSLSSpanExporter.self)
            
            if LOG_PRODUCER_PARAMETERS_INVALID == resultCode {
                if let resource = ConfigurationManager.shared.delegateResource?(self_p.scope) {
                    self_p.config?.setEndpoint(resource.endpoint)
                    self_p.config?.setProject(resource.project)
                    self_p.config?.setLogstore(resource.instanceId)
                }
                
                if let accessKey = ConfigurationManager.shared.delegateAccessKey?(self_p.scope) {
                    self_p.config?.setAccessKeyId(accessKey.accessKeyId)
                    self_p.config?.setAccessKeySecret(accessKey.accessKeySecret)
                    if let token = accessKey.accessKeySecuritToken, !token.isEmpty {
                        self_p.config?.resetSecurityToken(accessKey.accessKeyId,
                                                          accessKeySecret: accessKey.accessKeySecret,
                                                          securityToken: accessKey.accessKeySecuritToken
                        )
                    }
                }
            } else if LOG_PRODUCER_SEND_UNAUTHORIZED == resultCode {
                if let accessKey = ConfigurationManager.shared.delegateAccessKey?(self_p.scope) {
                    self_p.config?.setAccessKeyId(accessKey.accessKeyId)
                    self_p.config?.setAccessKeySecret(accessKey.accessKeySecret)
                    if let token = accessKey.accessKeySecuritToken, !token.isEmpty {
                        self_p.config?.resetSecurityToken(accessKey.accessKeyId,
                                                          accessKeySecret: accessKey.accessKeySecret,
                                                          securityToken: accessKey.accessKeySecuritToken
                        )
                    }
                }
            }
        }, userparams: self)
    }
    
    
    public func export(spans: [OpenTelemetrySdk.SpanData]) -> OpenTelemetrySdk.SpanExporterResultCode {
        for span in spans {
            do {
                let jsonData = try jsonEncoder.encode(SpanExporterData(span: span))
                if let json = String(data: jsonData, encoding: .utf8) {
                    print(json)
                }
                
                let log: Log = Log()
                log.putContent(jsonData)
                client?.add(log)
            } catch {
                return .failure
            }
        }
        return .success
    }
    
    public func flush() -> OpenTelemetrySdk.SpanExporterResultCode {
        return .success
    }
    
    public func shutdown() {
        
    }
}

private struct SpanExporterData {
    private let name: String
    private let traceId: String
    private let spanId: String
    private let spanKind: String
    private let traceFlags: TraceFlags
    private let traceState: TraceState
    private let parentSpanId: String?
    private let start: Date
    private let end: Date
    private let duration: TimeInterval
    private let attributes: [String: AttributeValue]
    private let resource: [String: AttributeValue]
    
    private let host: String
    private let service: String
    private let statusCode: String
    private let statusMessage: String
    
    init(span: SpanData) {
        self.name = span.name
        self.traceId = span.traceId.hexString
        self.spanId = span.spanId.hexString
        self.spanKind = span.kind.rawValue
        self.traceFlags = span.traceFlags
        self.traceState = span.traceState
        self.parentSpanId = span.parentSpanId?.hexString ?? SpanId.invalid.hexString
        self.start = span.startTime
        self.end = span.endTime
        self.duration = span.endTime.timeIntervalSince(span.startTime)
        self.attributes = span.attributes
        self.resource = span.resource.attributes
        
        self.host = span.resource.attributes["host.name"]?.description ?? ""
        self.service = span.resource.attributes["service.name"]?.description ?? ""
        self.statusCode = span.status.name
        self.statusMessage = span.status.description
    }
}

extension SpanExporterData: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case traceID
        case spanID
        case kind
        case traceFlags
        case traceState
        case parentSpanID
        case start
        case end
        case duration
        case attribute
        case resource
        
        case host
        case service
        case statusCode
        case statusMessage
    }
    
    enum TraceFlagsCodingKeys: String, CodingKey {
        case sampled
    }
    
    enum TraceStateCodingKeys: String, CodingKey {
        case entries
    }
    
    enum TraceStateEntryCodingKeys: String, CodingKey {
        case key
        case value
    }
    
    struct AttributesCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }
    
    enum AttributeValueCodingKeys: String, CodingKey {
        case description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(traceId, forKey: .traceID)
        try container.encode(spanId, forKey: .spanID)
        try container.encode(spanKind, forKey: .kind)
        
        var traceFlagsContainer = container.nestedContainer(keyedBy: TraceFlagsCodingKeys.self, forKey: .traceFlags)
        try traceFlagsContainer.encode(traceFlags.sampled, forKey: .sampled)
        
        var traceStateContainer = container.nestedContainer(keyedBy: TraceStateCodingKeys.self, forKey: .traceState)
        var traceStateEntriesContainer = traceStateContainer.nestedUnkeyedContainer(forKey: .entries)
        
        try traceState.entries.forEach { entry in
            var traceStateEntryContainer = traceStateEntriesContainer.nestedContainer(keyedBy: TraceStateEntryCodingKeys.self)
            
            try traceStateEntryContainer.encode(entry.key, forKey: .key)
            try traceStateEntryContainer.encode(entry.value, forKey: .value)
        }
        
        try container.encodeIfPresent(parentSpanId, forKey: .parentSpanID)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(duration, forKey: .duration)
        
        try container.encode(host, forKey: .host)
        try container.encode(service, forKey: .service)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(statusMessage, forKey: .statusMessage)
        
        var attributesContainer = container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attribute)
        
        try attributes.forEach { attribute in
            if let attributeValueCodingKey = AttributesCodingKeys(stringValue: attribute.key) {
                try attributesContainer.encode(attribute.value.description, forKey: attributeValueCodingKey)
            } else {
                // this should never happen
                let encodingContext = EncodingError.Context(codingPath: attributesContainer.codingPath,
                                                            debugDescription: "Failed to create coding key")
                
                throw EncodingError.invalidValue(attribute, encodingContext)
            }
        }
        
        var resourceContainer = container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .resource)
        try resource.forEach { attribute in
            if let attributeValueCodingKey = AttributesCodingKeys(stringValue: attribute.key) {
                try resourceContainer.encode(attribute.value.description, forKey: attributeValueCodingKey)
            } else {
                // this should never happen
                let encodingContext = EncodingError.Context(codingPath: resourceContainer.codingPath,
                                                            debugDescription: "Failed to create resouce coding key")
                throw EncodingError.invalidValue(attribute, encodingContext)
            }
        }
        
        
    }
}


