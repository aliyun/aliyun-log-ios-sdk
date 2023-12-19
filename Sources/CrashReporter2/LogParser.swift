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
import CommonCrypto

let LINE_BLOCK_START: String = "Incident Identifier:"
let LINE_BLOCK_MODULE_START: String = ""

internal enum ParserState: Int {
    case notStart
    case start
    case blockStart
    case blockInProgress
    case idle
}

class BlockBuilder {
    let blockName: String
    var content: String
    
    init(blockName: String) {
        if blockName.hasPrefix("Memory Status(bytes):") {
            self.blockName = "mem_status"
        } else if blockName.hasPrefix("Exception Category:") {
            self.blockName = "exception_category"
        } else if blockName.hasPrefix("Thread ") && !blockName.hasSuffix("Thread State:") {
            self.blockName = "thread_list"
        } else if blockName.hasPrefix("Thread ") && blockName.hasSuffix("Thread State:") {
            self.blockName = "thread_state"
        } else if blockName.hasPrefix("Storage Status(bytes):") {
            self.blockName = "storage_status"
        } else if blockName.hasPrefix("Extra Information:") {
            self.blockName = "extra_information"
        } else {
            var name = blockName.trimmingCharacters(in: .whitespacesAndNewlines)
            if name.suffix(1) == ":" {
                name = String(name.prefix(name.count - 1))
            }
            name = name.replacingOccurrences(of: " ", with: "_")
            self.blockName = name.lowercased()
        }
        
        self.content = ""
    }
    
    func append(line: String) {
        content.append(line)
    }
    
    func pack() {
        // Perform any necessary operations before packing the content
    }
}


internal class LogParser {
    static let shared = LogParser()
    
    var state: ParserState = .notStart
    var preState: ParserState = .notStart
    var inThreadListParsing = false
    var inStacktraceParsing = false
    var errorReason: String? = ""
    var errorFramework: String?
    var stackBlockBuilder: BlockBuilder?
    var errorId: String?
    var type: String?
    
    private init() {
        
    }
    
    func parser(filePath: String) -> [String: String]? {
        guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return nil
        }
        
        let mainBundlePath = Bundle.main.bundlePath
        var frameworks = [String]()
        var path = (mainBundlePath as NSString).lastPathComponent
        frameworks.append(String(path.prefix(upTo: path.range(of: ".")!.lowerBound)))
        
        for bundle in Bundle.allFrameworks {
            if bundle.bundlePath.contains(mainBundlePath) {
                path = (bundle.bundlePath as NSString).lastPathComponent
                frameworks.append(String(path.prefix(upTo: path.range(of: ".")!.lowerBound)))
            }
        }
        
        let lines = content.components(separatedBy: CharacterSet.newlines)
        var blockBuilders = [BlockBuilder]()
        var blockBuilder: BlockBuilder?
        
        preState = .notStart
//        state = .notStart
        
        for line in lines {
            // debug statement
//            print("debugggg, line: \(line)")
            
            // begin header info parse
            if state == .notStart && line.hasPrefix(LINE_BLOCK_START) {
                state = .start
                blockBuilder = BlockBuilder(blockName: "basic_info")
                parserBasicBlock(blockBuilder: blockBuilder, line: line)
                continue
            }
            
            // new block will parse
            if line == LINE_BLOCK_MODULE_START {
                preState = state
                state = .blockStart
                continue
            }
            
            // check should begin new block parse
            let shouldPackBlock = checkState(line: line)
            if shouldPackBlock {
                if let builder = blockBuilder {
                    builder.pack()
                    blockBuilders.append(builder)
                    blockBuilder = nil
                }
            }
            
            // parse stack block
            if inStacktraceParsing {
                parserStacktraceBlock(builder: stackBlockBuilder, line: line, frameworks: frameworks)
            }
            
            if state == .start {
                parserBasicBlock(blockBuilder: blockBuilder, line: line)
                continue
            }
            
            if state == .blockStart {
                blockBuilder = BlockBuilder(blockName: line)
                parserBlock(blockBuilder: blockBuilder, line: line)
                
                state = .blockInProgress
                continue
            }
            
            if state == .blockInProgress {
                parserBlock(blockBuilder: blockBuilder, line: line)
                continue
            }
        }
        
