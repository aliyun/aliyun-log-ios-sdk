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
import WebKit

// MARK: - URLProtocol for cache XHR request body
// MARK: - register & unregister
class WKWebViewBodyCacheURLProtocol : URLProtocol {
    static var WKWebViewProtocolKey = "kOTelJSBridgeNSURLProtocolKey"
    static var WKWebViewBridgeRequestId = "OTelJSBridge-RequestId"

    var requestId: String?
    var requestMethod: String?

    var customTask : URLSessionDataTask?

    static func register() {
        self.registerScheme(scheme: "http")
        self.registerScheme(scheme: "https")

        URLProtocol.registerClass(WKWebViewBodyCacheURLProtocol.self)
    }

    static func unregister() {
        self.unregisterScheme(scheme: "http")
        self.unregisterScheme(scheme: "https")

        URLProtocol.unregisterClass(WKWebViewBodyCacheURLProtocol.self)
    }
}

// MARK: - URLProtocol implementation
extension WKWebViewBodyCacheURLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        if let bool: Bool = URLProtocol.property(forKey: WKWebViewProtocolKey, in: request) as? Bool, bool {
            return false
        }

        if let host = request.url?.absoluteString, host.contains(WKWebViewBridgeRequestId) {
            return true
        }

        return false
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
}

// MARK: - loading url
extension WKWebViewBodyCacheURLProtocol {
    override func startLoading() {
        guard let mutableRequest = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }

        // set a flag to prevent loop
        URLProtocol.setProperty(true, forKey: WKWebViewBodyCacheURLProtocol.WKWebViewProtocolKey, in: mutableRequest)

        var requestId: String?
        if let absoluteUrl = mutableRequest.url?.absoluteString, absoluteUrl.contains(WKWebViewBodyCacheURLProtocol.WKWebViewBridgeRequestId) {
            requestId = self.fetchRequestId(url: absoluteUrl)
            if let requestIdPair = self.fetchRequestIdPair(url: absoluteUrl) {
                // remove requestId pair before send url request
                mutableRequest.url = URL.init(string: absoluteUrl.replacingOccurrences(of: requestIdPair, with: ""))
            }
        }

        self.requestId = requestId
        self.requestMethod = mutableRequest.httpMethod

        // sync cookie
        var request = mutableRequest as URLRequest
        WebViewCookieManager.syncRequestCookie(request: &request)

        // set http body
        if let requestId = requestId, let httpMethod = request.httpMethod, httpMethod.count > 0 {
            let methods = ["GET"]
            if !methods.contains(httpMethod) {
                if let bodyRequest = XMLBodyCacheRequest.getRequestBody(requestId: requestId) {
                    AjaxBodyHelper.setBodyRequest(bodyRequest: bodyRequest, request: &request)
                }
            }
        }

        // TODO: 外部代理

//        print("WKWebViewBodyCacheURLProtocol. method: \(request.httpMethod!), url: \(request.url!), path: \(request.url!.path), headers: \(request.allHTTPHeaderFields!)")

        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        self.customTask = session.dataTask(with: request)
        self.customTask?.resume()
    }

    override func stopLoading() {
        if let _ = customTask {
            customTask!.cancel()
            customTask = nil
        }

        self.clearRequestBody()
    }

    func clearRequestBody() {
        /**
         参考
         全部的 method
         http://www.iana.org/assignments/http-methods/http-methods.xhtml
         https://stackoverflow.com/questions/41411152/how-many-http-verbs-are-there

         Http 1.1
         https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Methods

         HTTP Extensions WebDAV
         http://www.webdav.org/specs/rfc4918.html#http.methods.for.distributed.authoring
         */

        // 清除缓存
        // 针对有 body 的 method，才需要清除 body 缓存
        let methods = ["POST", "PUT", "DELETE", "PATCH", "LOCK", "PROPFIND", "PROPPATCH", "SEARCH"]
        if let requestMethod = requestMethod, requestMethod.count > 0, methods.contains(requestMethod) {
            XMLBodyCacheRequest.deleteRequestBody(requestId: self.requestId)
        }
    }
}

extension WKWebViewBodyCacheURLProtocol {
    static let URL_REQUEST_ID_REGEX = "^.*?[&|\\?|%3f]?OTelJSBridge-RequestId[=|%3d](\\d+).*?$"
    static let URL_REQUEST_ID_PAIR_REGEX = "^.*?([&|\\?|%3f]?OTelJSBridge-RequestId[=|%3d]\\d+).*?$"

    func fetchRequestId(url: String) -> String? {
        return self.getMatchedTextFromUrl(url: url, regex: WKWebViewBodyCacheURLProtocol.URL_REQUEST_ID_REGEX)
    }

    func fetchRequestIdPair(url: String) -> String? {
        return self.getMatchedTextFromUrl(url: url, regex: WKWebViewBodyCacheURLProtocol.URL_REQUEST_ID_PAIR_REGEX)
    }

    func getMatchedTextFromUrl(url: String, regex: String) -> String? {
        do {
            let regexExpression = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive)
            var content: String?
            let matches = regexExpression.matches(in: url, range: NSMakeRange(0, url.count))
            for match in matches {
                for i in 0...match.numberOfRanges {
                    content = (url as NSString).substring(with: match.range(at: i))
                    if (1 == i) {
                        return content
                    }
                }
            }

            return content

        } catch  {
            print("WKWebViewInstrumentation. WKWebViewBodyCacheURLProtocol.getMatchedTextFromUrl() error: \(error)")
        }

        return nil
    }
}

// MARK: - URLSessionDataDelegate
extension WKWebViewBodyCacheURLProtocol : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.clearRequestBody()

        if let e = error {
            self.client?.urlProtocol(self, didFailWithError: e)
        } else {
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }


    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }
}

// MARK: - register scheme with browsingContextController for custom protocol
extension WKWebViewBodyCacheURLProtocol {
    // encode with base64 for protection
    private static var registerString: String {
        return String(data: Data(base64Encoded: "cmVnaXN0ZXJTY2hlbWVGb3JDdXN0b21Qcm90b2NvbDo=")!, encoding: .utf8)!
    }

    // encode with base64 for protection
    private static var unregisterString: String {
        return String(data: Data(base64Encoded: "dW5yZWdpc3RlclNjaGVtZUZvckN1c3RvbVByb3RvY29sOg==")!, encoding: .utf8)!
    }

    // encode with base64 for protection
    private static var controllerString: String {
        return String(data: Data(base64Encoded: "YnJvd3NpbmdDb250ZXh0Q29udHJvbGxlcg==")!, encoding: .utf8)!
    }

    private static var browsingContextController : NSObject.Type? {
        guard let instance = WKWebView().value(forKey: controllerString) else {
            return nil
        }
        return type(of: instance) as? NSObject.Type
    }

    private static var registerSchemeForCustomProtocol : Selector {
        return Selector((registerString))
    }

    private static var unregisterSchemeForCustomProtocol : Selector {
        return Selector((unregisterString))
    }

    static func registerScheme(scheme: String) {
        guard let controller = browsingContextController else {
            return
        }

        if (controller.responds(to: registerSchemeForCustomProtocol)) {
            controller.perform(registerSchemeForCustomProtocol, with: scheme)
        }
    }

    static func unregisterScheme(scheme: String) {
        guard let controller = browsingContextController else {
            return
        }

        if (controller.responds(to: unregisterSchemeForCustomProtocol)) {
            controller.perform(unregisterSchemeForCustomProtocol, with: scheme)
        }
    }
}
