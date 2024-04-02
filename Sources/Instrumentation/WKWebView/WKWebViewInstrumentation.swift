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
//import OpenTelemetryApi
import WebKit

// MARK: - WKWebView instrumentation -
public class WKWebViewInstrumentation : NSObject {
    public private(set) var webView: WKWebView
//    public private(set) var tracer: Tracer
    private var delegate: WKWebViewDelegate

//    @objc
    public init(webView: WKWebView, configuration: WKWebViewInstrumentationConfiguration) {
        self.webView = webView
//        self.tracer = OpenTelemetry.instance.tracerProvider.get(instrumentationName: "WKWebView", instrumentationVersion: "0.0.1")
        self.delegate = WKWebViewDelegate()
        super.init()
    }

//    @objc
    open func start() {
        self.hookJs()
        self.setup()
    }

//    @objc
    open func stop() {
        self.destroy()
    }

    open class func loadRequest(webView: WKWebView, request: inout URLRequest) {
        WebViewCookieManager.syncRequestCookie(request: &request)
        webView.load(request)
        // MARK: todo hook
    }

    private func hookJs() {
        let userScript = WKUserScript.init(source: hookajax,
                                           injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                                           forMainFrameOnly: false
        )

        webView.configuration.userContentController.removeScriptMessageHandler(forName: "OTelJSBridgeMessage")
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(self, name: "OTelJSBridgeMessage")
    }

    private func setup() {
        // sync HTTPCookieStorage to WKHTTPCookieStorage
        WebViewCookieManager.copyHTTPCookieStorageToWKHTTPCookieStorageOniOS11(webView: self.webView, completion: nil)

        // register URLProtocol
        WKWebViewHtmlURLProtocol.register()
        WKWebViewBodyCacheURLProtocol.register()

        // setup navigation & ui delegate
        self.webView.navigationDelegate = delegate
        self.webView.uiDelegate = delegate
//        self.webView.configuration.allowsInlineMediaPlayback = true
    }

    private func destroy() {
        WKWebViewHtmlURLProtocol.unregister()

        webView.configuration.userContentController.removeScriptMessageHandler(forName: "OTelJSBridgeMessage")
        webView.navigationDelegate = nil

        WKWebViewBodyCacheURLProtocol.unregister()
    }
}

// MARK: - WKScriptMessageHandler -
extension WKWebViewInstrumentation : WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // TODO: bridge support
        if (message.name == "OTelJSBridgeMessage") {
            let messageDictionary = (message.body as! NSDictionary) as! Dictionary<String, Any>
            let messageModule = JSBridgeMessageModule(dictionary: messageDictionary)
            WKWebViewInstrumentation.dispatchCallbackMessage(webView: webView, message: messageModule)
        }
    }
}

/// dispatch method call from js
extension WKWebViewInstrumentation {
    private static var dispatchQueue: OperationQueue {
        return OperationQueue()
    }

    private static var methodInvokeQueue: OperationQueue {
        return OperationQueue()
    }

    static func dispatchCallbackMessage(webView: WKWebView, message: JSBridgeMessageModule) {
        dispatchQueue.addOperation {
            WKWebViewInstrumentation.dispatchCallbackMessageInQueue(webView: webView, message: message)
        }
    }

    static func dispatchCallbackMessageInQueue(webView: WKWebView, message: JSBridgeMessageModule) {
        guard let module = message.module, let method = message.method else {
            message.callback?(nil)
            return
        }

//        print("WKWebViewInstrumentation. dispatchCallbackMessageInQueue, module: \(module), method: \(method)")

        var callback: ((_ response: [String: Any]?) -> ())? = nil
        if let callbackId = message.callbackId {
            callback = { response in
                let callbackResponse = JSBridgeMessageModule(messageType: .callback, data: response, callbackId: callbackId)
                WKWebViewInstrumentation.dispatchMessageResponse(webView: webView, responseModule: callbackResponse)
            }
        } else if let cbk = message.callback {
            callback = cbk
        }

        methodInvokeQueue.addOperation {
            switch method {
                case "cacheAJAXBody":
                    XMLBodyCacheRequest.shared.cacheAjaxBody(params: message.data!, callback: callback)
                case "setCookie":
                    WebViewCookieManager.shared.setCookie(params: message.data!, callback: callback)
                case "cookie":
                    WebViewCookieManager.shared.getCookie(params: message.data!, callback: callback)
                default:
                    print("WKWebViewInstrumentation. not support \(method)")
            }
        }
    }
}

