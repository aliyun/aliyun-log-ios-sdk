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
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk)
import OpenTelemetryApi
import OpenTelemetrySdk
#endif
import AliNetworkDiagnosis


open class TraceNode : NSObject {
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk)
    var tracer: Tracer?
    var span: Span?
#endif
    var type: String
    var request: SLSRequest
    
    public init(_ type: String, _ request: SLSRequest) {
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk)
        self.tracer = OpenTelemetry.instance.tracerProvider.get(
            instrumentationName: "network_diagnosis",
            instrumentationVersion: "1.0.0"
        )
#endif
        self.type = type
        self.request = request
        
        super.init()
        start()
    }
    
    @objc
    public static func traceNode(_ type: String, request: SLSRequest) -> TraceNode {
        return TraceNode(type, request)
    }
    
    func start() {
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk)
        guard let tracer = self.tracer else {
            return
        }
        
        span = tracer.spanBuilder(spanName: type).startSpan()
        
        span?.setAttribute(key: "detection.type", value: type)
        span?.setAttribute(key: "detection.domain", value: request.domain)
        span?.setAttribute(key: "detection.traceId", value: span?.context.traceId.hexString ?? "")
        span?.setAttribute(key: "detection.spanId", value: span?.context.spanId.hexString ?? "")
        span?.setAttribute(key: "detection.deviceId", value: SLSUtdid.getUtdid())
#endif
    }
    
    @objc
    open func setDetectConfig(_ config: AliDetectConfig) {
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk)
        guard let span = span else {
            return
        }
        
        let flowNode = AliFlowNode()
        flowNode.nodeName = type
        flowNode.traceId = span.context.traceId.hexString
        flowNode.spanId = span.context.spanId.hexString
        
        if let s = span as? RecordEventsReadableSpan {
            flowNode.parentSpanId = s.parentContext?.spanId.hexString
        }

        config.setTraceFlowNode(flowNode)
#endif
    }
    
    @objc
    open func end() {
#if canImport(OpenTelemetryApi) && canImport(OpenTelemetrySdk)
        guard let span = span else {
            return
        }
        
        span.end()
#endif
    }
}
