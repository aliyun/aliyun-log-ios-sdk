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

public class Utdid: NSObject {

    @objc
    public static var shared = Utdid()
    
    private override init() {
    }
    
    @objc
    public static func getUtdid() -> String {
        if let utdid = Storage.getUtdid(), !utdid.isEmpty {
            return utdid
        }
        
        let uuid = UUID().uuidString
        Storage.setUtdid(uuid)
        
        return uuid
    }

    @objc
    public static func setUtdid(_ utdid: String) {
        guard !utdid.isEmpty else {
            return
        }
        
        Storage.setUtdid(utdid)
    }

    
}

fileprivate class Storage {
    
    static func getFile() -> String {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        let slsRootDir = (libraryPath as NSString).appendingPathComponent("sls-ios")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: slsRootDir) {
            do {
                try fileManager.createDirectory(atPath: slsRootDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return ""
            }
        }
        return (slsRootDir as NSString).appendingPathComponent("files")
    }
    
    static func setUtdid(_ utdid: String) {
        let files = getFile()
        guard !files.isEmpty else {
            return
        }
        
        do {
            try utdid.write(toFile: files, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write utdid to file: \(error.localizedDescription)")
        }
    }

    static func getUtdid() -> String? {
        let files = getFile()
        guard !files.isEmpty, let content = try? String(contentsOfFile: files, encoding: .utf8) else {
            return nil
        }
        
        let lines = content.components(separatedBy: "\n")
        if let utdid = lines.first {
            return utdid
        }
        
        return nil
    }
}