        if let stackBlockBuilder = stackBlockBuilder {
            blockBuilders.append(stackBlockBuilder)
        }
        
        if let blockBuilder = blockBuilder {
            blockBuilders.append(blockBuilder)
        }
        
        var results = [String: String]()
        for block in blockBuilders {
            results[block.blockName] = block.content as String
            
            if block.blockName == "exception_category" {
                results["catId"] = md5(content: block.content)
            }
        }
        
        if let errorId = errorId {
            results["id"] = errorId
        }
        if let type = type {
            results["sub_type"] = type
        }
        
        if let errorFramework = errorFramework {
            var summary = [String: String]()
            summary["exception"] = type
            if let errorReason = errorReason {
                summary["reason"] = errorReason
            }
            summary["code"] = errorFramework
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: summary, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    results["summary"] = jsonString
                }
            }
        }
        
        return results
    }
    
    func parserBasicBlock(blockBuilder: BlockBuilder?, line: String) {
        blockBuilder?.append(line: line)
        blockBuilder?.append(line: "\n")
        
        if line.hasPrefix("Incident Identifier: ") {
            errorId = line.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func parserBlock(blockBuilder: BlockBuilder?, line: String) {
        blockBuilder?.append(line: line)
        blockBuilder?.append(line: "\n")
        
        if "exception_category" == blockBuilder?.blockName {
            if line.hasPrefix("Exception Type") {
                let array = line.components(separatedBy: ":")
                if array.count == 2 {
                    type = array[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if let t = type {
                        if t.contains("(") {
                            type = t.prefix(upTo: t.range(of: "(")!.lowerBound).trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
            }
        } else if "extra_information" == blockBuilder?.blockName {
            if line.hasPrefix("CrashDoctor Diagnosis:") || line.hasPrefix("Originated at") {
                errorReason?.append(line)
            }
        }
    }
    
    func checkState(line: String) -> Bool {
        if preState == .notStart {
            return false
        }
        
        if line.hasPrefix("Exception Category:") ||
           (line.hasPrefix("Thread ") && line.hasSuffix("Thread State:")) ||
           line.hasPrefix("Binary Images:") ||
           line.hasPrefix("Memory Status(bytes):") ||
           line.hasPrefix("Storage Status(bytes):") ||
           line.hasPrefix("Extra Information:") ||
           line.hasPrefix("User Action:       ") ||
           line.hasPrefix("User Info:       ") ||
           line.hasPrefix("Custom Crash Info:       ") {
            
            preState = .notStart
            return true
        }
        
        if line.hasPrefix("Thread ") && !line.hasSuffix("Thread State:") {
            let shouldPack: Bool
            if !inThreadListParsing {
                inThreadListParsing = true
                state = .blockStart
                preState = .notStart
                shouldPack = true
            } else {
                state = .blockInProgress
                preState = .notStart
                shouldPack = false
            }
            inStacktraceParsing = line.hasSuffix(" Crashed:")
            return shouldPack
        }
        
        state = .blockInProgress
        preState = .notStart
        return false
    }
    
    func parserStacktraceBlock(builder: BlockBuilder?, line: String, frameworks: [String]) {
        if stackBlockBuilder == nil {
            stackBlockBuilder = BlockBuilder(blockName: "stacktrace")
        }
        stackBlockBuilder?.append(line: line)
        stackBlockBuilder?.append(line: "\n")
        
        if errorFramework != nil {
            return
        }
        
        for framework in frameworks {
            if line.contains(framework) {
                errorFramework = framework
                break
            }
        }
    }
    
    func md5(content: String) -> String {
        let cChar = (content as NSString).utf8String
        var result = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(cChar, CC_LONG(strlen(cChar!)), &result)
        
        return result.reduce("", { $0 + String(format: "%02x", $1) })
    }
    
}
