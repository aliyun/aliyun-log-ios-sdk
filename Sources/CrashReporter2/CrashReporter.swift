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
#if canImport(WPKMobiWrapper)
import WPKMobiWrapper
#else
import AliyunLogCrashReporter.WPKMobiWrapper
#endif

typealias DirectoryChangedBlock = (String) -> Void

open class CrashReporter: NSObject {
    @objc
    public static let shared: CrashReporter = CrashReporter()
    
    private let crashFileHelper: CrashFileHelper
    private var crashLogSource: DispatchSourceFileSystemObject?
    private var debuggable: Bool = false
    
    private override init() {
        crashFileHelper = CrashFileHelper()
    }
    
    @objc
    public func `init`(debuggable: Bool) {
        CrashReporterOTel().initOtel()
        observeDirectoryChanged()
        initWPKMobi()
        
        if let builder = CrashReporterOTel.spanBuilder("app.start") {
            builder.setAttribute(key: "t", value: "pv")
            
            AttributesHelper.setAttributes(builder)
            builder.startSpan().end()
        }
    }
    
    @objc
    public func addLog(_ log: String) {
        addLog(logs: ["content": log])
    }

    @objc
    public func addLog(logs: [String: String]) {
        if logs.count == 0 {
            return
        }

        if let builder = CrashReporterOTel.spanBuilder("log") {
            builder.setAttribute(key: "t", value: "log")

            for (k, v) in logs {
                builder.setAttribute(key: "log.\(k)", value: v)
            }

            AttributesHelper.setAttributes(builder)
            
            builder.startSpan().end()
        }
    }

    @objc
    public func reportException(_ error: NSException) {
        reportException(name: "exception", error: error, properties: nil)
    }

    @objc
    public func reportException(_ error: NSException, properties: [String: String]?) {
        reportException(name: "exception", error: error, properties: properties)
    }

    @objc
    public func reportException(name: String, error: NSException, properties: [String: String]?) {
        if let builder = CrashReporterOTel.spanBuilder("exception") {
            builder.setAttribute(key: "t", value: "exception")
                .setAttribute(key: "ex.name", value: name)
                .setAttribute(key: "ex.type", value: "\(error.name.rawValue)")
                .setAttribute(key: "ex.message", value: "\(error.reason ?? "")")
                .setAttribute(key: "ex.stacktrace", value: "\(error.callStackSymbols.joined(separator: "\n"))")

            if let properties = properties {
                for (k, v) in properties {
                    builder.setAttribute(key: "ex.\(k)", value: v)
                }
            }

            AttributesHelper.setAttributes(builder)
            builder.startSpan().end()
        }
    }

    private func observeDirectoryChanged() {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        
        let wpkLogpath = (libraryPath as NSString).appendingPathComponent(".WPKLog")
        guard checkAndCreateDirectory(dir: wpkLogpath) else { return }
        
        let crashLogPath = (wpkLogpath as NSString).appendingPathComponent("CrashLog")
        guard checkAndCreateDirectory(dir: crashLogPath) else { return }
        
        observeDirectory(&crashLogSource, path: crashLogPath) { path in
            CrashReporter.shared.crashFileHelper.parseCrashFile(path)
        }
        
        crashFileHelper.scanAndReport(crashLogPath)
    }
    
    private func initWPKMobi() {
        WPKMobiWrapper.`init`(true)
    }
    
    private func checkAndCreateDirectory(dir: String) -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dir) {
            print("\(dir) path not exists.")
            do {
                try fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                print("create directory \(dir) error.")
                return false
            }
        }
        return true
    }
    
    private func observeDirectory(_ _source: inout DispatchSourceFileSystemObject?, path: String, handler: @escaping DirectoryChangedBlock) {
        let dirURL = URL(fileURLWithPath: path)
        let fd = open(dirURL.path, O_EVTONLY)
        if fd < 0 {
            print("unable to open the path: \(dirURL.path)")
            return
        }
        
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .write, queue: DispatchQueue.global())
        source.setEventHandler {
            let type = source.data
            switch type {
            case .write:
                handler(path)
            default:
                break
            }
        }
        
        source.setCancelHandler {
            close(fd)
        }
        
        source.resume()
        _source = source
    }
}
