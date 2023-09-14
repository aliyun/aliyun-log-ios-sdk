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
import WPKMobiWrapper

typealias DirectoryChangedBlock = (String) -> Void

open class CrashReporter: NSObject {
    private var crashFileHelper: CrashFileHelper?
    private var crashLogSource: DispatchSourceFileSystemObject?
    private var debuggable: Bool = false
    
    public override init() {
        crashFileHelper = CrashFileHelper()
    }
    
    @objc
    open func `init`(debuggable: Bool) -> CrashReporter {
        CrashReporterOTel().initOtel()
        let reporter = CrashReporter()
        reporter.observeDirectoryChanged()
        reporter.initWPKMobi()
        return reporter
    }
    
    private func observeDirectoryChanged() {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        
        let wpkLogpath = (libraryPath as NSString).appendingPathComponent(".WPKLog")
        guard checkAndCreateDirectory(dir: wpkLogpath) else { return }
        
        let crashLogPath = (wpkLogpath as NSString).appendingPathComponent("CrashLog")
        guard checkAndCreateDirectory(dir: crashLogPath) else { return }
        
        let crashStatLogPath = (wpkLogpath as NSString).appendingPathComponent("CrashStatLog")
        guard checkAndCreateDirectory(dir: crashStatLogPath) else { return }
        
        observeDirectory(&crashLogSource, path: crashLogPath) { [weak self] path in
            self?.crashFileHelper?.parseCrashFile(path)
        }
        
        // observeDirectory(_crashStatLogSource, crashStatLogPath, ^(NSString *path) {
        //     [self.crashFileHelper parseCrashFile: path];
        // });
        
        crashFileHelper?.scanAndReport(crashLogPath)
        
        if let builder = CrashReporterOTel.spanBuilder("app.start") {
            builder.setAttribute(key: "t", value: "pv")
                .startSpan()
                .end()
        }
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
                print("directory changed. \(path)")
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
