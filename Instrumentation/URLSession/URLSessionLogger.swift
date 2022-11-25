/*
 * Copyright The OpenTelemetry Authors
 * SPDX-License-Identifier: Apache-2.0
 */

import Foundation
//import OpenTelemetryApi
//import OpenTelemetrySdk
import os.log
#if os(iOS) && !targetEnvironment(macCatalyst)
//    import NetworkStatus
#endif // os(iOS) && !targetEnvironment(macCatalyst)

class URLSessionLogger {
    static var runningSpans = [String: SLSSpan]()
    static var runningSpansQueue = DispatchQueue(label: "io.opentelemetry.URLSessionLogger")
//    #if os(iOS) && !targetEnvironment(macCatalyst)
//
//        static var netstatInjector: NetworkStatusInjector? = { () -> NetworkStatusInjector? in
//            do {
//                let netstats = try NetworkStatus()
//                return NetworkStatusInjector(netstat: netstats)
//            } catch {
//                if #available(iOS 14, macOS 11, tvOS 14, *) {
//                    os_log(.error, "failed to initialize network connection status: %@", error.localizedDescription)
//                } else {
//                    NSLog("failed to initialize network connection status: %@", error.localizedDescription)
//                }
//
//                return nil
//            }
//        }()
//    #endif // os(iOS) && !targetEnvironment(macCatalyst)

    /// This methods creates a Span for a request, and optionally injects tracing headers, returns a  new request if it was needed to create a new one to add the tracing headers
    @discardableResult static func processAndLogRequest(_ request: URLRequest, sessionTaskId: String, instrumentation: URLSessionInstrumentation, shouldInjectHeaders: Bool) -> URLRequest? {
        guard instrumentation.configuration.shouldInstrument?(request) ?? true else {
            return nil
        }
        
        var spanName = "HTTP " + (request.httpMethod ?? "")
        if let customSpanName = instrumentation.configuration.nameSpan?(request) {
            spanName = customSpanName
        }
        
        let spanBuilder = SLSTracer.spanBuilder(spanName)
        spanBuilder.addAttributes([
            SLSAttribute.of("http.method", value: request.httpMethod ?? "unknown_method"),
            SLSAttribute.of("http.url", value: request.url?.absoluteString ?? ""),
            SLSAttribute.of("http.target", value: request.url?.path ?? ""),
            SLSAttribute.of("net.peer.name", value: request.url?.host ?? ""),
            SLSAttribute.of("http.scheme", value: request.url?.scheme ?? ""),
            SLSAttribute.of("net.peer.port", value: String(request.url?.port ?? 0))
//            SLSAttribute.of("", value: "")
        ])

        instrumentation.configuration.spanCustomization?(request, spanBuilder)

        let span = spanBuilder.build()
        runningSpansQueue.sync {
            runningSpans[sessionTaskId] = span
        }

        var returnRequest: URLRequest?
        if shouldInjectHeaders, instrumentation.configuration.shouldInjectTracingHeaders?(request) ?? true {
            returnRequest = instrumentedRequest(for: request, span: span, instrumentation: instrumentation)
        }

//        #if os(iOS) && !targetEnvironment(macCatalyst)
//            if let injector = netstatInjector {
//                injector.inject(span: span)
//            }
//        #endif

        instrumentation.configuration.createdRequest?(returnRequest ?? request, span)

        return returnRequest
    }

    /// This methods ends a Span when a response arrives
    static func logResponse(_ response: URLResponse, dataOrFile: Any?, instrumentation: URLSessionInstrumentation, sessionTaskId: String) {
        var span: SLSSpan!
        runningSpansQueue.sync {
            span = runningSpans.removeValue(forKey: sessionTaskId)
        }
        guard span != nil,
              let httpResponse = response as? HTTPURLResponse
        else {
            return
        }

        span.addAttributes([SLSAttribute.of("http.status_code", value: String(httpResponse.statusCode))])
        span.statusCode = URLSessionLogger.statusForStatusCode(code: httpResponse.statusCode)

        instrumentation.configuration.receivedResponse?(response, dataOrFile, span)
        span.end()
    }

    /// This methods ends a Span when a error arrives
    static func logError(_ error: Error, dataOrFile: Any?, statusCode: Int, instrumentation: URLSessionInstrumentation, sessionTaskId: String) {
        var span: SLSSpan!
        runningSpansQueue.sync {
            span = runningSpans.removeValue(forKey: sessionTaskId)
        }
        guard span != nil else {
            return
        }
        
        span.addAttributes([SLSAttribute.of("http.status_code", value: String(statusCode))])
        span.statusCode = URLSessionLogger.statusForStatusCode(code: statusCode)
        instrumentation.configuration.receivedError?(error, dataOrFile, statusCode, span)

        span.end()
    }

    private static func statusForStatusCode(code: Int) -> SLSStatusCode {
        switch code {
        case 100 ... 399:
            return SLSStatusCode.UNSET
        default:
            return SLSStatusCode.ERROR
        }
    }

    private static func instrumentedRequest(for request: URLRequest, span: SLSSpan?, instrumentation: URLSessionInstrumentation) -> URLRequest? {
        var request = request
        guard instrumentation.configuration.shouldInjectTracingHeaders?(request) ?? true
        else {
            return nil
        }
        instrumentation.configuration.injectCustomHeaders?(&request, span)
        var instrumentedRequest = request
        objc_setAssociatedObject(instrumentedRequest, &URLSessionInstrumentation.instrumentedKey, true, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        var traceHeaders = tracePropagationHTTPHeaders(span: span)
        if let originalHeaders = request.allHTTPHeaderFields {
            traceHeaders.merge(originalHeaders) { _, new in new }
        }
        instrumentedRequest.allHTTPHeaderFields = traceHeaders
        return instrumentedRequest
    }

    private static func tracePropagationHTTPHeaders(span: SLSSpan?) -> [String: String] {
        var headers = [String: String]()

//        struct HeaderSetter: Setter {
//            func set(carrier: inout [String: String], key: String, value: String) {
//                carrier[key] = value
//            }
//        }
//
//        guard let currentSpan = span ?? OpenTelemetry.instance.contextProvider.activeSpan else {
//            return headers
//        }
//        textMapPropagator.inject(spanContext: currentSpan.context, carrier: &headers, setter: HeaderSetter())
        
        guard let currentSpan: SLSSpan? = span ?? SLSContextManager.activeSpan() else {
            return headers
        }
        
        let traceparent = String(format: "00-%@-%@-01", currentSpan?.traceID ?? "", currentSpan?.spanID ?? "")
        headers["traceparent"] = traceparent
        
        return headers
    }
}
