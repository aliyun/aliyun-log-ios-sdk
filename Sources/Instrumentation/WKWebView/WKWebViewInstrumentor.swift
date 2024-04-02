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

public class WKWebViewInstrumentor {
    public static func start(configuration: WKWebViewInstrumentationConfiguration) {
        let selectors = [
            #selector(WKWebView.load(_:))
        ]
        
        let classes = InstrumentationUtils.objc_getClassList()
        let selectorsCount = selectors.count
        DispatchQueue.concurrentPerform(iterations: classes.count) { iteration in
            let theClass: AnyClass = classes[iteration]
            guard theClass != Self.self else { return }
            var selectorFound = false
            var methodCount: UInt32 = 0
            guard let methodList = class_copyMethodList(theClass, &methodCount) else { return }
            defer { free(methodList) }
            
            for i in 0..<selectorsCount {
                for j in 0..<Int(methodCount) {
                    if method_getName(methodList[j]) == selectors[i] {
                        selectorFound = true
                        WKWebViewInstrumentor.injectIntoWKWebView(cls: theClass)
                        break
                    }
                }
                if selectorFound {
                    break
                }
            }
        }
    }
    
    static func injectIntoWKWebView(cls: AnyClass) {
        injectIntoLoadRequest(cls: cls)
    }
    
    static func injectIntoLoadRequest(cls: AnyClass) {
        let selector = #selector(WKWebView.load(_:))
        guard let original = class_getInstanceMethod(cls, selector) else { return }
        var originalIMP: IMP?
        let block: @convention(block) (Any, URLRequest) -> WKNavigation? = { object, request in
            if let webView = object as? WKWebView {
                if !(webView.holderObject is WKWebViewInstrumentation) {
                    let instrumentation = WKWebViewInstrumentation(webView: webView, configuration: WKWebViewInstrumentationConfiguration())
                    instrumentation.start()
                    webView.holderObject = instrumentation
                }
            }
            
            let castedIMP = unsafeBitCast(originalIMP, to: (@convention(c)(Any, Selector, URLRequest) -> WKNavigation?).self)
            return castedIMP(object, selector, request)
        }
        
        let swizzledIMP = imp_implementationWithBlock(unsafeBitCast(block, to: AnyObject.self))
        originalIMP = method_setImplementation(original, swizzledIMP)
    }
}


fileprivate extension WKWebView {
    private struct AssociateKeys {
        static var holderKey = "wkwebview_instrumentation_holder_key"
    }
    var holderObject: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &AssociateKeys.holderKey) as AnyObject
        }

        set {
            objc_setAssociatedObject(self, &AssociateKeys.holderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
