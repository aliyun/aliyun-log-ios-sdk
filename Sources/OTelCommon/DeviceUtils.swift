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
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class DeviceUtils: NSObject {
    
    @objc
    public static func getDeviceModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    @objc
    public static func getDeviceModel() -> String {
        let modelIdentifier = DeviceUtils.getDeviceModelIdentifier()
        switch modelIdentifier {
        case "iPhone3,1"   : return "iPhone 4"
        case "iPhone3,2"   : return "iPhone 4"
        case "iPhone3,3"   : return "iPhone 4"
        case "iPhone4,1"   : return "iPhone 4S"
        case "iPhone5,1"   : return "iPhone 5"
        case "iPhone5,2"   : return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3"   : return "iPhone 5c (GSM)"
        case "iPhone5,4"   : return "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1"   : return "iPhone 5s (GSM)"
        case "iPhone6,2"   : return "iPhone 5s (GSM+CDMA)"
        case "iPhone7,1"   : return "iPhone 6 Plus"
        case "iPhone7,2"   : return "iPhone 6"
        case "iPhone8,1"   : return "iPhone 6s"
        case "iPhone8,2"   : return "iPhone 6s Plus"
        case "iPhone8,4"   : return "iPhone SE"
        case "iPhone9,1"   : return "iPhone 7"
        case "iPhone9,2"   : return "iPhone 7 Plus"
        case "iPhone9,3"   : return "iPhone 7"
        case "iPhone9,4"   : return "iPhone 7 Plus"
        case "iPhone10,1"  : return "iPhone_8"
        case "iPhone10,4"  : return "iPhone_8"
        case "iPhone10,2"  : return "iPhone_8_Plus"
        case "iPhone10,5"  : return "iPhone_8_Plus"
        case "iPhone10,3"  : return "iPhone X"
        case "iPhone10,6"  : return "iPhone X"
        case "iPhone11,8"  : return "iPhone XR"
        case "iPhone11,2"  : return "iPhone XS"
        case "iPhone11,6"  : return "iPhone XS Max"
        case "iPhone11,4"  : return "iPhone XS Max"
        case "iPhone12,1"  : return "iPhone 11"
        case "iPhone12,3"  : return "iPhone 11 Pro"
        case "iPhone12,5"  : return "iPhone 11 Pro Max"
        case "iPhone12,8"  : return "iPhone SE2"
        case "iPhone13,1"  : return "iPhone 12 mini"
        case "iPhone13,2"  : return "iPhone 12"
        case "iPhone13,3"  : return "iPhone 12 Pro"
        case "iPhone13,4"  : return "iPhone 12 Pro Max"
        case "iPhone14,4"  : return "iPhone 13 mini"
        case "iPhone14,5"  : return "iPhone 13"
        case "iPhone14,2"  : return "iPhone 13 Pro"
        case "iPhone14,3"  : return "iPhone 13 Pro Max"
            
        case "iPod1,1"     : return "iPod Touch 1G"
        case "iPod2,1"     : return "iPod Touch 2G"
        case "iPod3,1"     : return "iPod Touch 3G"
        case "iPod4,1"     : return "iPod Touch 4G"
        case "iPod5,1"     : return "iPod Touch (5 Gen)"
        case "iPod7,1"     : return "iPod Touch (6 Gen)"
            
        case "iPad1,1"     : return "iPad"
        case "iPad1,2"     : return "iPad 3G"
        case "iPad2,1"     : return "iPad 2 (WiFi)"
        case "iPad2,2"     : return "iPad 2"
        case "iPad2,3"     : return "iPad 2 (CDMA)"
        case "iPad2,4"     : return "iPad 2"
        case "iPad3,1"     : return "iPad 3 (WiFi)"
        case "iPad3,2"     : return "iPad 3 (GSM+CDMA)"
        case "iPad3,3"     : return "iPad 3"
        case "iPad3,4"     : return "iPad 4 (WiFi)"
        case "iPad3,5"     : return "iPad 4"
        case "iPad3,6"     : return "iPad 4 (GSM+CDMA)"
        case "iPad6,11"    : return "iPad 5"
        case "iPad6,12"    : return "iPad 5"
        case "iPad7,5"     : return "iPad 6"
        case "iPad7,6"     : return "iPad 6"
        case "iPad7,11"    : return "iPad 7"
        case "iPad7,12"    : return "iPad 7"
        case "iPad11,6"    : return "iPad 8"
        case "iPad12,1"    : return "iPad 9"
        case "iPad12,2"    : return "iPad 9"
            
        case "iPad4,1"     : return "iPad Air (WiFi)"
        case "iPad4,2"     : return "iPad Air (Cellular)"
        case "iPad5,3"     : return "iPad Air 2"
        case "iPad5,4"     : return "iPad Air 2"
        case "iPad11,3"    : return "iPad Air 3"
        case "iPad11,4"    : return "iPad Air 3"
        case "iPad13,1"    : return "iPad Air 4"
        case "iPad13,2"    : return "iPad Air 4"
            
        case "iPad2,5"     : return "iPad Mini (WiFi)"
        case "iPad2,6"     : return "iPad Mini"
        case "iPad2,7"     : return "iPad Mini (GSM+CDMA)"
        case "iPad4,4"     : return "iPad Mini 2 (WiFi)"
        case "iPad4,5"     : return "iPad Mini 2 (Cellular)"
        case "iPad4,6"     : return "iPad Mini 2"
        case "iPad4,7"     : return "iPad Mini 3"
        case "iPad4,8"     : return "iPad Mini 3"
        case "iPad4,9"     : return "iPad Mini 3"
        case "iPad5,1"     : return "iPad Mini 4 (WiFi)"
        case "iPad5,2"     : return "iPad Mini 4 (LTE)"
        case "iPad11,1"    : return "iPad Mini 5"
        case "iPad11,2"    : return "iPad Mini 5"
        case "iPad14,1"    : return "iPad Mini 6"
        case "iPad14,2"    : return "iPad Mini 6"
            
        case "iPad6,3"     : return "iPad Pro 9.7"
        case "iPad6,4"     : return "iPad Pro 9.7"
        case "iPad7,3"     : return "iPad Pro 10.5"
        case "iPad7,4"     : return "iPad Pro 10.5"
        case "iPad8,1"     : return "iPad Pro 11"
        case "iPad8,2"     : return "iPad Pro 11"
        case "iPad8,3"     : return "iPad Pro 11"
        case "iPad8,4"     : return "iPad Pro 11"
        case "iPad8,9"     : return "iPad Pro 11 2"
        case "iPad8,10"    : return "iPad Pro 11 2"
        case "iPad13,4"    : return "iPad Pro 11 3"
        case "iPad13,5"    : return "iPad Pro 11 3"
        case "iPad13,6"    : return "iPad Pro 11 3"
        case "iPad13,7"    : return "iPad Pro 11 3"
        case "iPad6,7"     : return "iPad Pro 12.9"
        case "iPad6,8"     : return "iPad Pro 12.9"
        case "iPad7,1"     : return "iPad Pro 12.9 2"
        case "iPad7,2"     : return "iPad Pro 12.9 2"
        case "iPad8,5"     : return "iPad Pro 12.9 3"
        case "iPad8,6"     : return "iPad Pro 12.9 3"
        case "iPad8,7"     : return "iPad Pro 12.9 3"
        case "iPad8,8"     : return "iPad Pro 12.9 3"
        case "iPad8,11"    : return "iPad Pro 12.9 4"
        case "iPad8,12"    : return "iPad Pro 12.9 4"
        case "iPad13,8"    : return "iPad Pro 12.9 5"
        case "iPad13,9"    : return "iPad Pro 12.9 5"
        case "iPad13,10"   : return "iPad Pro 12.9 5"
        case "iPad13,11"   : return "iPad Pro 12.9 5"
            
        case "AppleTV1,1"  : return "Apple TV 1"
        case "AppleTV2,1"  : return "Apple TV 2"
        case "AppleTV3,1"  : return "Apple TV 3"
        case "AppleTV3,2"  : return "Apple TV 3"
        case "AppleTV5,3"  : return "Apple TV 4"
        case "AppleTV6,2"  : return "Apple TV 4K"
        case "AppleTV11,1" : return "Apple TV 4K 2"
            
        case "i386"        : return "Simulator"
        case "x86_64"      : return "Simulator"
            
        default: return modelIdentifier
        }
    }
    
    @objc
    public static func isJailBreak() -> Bool {
        // 获取越狱文件路径
        let cydiaPath = "/Applications/Cydia.app"
        let aptPath = "/private/var/lib/apt/"
        if FileManager.default.fileExists(atPath: cydiaPath) {
            return true
        }
        if FileManager.default.fileExists(atPath: aptPath) {
            return true
        }
        // 可能存在hook了NSFileManager方法，此处用底层C stat去检测
        var stat_info = stat()
        if stat("/Library/MobileSubstrate/MobileSubstrate.dylib", &stat_info) == 0 {
            return true
        }
        if stat("/Applications/Cydia.app", &stat_info) == 0 {
            return true
        }
        if stat("/var/lib/cydia/", &stat_info) == 0 {
            return true
        }
        if stat("/var/cache/apt", &stat_info) == 0 {
            return true
        }
        
        // 通常，越狱机的输出结果会包含字符串：Library/MobileSubstrate/MobileSubstrate.dylib。
        // 攻击者给MobileSubstrate改名，原理都是通过DYLD_INSERT_LIBRARIES注入动态库。那么可以检测当前程序运行的环境变量
        if let _ = getenv("DYLD_INSERT_LIBRARIES") {
            return true
        }
        
        return false
    }
    
    @objc
    public static func getResolution() -> String {
#if canImport(UIKit)
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        return "\((Int)(size.width * scale))x\((Int)(size.height * scale))"
#elseif canImport(AppKit)
        let screen = NSScreen.main
        let description = screen?.deviceDescription
        let size = (description?[NSDeviceSize] as? NSValue)?.sizeValue ?? CGSize.zero
        return "\((Int)(size.width))x\((Int)(size.height))"
#else
        return "0x0"
#endif
    }
    
    @objc
    public static func getCPUArch() -> String {
        var cpu = ""
        var size = MemoryLayout<cpu_type_t>.size
        var type: cpu_type_t = 0
        sysctlbyname("hw.cputype", &type, &size, nil, 0)
        size = MemoryLayout<cpu_subtype_t>.size
        var subtype: cpu_subtype_t = 0
        sysctlbyname("hw.cpusubtype", &subtype, &size, nil, 0)
        if type == CPU_TYPE_X86_64 {
            cpu = "x86_64"
        } else if type == CPU_TYPE_X86 {
            cpu = "x86"
        } else if type == CPU_TYPE_ARM {
            cpu = "ARM"
            switch subtype {
                case CPU_SUBTYPE_ARM_V6:
                    cpu += "v6"
                case CPU_SUBTYPE_ARM_V7:
                    cpu += "v7"
                case CPU_SUBTYPE_ARM_V8:
                    cpu += "v8"
                default:
                    break
            }
        } else if type == CPU_TYPE_ARM64 {
            cpu = "ARM64"
        }
        return cpu
    }

    
}
