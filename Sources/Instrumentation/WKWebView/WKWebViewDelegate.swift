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

// MARK: WKNavigationDelegate & WKUIDelegate
class WKWebViewDelegate: NSObject, WKNavigationDelegate {

    // MARK: - WKNavigationDelegate
    // before send request
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if var request = navigationAction.request as? URLRequest {
            WebViewCookieManager.syncRequestCookie(request: &request)
        }

        decisionHandler(.allow)
    }

    // after receive response
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if #available(iOS 11.0, *) {
            // sync WKWebView cookie to HTTPCookieStore
            WebViewCookieManager.copyWKHTTPCookieStoreToHTTPCookieStore(webView: webView, completion: nil)
        } else {
            // sync response 'Set-Cookie' from WKWebView to HTTPCookieStorage
            if let response = navigationResponse.response as? HTTPURLResponse,
               let url = response.url,
               let allHeaderFields = response.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: url)
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }

        decisionHandler(.allow)
    }

    // after page jump
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // ignored
    }

    // for authentication
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // ignored
        completionHandler(.performDefaultHandling, nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WKWebViewNavigationDelegate: \(error)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WKWebViewNavigationDelegate: \(error)")
    }
}

// MARK: - WKUIDelegate
extension WKWebViewDelegate: WKUIDelegate {
    // create a new webview
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let bool = navigationAction.targetFrame?.isMainFrame, !bool else {
            return nil
        }

        // sync cookie with '<a target="_blank" href="">' tag
        var request = navigationAction.request
        webView.load(WebViewCookieManager.fixRequest(request: &request))

        return nil
    }

//    // alert panel
//    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//
//    }
//
//    // confirm panel
//    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
//
//    }

    // input panel
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {

        if self.handleSyncCallWithPrompt(webView: webView, prompt: prompt, defaultText: defaultText, completionHandler: completionHandler) {
            return
        }
    }


//    fileprivate func canShowPanelWithWebView(webView: WKWebView) -> Bool {
//        if let delegate = webView.holderObject as? WKWebViewNavigationDelegate {
//
//        }
//    }
}

// MARK: - handle sync call with
extension WKWebViewDelegate {
    func handleSyncCallWithPrompt(webView: WKWebView, prompt: String, defaultText: String?, completionHandler: @escaping (String?) -> Void) -> Bool {
        if prompt != "OTelJSBridge" {
            return false
        }

        guard let defaultText = defaultText else {
            completionHandler(nil)
            return false
        }

        guard let jsonData = defaultText.data(using: .utf8), let body = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            completionHandler(nil)
            return false
        }

        let bridgeMessage = JSBridgeMessageModule(dictionary: body) { response in
            guard let response = response, response.count > 0 else {
                completionHandler(nil)
                return
            }

            guard let data = try? JSONSerialization.data(withJSONObject: response) else {
                completionHandler(nil)
                return
            }

            guard let jsonString = String.init(data: data, encoding: .utf8) else {
                completionHandler(nil)
                return
            }

            completionHandler(jsonString)

        }

        WKWebViewInstrumentation.dispatchCallbackMessage(webView: webView, message: bridgeMessage)
        return true
    }
}

fileprivate extension WKWebView {
    private struct AssociateKeys {
        static var canShowPanelWithWebView = "canShowPanelWithWebView"
    }
    var holderObject: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.canShowPanelWithWebView) as AnyObject
        }

        set {
            objc_setAssociatedObject(self, &AssociateKeys.canShowPanelWithWebView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
