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
//#if canImport(URLSessionInstrumentation)
import URLSessionInstrumentation
import OpenTelemetryApi
//#endif

public struct AliyunURLSessionInstrumentationConfiguration {
//#if canImport(URLSessionInstrumentation)
    let configuration: URLSessionInstrumentationConfiguration?
//#endif
    
    public var headersInWhiteList: [String]?
    public var headersInBlackList: [String]?
    public var shouldRecordRequestBody: ((URLRequest) -> Bool)?
    public var shouldRecordResponseBody: ((URLResponse) -> Bool)?
    
//#if canImport(URLSessionInstrumentation)
    public init(_ configuration: URLSessionInstrumentationConfiguration?,
                _ headersInWhiteList: [String]?,
                _ headersInBlackList: [String]?,
                _ shouldRecordRequestBody: ((URLRequest) -> Bool)? = nil,
                _ shouldRecordResponseBody: ((URLResponse) -> Bool)? = nil)
    {
        self.configuration = configuration
        self.headersInBlackList = headersInBlackList
        self.shouldRecordRequestBody = shouldRecordRequestBody
        self.shouldRecordResponseBody = shouldRecordResponseBody
    }
//#else
//    public init(_ headersInWhiteList: [String]?,
//                _ headersInBlackList: [String]?,
//                _ shouldRecordRequestBody: ((URLRequest) -> Bool)? = nil,
//                _ shouldRecordResponseBody: ((URLResponse) -> Bool)? = nil)
//    {
//        self.headersInBlackList = headersInBlackList
//        self.shouldRecordRequestBody = shouldRecordRequestBody
//        self.shouldRecordResponseBody = shouldRecordResponseBody
//    }
//#endif
    
}

//#if canImport(URLSessionInstrumentation)
extension URLSessionInstrumentationConfiguration {
    
    public init(configuration: AliyunURLSessionInstrumentationConfiguration?) {
        self.init(
            shouldRecordPayload: { session in
                return configuration?.configuration?.shouldRecordPayload?(session) ?? true
            }, shouldInstrument: { request in
                return configuration?.configuration?.shouldInstrument?(request) ?? true
            }, nameSpan: { request in
                return configuration?.configuration?.nameSpan?(request) ?? "\(request.httpMethod?.uppercased() ?? "") \(request.url?.path ?? "")"
            }, spanCustomization: { (request, spanBuilder) in
                URLSessionInstrumentationConfiguration.recordHeaders(
                    configuarion: configuration,
                    headers: request.allHTTPHeaderFields,
                    spanBuilder: spanBuilder,
                    span: nil
                )
                
                // 对齐最新的SemanticAttributes
                spanBuilder.setAttribute(key: SemanticAttributes.urlPath.rawValue, value: request.url?.absoluteString ?? "")
                spanBuilder.setAttribute(key: SemanticAttributes.urlScheme.rawValue, value: request.url?.scheme ?? "")
                spanBuilder.setAttribute(key: SemanticAttributes.urlFull.rawValue, value: request.url?.absoluteString ?? "")
                spanBuilder.setAttribute(key: SemanticAttributes.serverAddress.rawValue, value: request.url?.host ?? "")
                
                if let method = request.httpMethod?.uppercased(),
                   "POST" == method || "PUT" == method || "PATCH" == method || "DELETE" == method {
                    guard configuration?.shouldRecordRequestBody?(request) ?? true else {
                        return
                    }
                    
                    guard let httpBody = request.httpBody else {
                        return
                    }
                    spanBuilder.setAttribute(key: SemanticAttributes.httpRequestBodySize.rawValue, value: httpBody.count)
                    
                    guard let body = String(data: httpBody, encoding: .utf8) else {
                        return
                    }
                    spanBuilder.setAttribute(key: "http.request.body", value: body)
                } else {
                    spanBuilder.setAttribute(key: SemanticAttributes.urlQuery.rawValue, value: request.url?.query ?? "")
                }
            }, shouldInjectTracingHeaders: { request in
                return true
            }, injectCustomHeaders: { request, span in
                
            }, createdRequest: { request, span in
                // remove http.method
                span.setAttribute(key: SemanticAttributes.httpMethod.rawValue, value: nil)
                // remove http.scheme
                span.setAttribute(key: SemanticAttributes.httpScheme.rawValue, value: nil)
                // remove http.url
                span.setAttribute(key: SemanticAttributes.httpUrl.rawValue, value: nil)
                // remote http.target
                span.setAttribute(key: SemanticAttributes.httpTarget.rawValue, value: nil)
                
                // add http.request.method
                span.setAttribute(key: "http.request.method", value: request.httpMethod ?? "unknown_method")
            }, receivedResponse: { response, dataOrFile, span in
                guard let res = response as? HTTPURLResponse else {
                    return
                }
                
                URLSessionInstrumentationConfiguration.recordHeaders(
                    configuarion: configuration,
                    headers: URLSessionInstrumentationConfiguration.converAllHeaders(res.allHeaderFields),
                    spanBuilder: nil,
                    span: span
                )
                
                // remove http.status_code
                span.setAttribute(key: SemanticAttributes.httpStatusCode.rawValue, value: nil)
                // add http.response.status_code
                span.setAttribute(key: SemanticAttributes.httpResponseStatusCode.rawValue, value: res.statusCode)
                
                guard configuration?.shouldRecordResponseBody?(response) ?? true else {
                    return
                }
                
                guard let d = dataOrFile as? Data, let data = String(data: d, encoding: .utf8) else {
                    return
                }
                
                span.setAttribute(key: "http.response.body", value: data)
            }, receivedError: { error, dataOrFile, status, span in
                span.setAttribute(key: "http.response.error", value: "\(error)")
                span.setAttribute(key: SemanticAttributes.httpResponseStatusCode.rawValue, value: status)
            }, delegateClassesToInstrument: {
                return nil
            }()
        )
    }
    
    static func recordHeaders(configuarion: AliyunURLSessionInstrumentationConfiguration?, headers: [String: String]?, spanBuilder: SpanBuilder?, span: Span?) {
        guard let _ = headers else {
            return
        }
        
        let whiteList: [String] = configuarion?.headersInWhiteList ?? []
        let blackList: [String] = configuarion?.headersInBlackList ?? []
        
        
        for (k, v) in headers! {
            if "User-Agent" == k {
                if let builder = spanBuilder {
                    builder.setAttribute(key: SemanticAttributes.userAgentOriginal.rawValue, value: v)
                } else if let span = span {
                    span.setAttribute(key: SemanticAttributes.userAgentOriginal.rawValue, value: v)
                }
                
                continue
            }
            
            if blackList.count > 0, blackList.contains(k) {
                continue
            }
            
            if whiteList.count > 0, !whiteList.contains(k) {
                continue
            }
            
            if let builder = spanBuilder {
                builder.setAttribute(key: "http.request.header.\(k)", value: v)
            } else if let span = span {
                span.setAttribute(key: "http.response.header.\(k)", value: v)
            }
        }
    }
    
    static func converAllHeaders(_ src: [AnyHashable: Any]) -> [String: String] {
        var dest = [String: String]()
        for (k, v) in src {
            guard let key = k as? String else {
                continue
            }
            
            guard let value = v as? String else {
                continue
            }
            
            dest[key] = value
        }
        
        return dest
    }
}
//#endif
