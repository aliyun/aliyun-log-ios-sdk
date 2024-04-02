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

// MARK: - URLProtocol
class WKWebViewHtmlURLProtocol: URLProtocol {
    static var WKWebViewProtocolKey = "kOTelJSBridgeNSURLProtocolKey_1"

    var customTask : URLSessionDataTask?

    override class func canInit(with request: URLRequest) -> Bool {
        if let bool: Bool = URLProtocol.property(forKey: WKWebViewHtmlURLProtocol.WKWebViewProtocolKey, in: request) as? Bool, bool {
            return false
        }

        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }

    override func startLoading() {
        guard let mutableRequest = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }

        URLProtocol.setProperty(true, forKey: WKWebViewHtmlURLProtocol.WKWebViewProtocolKey, in: mutableRequest)

        // sync cookie
        var request = self.request as URLRequest
        WebViewCookieManager.syncRequestCookie(request: &request)

//        print("WKWebViewHtmlURLProtocol. method: \(request.httpMethod), url: \(request.url!), path: \(request.url!.path),cookie: \(request.value(forHTTPHeaderField: "Cookie") ?? "")")

        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        self.customTask = session.dataTask(with: request)
        self.customTask?.resume()
    }

    override func stopLoading() {
        if let _ = customTask {
            customTask!.cancel()
            customTask = nil
        }
    }
}

// MARK: - URLSessionDataDelegate for URLSession
extension WKWebViewHtmlURLProtocol : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
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

// MARK: - register & unregister
extension WKWebViewHtmlURLProtocol {
    static func register() {
        registerScheme(scheme: "http")
        registerScheme(scheme: "https")

        URLProtocol.registerClass(WKWebViewHtmlURLProtocol.self)
    }

    static func unregister() {
        unregisterScheme(scheme: "http")
        unregisterScheme(scheme: "https")

        URLProtocol.unregisterClass(WKWebViewHtmlURLProtocol.self)
    }
}

extension WKWebViewHtmlURLProtocol {
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
