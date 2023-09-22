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
#if canImport(AliyunLogCrashReporter.WPKMobiWrapper)
import AliyunLogCrashReporter.WPKMobiWrapper
#else
import WPKMobiWrapper
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
                .setAttribute(key: "net.access", value: DeviceUtils.getNetworkType())
                .startSpan()
                .end()
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
//                print("directory changed. \(path)")
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
