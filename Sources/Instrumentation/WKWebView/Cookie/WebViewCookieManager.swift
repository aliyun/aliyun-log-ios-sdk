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

class WebViewCookieManager {
    static var shared: WebViewCookieManager {
        let instance = WebViewCookieManager()
        return instance
    }
    
    private static let dateFormatter: DateFormatter = DateFormatter(timeZone: TimeZone(abbreviation: "UTC")!, dateFormat: "EEE, d MMM yyyy HH:mm:ss zzz")
    
    static func syncRequestCookie(request: inout URLRequest) {
        guard let url = request.url else {
            return
        }
        
        guard let cookies: [HTTPCookie] = HTTPCookieStorage.shared.cookies(for: url), cookies.count > 0 else {
            return
        }
        
        let requestHeader: [String: String] = HTTPCookie.requestHeaderFields(with: cookies)
        let cookie = requestHeader["Cookie"]
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
    }
    
    static func fixRequest(request: inout URLRequest) -> URLRequest {
        var fixedRequest: URLRequest = request
        
        if let _ = request.url, let cookies = HTTPCookieStorage.shared.cookies(for: request.url!), cookies.count > 0 {
            var cookieArray = [String]()
            for cookie in cookies {
                cookieArray.append("\(cookie.name)=\(cookie.value)")
            }
            fixedRequest.setValue(cookieArray.joined(separator: ";"), forHTTPHeaderField: "Cookie")
        }
        
        return fixedRequest
    }
}

// MARK: - Cookie sync between HTTPCookieStore and WKHTTPCookieStore
extension WebViewCookieManager {
    static func copyWKHTTPCookieStoreToHTTPCookieStore(webView: WKWebView, completion: (() -> ())?) {
        if #available(iOS 11.0, *) {
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            cookieStore.getAllCookies { cookies in
                if cookies.count == 0 {
                    completion?()
                    return
                }
                
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                    if let last = cookies.last, last.isEqual(cookie) {
                        completion?()
                        return
                    }
                }
            }
        }
    }
    
    static func copyHTTPCookieStorageToWKHTTPCookieStorageOniOS11(webView: WKWebView, completion: (()->Void)?) {
        if #available(iOS 11.0, *) {
            guard let cookies = HTTPCookieStorage.shared.cookies, cookies.count > 0 else {
                completion?()
                return
            }
            
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            for cookie in cookies {
                cookieStore.setCookie(cookie) {
                    if let c = cookies.last, c.isEqual(cookie) {
                        completion?()
                        return
                    }
                }
            }
        }
    }
}

// MARK: - Cookie setter & getter for WKScriptMessageHandler
extension WebViewCookieManager {
    func setCookie(params: [String: Any], callback: ((_ response: [String: Any]?) -> ())?) {
        guard let cookies = params["cookie"] as? String else {
            return
        }
        
        var properties = [HTTPCookiePropertyKey: Any]()
        let segments = cookies.components(separatedBy: ";")
        for (idx, sgmt) in segments.enumerated() {
            let trimmedSgmt = sgmt.trimmingCharacters(in: CharacterSet.whitespaces)
            let keyValues = trimmedSgmt.components(separatedBy: "=")

            if (keyValues.count == 2 && keyValues[0].count > 0){
                let key = keyValues[0].trimmingCharacters(in: CharacterSet.whitespaces)
                let value = keyValues[1].trimmingCharacters(in: CharacterSet.whitespaces)
                
                if (0 == idx) {
                    properties[HTTPCookiePropertyKey.name] = key
                    properties[HTTPCookiePropertyKey.value] = value
                } else if (key == "domain") {
                    properties[HTTPCookiePropertyKey.domain] = value
                } else if (key == "path") {
                    properties[HTTPCookiePropertyKey.path] = value
                } else if (key == "expires") {
                    properties[HTTPCookiePropertyKey.expires] = WebViewCookieManager.dateFormatter.date(from: value)
                }
            } else if (keyValues.count == 1 && keyValues[0].count > 0) {
                let key = keyValues[0].trimmingCharacters(in: CharacterSet.whitespaces)
                if (key == "Secure") {
                    properties[HTTPCookiePropertyKey.secure] = true
                }
            }
        }
        
        if (properties.count > 0) {
            if let cookieObject: HTTPCookie = HTTPCookie.init(properties: properties) {
                HTTPCookieStorage.shared.setCookie(cookieObject)
            }
        }
    }
    
    func getCookie(params: [String: Any], callback: ((_ response: [String: Any]?) -> ())?) {
        guard let url = params["url"] as? String else {
            callback?(["cookie": ""])
            return
        }
        
        guard let cookies: [HTTPCookie] = HTTPCookieStorage.shared.cookies(for: URL.init(string: url)!), cookies.count > 0 else {
            callback?(["cookie": ""])
            return
        }
        
        let header = HTTPCookie.requestHeaderFields(with: cookies)
        callback?([
            "cookie": header["Cookie"] ?? ""
        ])
    }
}

// MARK: - DateFormatter
fileprivate extension DateFormatter {
    convenience init(timeZone: TimeZone, dateFormat: String) {
        self.init()
        self.timeZone = timeZone
        self.dateFormat = dateFormat
    }
}
