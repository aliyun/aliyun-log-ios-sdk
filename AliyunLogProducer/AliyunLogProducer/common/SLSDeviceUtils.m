//
//  SLSDeviceUtils.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/5/31.
//

#import "SLSDeviceUtils.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import "reachable/Rechable.h"

@interface SLSDeviceUtils ()
+ (NSString *) getNetworkType;
+ (NSString *) getReachabilityStatus;
@end

@implementation SLSDeviceUtils

+ (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";
    
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceModel;
}


+ (NSString *) isJailBreak
{
    //以下检测的过程是越往下，越狱越高级
    //获取越狱文件路径
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        return @"true";
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        return @"true";
    }
    
    //可能存在hook了NSFileManager方法，此处用底层C stat去检测
    struct stat stat_info;
    if (0 == stat("/Library/MobileSubstrate/MobileSubstrate.dylib", &stat_info)) {
        return @"true";
    }
    if (0 == stat("/Applications/Cydia.app", &stat_info)) {
        return @"true";
    }
    if (0 == stat("/var/lib/cydia/", &stat_info)) {
        return @"true";
    }
    if (0 == stat("/var/cache/apt", &stat_info)) {
        return @"true";
    }
    
    //可能存在stat也被hook了，可以看stat是不是出自系统库，有没有被攻击者换掉。这种情况出现的可能性很小
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char *,struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        //相等为0，不相等，肯定被攻击
        if (strcmp(dylib_info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib")) {
            return @"true";
        }
    }
    
    //通常，越狱机的输出结果会包含字符串：Library/MobileSubstrate/MobileSubstrate.dylib。
    //攻击者给MobileSubstrate改名，原理都是通过DYLD_INSERT_LIBRARIES注入动态库。那么可以检测当前程序运行的环境变量
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env != NULL) {
        return @"true";
    }
    
    return @"false";
}

+ (NSString *)getResolution {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    return [NSString stringWithFormat:@"%.0f*%.0f",size.height * scale, size.width * scale];
//    return NSStringFromCGSize(CGSizeMake(size.width * scale, size.height * scale));
}

+ (NSString *)getCarrier {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *carrierName;
    if(!carrier.isoCountryCode) {
        carrierName = @"无运营商";
    } else {
        carrierName = [carrier carrierName];
    }
    
    return carrierName;
}

+ (NSString *)getReachabilityStatus {
    Reachable *reachability = [Reachable reachabilityWithHostname:@"www.aliyun.com"];
    switch ([reachability currentReachabilityStatus]) {
        case NotReachable:
            return @"Unknown";
        case ReachableViaWiFi:
            return @"Wi-Fi";
            break;
        case ReachableViaWWAN:
            return @"WWAN";
            break;
        default:
            return @"";
    }
}

+ (NSString *)getNetworkType {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = networkInfo.currentRadioAccessTechnology;
    return currentStatus;
}

+ (NSString *)getNetworkTypeName {
    NSString *currentReachabilityStatus = [self getReachabilityStatus];
    if(![@"WWAN" isEqual:currentReachabilityStatus]) {
        return currentReachabilityStatus;
    }
    
    NSString *currentStatus = [self getNetworkType];

    if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"4G";
    }

    if (@available(iOS 14.1, *)) {
        if ([currentStatus isEqualToString:CTRadioAccessTechnologyNRNSA]
            || [currentStatus isEqualToString:CTRadioAccessTechnologyNR]) {
            return @"5G";
        }
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]
       || [currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]
       || [currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]
       || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
       || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
       || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
       || [currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return @"3G";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]
        || [currentStatus isEqualToString:CTRadioAccessTechnologyEdge]
        || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return @"2G";
    }
    
    return @"Unknown";
}

+ (NSString *)getNetworkSubTypeName {
    NSString *currentReachabilityStatus = [self getReachabilityStatus];
    if(![@"WWAN" isEqual:currentReachabilityStatus]) {
        return @"Unknown";
    }
    
    NSString *currentStatus = [self getNetworkType];
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
        return @"GPRS";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
        return @"EDGE";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        return @"WCDMA";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        return @"HSDPA";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        return @"HSUPA";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return @"CDMA1x";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        return @"EVDOv0";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        return @"EVDORevA";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        return @"EVDORevB";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return @"HRPD";
    }
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"LTE";
    }
    
    if (@available(iOS 14.1, *)) {
        if ([currentStatus isEqualToString:CTRadioAccessTechnologyNRNSA]) {
            return @"NRNSA";
        } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyNR]) {
            return @"NR";
        }
    }
    
    return @"Unknown";
}

@end
