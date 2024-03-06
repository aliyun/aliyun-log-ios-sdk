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
import AliyunLogOTelCommon
import OpenTelemetryApi
import OpenTelemetrySdk

internal class CrashFileHelper {
    func scanAndReport(_ path: String) {
        parseCrashFile(path)
    }
    
    func parseCrashFile(_ path: String) {
        var isDirectory: ObjCBool = false
        if path.isEmpty || !FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            print("file path is empty or file is not exists.")
            return
        }
        
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            print("failed to get contents of directory: \(path)")
            return
        }
        
        for file in contents {
            let fullPath = (path as NSString).appendingPathComponent(file)
            parseCrashFileInternal(fullPath)
            
        }
    }
    
    func parseCrashFileInternal(_ filePath: String) {
        guard let results = LogParser.shared.parser(filePath: filePath) else { return }

        guard let catId = results["catId"],
              let errorId = results["id"],
              let subType = results["sub_type"] else { return }
        
        var mutableResults = results
        mutableResults.removeValue(forKey: "catId")
        mutableResults.removeValue(forKey: "id")
        mutableResults.removeValue(forKey: "sub_type")
        
        if let spanBuilder = CrashReporterOTel.spanBuilder("crashreporter") {
            for (key, value) in mutableResults {
                if "basic_info" == key || "summary" == key || "stacktrace" == key {
                    spanBuilder.setAttribute(key: "ex.\(key)", value: value)
                }
            }

            spanBuilder.setAttribute(key: "t", value: "error")
            spanBuilder.setAttribute(key: "ex.type", value: "crash")
            spanBuilder.setAttribute(key: "ex.sub_type", value: subType)
            spanBuilder.setAttribute(key: "ex.id", value: errorId)
            spanBuilder.setAttribute(key: "ex.catId", value: catId)

            AttributesHelper.setAttributes(spanBuilder)

            let span = spanBuilder.startSpan()
            span.end()
            CrashReporterOTel.forceFlush()

            _ = try? FileManager.default.removeItem(atPath: filePath)
        }
    }
    
    
}
