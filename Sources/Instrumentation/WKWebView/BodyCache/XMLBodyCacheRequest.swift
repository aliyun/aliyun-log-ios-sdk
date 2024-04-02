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

class XMLBodyCacheRequest {
    private static var cachedBody: [String: [String: Any]] = [String: [String: Any]]()
    private static var cachedBodyWriteLock: NSLock = NSLock()
    
    public static var shared: XMLBodyCacheRequest {
        let instance = XMLBodyCacheRequest()
        return instance
    }
    
    func cacheAjaxBody(params: [String: Any], callback: ((_ response: [String: Any]?) -> ())?) {
        guard let requestId: String = params["requestId"] as? String else {
            return
        }
        
        cacheBody(requestId: requestId, body: params)
        
        if let callback = callback {
            callback([
                "requestId": requestId,
                "requestUrl": params["requestUrl"] ?? ""
            ])
        }
    }
    
    func cacheBody(requestId: String, body: [String: Any]) {
        XMLBodyCacheRequest.writeLock()
        XMLBodyCacheRequest.cachedBody[requestId] = body
        XMLBodyCacheRequest.writeUnLock()
    }
    
    static func getRequestBody(requestId: String) -> [String: Any]? {
        return XMLBodyCacheRequest.cachedBody[requestId]
    }
    
    static func deleteRequestBody(requestId: String?) {
        guard let id = requestId else {
            return
        }
        
        XMLBodyCacheRequest.deleteBody(requestId: id)
    }
    
    static func deleteBody(requestId: String) {
        XMLBodyCacheRequest.writeLock()
        XMLBodyCacheRequest.cachedBody.removeValue(forKey: requestId)
        XMLBodyCacheRequest.writeUnLock()
    }
    
    fileprivate static func writeLock() {
        XMLBodyCacheRequest.cachedBodyWriteLock.lock()
    }
    
    fileprivate static func writeUnLock() {
        XMLBodyCacheRequest.cachedBodyWriteLock.unlock()
    }
}
