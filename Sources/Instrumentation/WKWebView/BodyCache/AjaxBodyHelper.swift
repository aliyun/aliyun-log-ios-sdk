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

class AjaxBodyHelper {
    
    static func setBodyRequest(bodyRequest: [String: Any], request: inout URLRequest) {
        guard let value = bodyRequest["value"] else {
            return
        }
        
        let bodyType = bodyRequest["bodyType"] as! String
        let formEnctype: String = bodyRequest["formEnctype"] as? String ?? ""
        
        var data: Data?
        if bodyType == "Blob"{
            data = AjaxBodyHelper.dataFromBase64(base64: value as! String)
        } else if bodyType == "ArrayBuffer" {
            data = AjaxBodyHelper.dataFromBase64(base64: value as! String)
        } else if bodyType == "FormData" {
            self.setFormData(value: value as! [String: Any], enctype: formEnctype, request: &request)
            return
        } else {
            if let value = value as? [String: Any] {
                data = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            } else if let value = value as? String {
                data = value.data(using: .utf8)
            } else {
                data = value as? Data
            }
        }
        request.httpBody = data
    }
    
    static func dataFromBase64(base64: String) -> Data {
        let components: [String] = base64.components(separatedBy: ",")
        let splitBase64: String
        if components.count == 2 {
            splitBase64 = components.last ?? ""
        } else {
            splitBase64 = base64
        }
        
        let paddedLength = splitBase64.count + (splitBase64.count % 4)
        let fixedBase64 = splitBase64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)
        return Data(base64Encoded: fixedBase64, options: .ignoreUnknownCharacters)!
    }
    
    static func setFormData(value: [String: Any], enctype: String, request: inout URLRequest) {
        guard let formData = value["formData"] as? [[Any]] else {
            return
        }

        let fileKeys = value["fileKeys"] as? [String]
        var params = [String: Any]()
        var fileDatas = [FileFormData]()
        
        
        for pair: [Any] in formData {
            if pair.count < 2 {
                continue
            }
            
            guard let key = pair[0] as? String else {
                continue
            }
            
            if let fileKeys = fileKeys, fileKeys.contains(key) {
                guard let fileJSON = pair[1] as? [String: Any] else {
                    continue
                }
                
                var fileName: String
                if let name = fileJSON["name"] as? String, name.count > 0 {
                    fileName = name
                } else {
                    fileName = key
                }
                
                var fileFormData = FileFormData(key: key, fileName: fileName)
                fileFormData.key = key
                fileFormData.size = (fileJSON["size"] as? NSNumber)?.intValue
                fileFormData.type = fileJSON["type"] as? String
                
                if let lastModified = fileJSON["lastModified"] as? NSNumber, lastModified.intValue > 0 {
                    fileFormData.lastModified = lastModified.intValue
                }
                
                if "multipart/form-data" == enctype, let d = fileJSON["data"] as? String {
                    fileFormData.data =  self.dataFromBase64(base64: d)
                    fileDatas.append(fileFormData)
                } else {
                    params[key] = fileFormData.fileName
                }
            } else {
                params[key] = pair[1]
            }
        }
        
        if "multipart/form-data" == enctype {
            URLRequestSerialization.shared.multipartFormRequestWithRequest(request: &request, params: params) { formData in
                for fileData in fileDatas {
                    formData.appendPart(data: fileData.data ?? Data(), name: fileData.key, fileName: fileData.fileName, mimeType: fileData.type ?? "")
                }
            }
        } else if "text/plain" == enctype {
            var string = String()
            let keys = Array(params.keys)
            let last = keys.last
            for key in keys {
                string.append("\(URLRequestSerialization.percentEscapedString(from: key as NSString))=\(URLRequestSerialization.percentEscapedString(from: params[key] as! NSString))")
                if key != last {
                    string.append("\r\n")
                }
                
            }
            let data = string.data(using: .utf8)
            request.httpBody = data
        } else {
            // application/x-www-form-urlencoded
            var string = String()
            let keys = Array(params.keys)
            let last = keys.last
            for key in keys {
                string.append("\(URLRequestSerialization.percentEscapedString(from: key as NSString))=\(URLRequestSerialization.percentEscapedString(from: params[key] as! NSString))")
                if key != last {
                    string.append("&")
                }
                
            }
            let data = string.data(using: .utf8)
            request.httpBody = data
        }
    }
}