/// response to js
extension WKWebViewInstrumentation {
    static func dispatchMessageResponse(webView: WKWebView, responseModule: JSBridgeMessageModule) {
        let message: [String: Any] = [
            "messageType": responseModule.messageType.rawValue as Any,
            "callbackId": responseModule.callbackId as Any,
            "eventName": responseModule.eventName as Any,
            "data": responseModule.data as Any
        ]

        self.evaluateJavaScriptFunction(data: message, webView: webView) { result, error in
            guard let e = error else {
                responseModule.callback?(nil)
                return
            }


            print("OTel WKWebView JSBridge error: \(e)")
        }
    }
}

extension WKWebViewInstrumentation {

    static func evaluateJavaScriptFunction(data: [String: Any], webView: WKWebView, completionHandler: @escaping (_ result: Any, _ error: Error?) -> ()) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            return
        }

        guard let dataString = String(data: jsonData, encoding: String.Encoding.utf8) else {
            return
        }

        var javaScriptString = dataString.replacingOccurrences(of: #"\\"#, with: #"\\\\"#)
        javaScriptString = javaScriptString.replacingOccurrences(of: #"\""#, with: #"\\\""#)
        javaScriptString = javaScriptString.replacingOccurrences(of: #"\'"#, with: #"\\\'"#)
        javaScriptString = javaScriptString.replacingOccurrences(of: #"\n"#, with: #"\\n"#)
        javaScriptString = javaScriptString.replacingOccurrences(of: #"\r"#, with: #"\\r"#)
        javaScriptString = javaScriptString.replacingOccurrences(of: #"\f"#, with: #"\\f"#)
        javaScriptString = javaScriptString.replacingOccurrences(of: #"\u2028"#, with: #"\\u2028"#)
        javaScriptString = javaScriptString.replacingOccurrences(of: #"\u2029"#, with: #"\\u2029"#)

        if (Thread.current.isMainThread) {
            WKWebViewInstrumentation.evaluateJavaScript(javaScriptString: javaScriptString, webView: webView, completionHandler: completionHandler)
        } else {
            DispatchQueue.main.sync {
                WKWebViewInstrumentation.evaluateJavaScript(javaScriptString: javaScriptString, webView: webView, completionHandler: completionHandler)
            }
        }
    }

    static func evaluateJavaScript(javaScriptString: String, webView: WKWebView, completionHandler: @escaping (_ result: Any, _ error: Error?) -> ()) {
        webView.evaluateJavaScript("window.OTelJSBridge._handleMessageFromNative('\(javaScriptString)')") { result, error in
            let _ = webView.title
            completionHandler(result as Any, error)
        }
    }
}

struct JSBridgeMessageModule {
    enum MessageType: String {
        case callback = "callback"
        case event = "event"
    }

    let messageType: MessageType
    let data: [String: Any]?
    let module: String?
    let method: String?
    let callbackId: String?
    let eventName: String?
    let callback: (([String: Any]?)->Void)?

    init(messageType: MessageType = .callback, data: [String: Any]?, callbackId: String?) {
        self.messageType = messageType
        self.data = data
        self.callbackId = callbackId
        self.module = nil
        self.method = nil
        self.eventName = nil
        self.callback = nil
    }

    init(dictionary: [String: Any]) {
        self.init(dictionary: dictionary, callback: nil)
    }

    init(dictionary: [String: Any], callback: (([String: Any]?) -> Void)?) {
        self.messageType = (dictionary["messageType"] as? String == "callback") ? .callback : .event
        self.data = dictionary["data"] as? [String: Any]
        self.module = dictionary["module"] as? String
        self.method = dictionary["method"] as? String
        self.callbackId = dictionary["callbackId"] as? String
        self.eventName = dictionary["eventName"] as? String
        self.callback = callback
    }
}

// https://stackoverflow.com/a/43056053/1760982
fileprivate final class ObjectAssociation<T: Any> {
    private let policy: objc_AssociationPolicy

    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }

    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}
