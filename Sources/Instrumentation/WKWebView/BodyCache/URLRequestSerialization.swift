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

class URLRequestSerialization {
    
    private static let CharactersGeneralDelimitersToEncode = ":#[]@"
    private static let CharactersSubDelimitersToEncode = "!$&'()*+,;="
    private static let batchSize = 50
    
    static var shared: URLRequestSerialization {
        let instance = URLRequestSerialization()
        return instance
    }
    
    func multipartFormRequestWithRequest(request: inout URLRequest, params: [String: Any], callback: ((_ formData: MultipartFormData) -> ())?) {
        guard let method = request.httpMethod, method != "GET", method != "HEAD" else {
            return
        }
        
        var formData = StreamingMultipartFormData(urlRequest: request, stringEncoding: String.Encoding.utf8)
        
        for pair in URLRequestSerialization.queryStringPairsFromDictionary(dictionary: params) {
            var data: Data?
            if let value = pair.value as? Data {
                data = value
            } else if let _ = pair.value as? NSNull {
                data = Data()
            } else {
                data = "\(pair.value ?? "")".data(using: String.Encoding.utf8)
            }
            
            if let d = data {
                formData.appendPart(data: d, name: "\(pair.field ?? "")")
            }
        }
        
        callback?(formData)
        
        request = formData.requestByFinalizingMultipartFormData()
    }
    
    static func queryStringPairsFromDictionary(dictionary: [String: Any]) -> [QueryStringPairModule] {
        return self.queryStringParisFromKeyAndValue(key: nil, value: dictionary)
    }

    static func queryStringParisFromKeyAndValue(key: String?, value: Any) ->[QueryStringPairModule] {
        var queryStringComponents = [QueryStringPairModule]()
//        let sortDescriptor = NSSortDescriptor.init(key: "description", ascending: true, selector: Selector("compare:"))
        let sortDescriptor = NSSortDescriptor.init(key: "description", ascending: true, selector: #selector(NSString.compare(_:)))
        
        if let vlu = value as? NSDictionary {
            let keys = vlu.allKeys as NSArray
            
            for k in keys.sortedArray(using: [sortDescriptor]) {
                if let value = vlu[k] {
                    var kk: String
                    if let _ = key {
                        kk = "\(key!)\(k)"
                    } else {
                        kk = "\(k)"
                    }
                    queryStringComponents.append(contentsOf: self.queryStringParisFromKeyAndValue(key: kk, value: value))
                }
            }
        } else if let vlu = value as? NSArray {
            for v in vlu {
                queryStringComponents.append(contentsOf: self.queryStringParisFromKeyAndValue(key: "\(key ?? "")", value: v))
            }
            
        } else if let vlu = value as? NSSet {
            for v in vlu.sortedArray(using: [sortDescriptor]) {
                queryStringComponents.append(contentsOf: self.queryStringParisFromKeyAndValue(key: key, value: v))
            }
        } else {
            queryStringComponents.append(QueryStringPairModule(field: key, value: value))
        }
        
        return queryStringComponents
    }
    
    static func percentEscapedString(from: NSString) -> String {
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: self.CharactersGeneralDelimitersToEncode.appending(self.CharactersSubDelimitersToEncode))
     
        var index = 0
        var escaped = ""
        
        while index < from.length {
            let length: UInt = UInt(min(from.length - index, self.batchSize))
            var range: NSRange = NSMakeRange(index, Int(length))
            range = from.rangeOfComposedCharacterSequences(for: range)
            
            let subString: NSString = from.substring(with: range) as NSString
            let encoded = subString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
            escaped.append(encoded!)
            
            index += range.length
        }
        
        return escaped
    }
}

struct QueryStringPairModule {
    var field: Any?
    var value: Any?
    
    init(field: Any?, value: Any) {
        self.field = field
        self.value = value
    }
    
    func urlEncodedStringValue() -> String {
        guard let value = value, let field = field else {
            return URLRequestSerialization.percentEscapedString(from: field as! NSString)
        }

        return "\(URLRequestSerialization.percentEscapedString(from: field as! NSString))=\(URLRequestSerialization.percentEscapedString(from: value as! NSString))"
    }
    

}
