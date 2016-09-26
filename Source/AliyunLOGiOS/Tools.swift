//
//  Tools.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/8/1.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation

extension Data{
    var LZ4:Data!{
        
        let raw_data_size = self.count
        let compress_bound = LZ4_compressBound(Int32(raw_data_size));
        let compress_data = Data.init(capacity: Int(compress_bound))
        let compressed_size = LZ4_compress((self as NSData).bytes.assumingMemoryBound(to: Int8.self),UnsafeMutablePointer<Int8>(mutating: (compress_data as NSData).bytes.assumingMemoryBound(to: Int8.self)),Int32(raw_data_size));
        
        return Data.init(bytes: (compress_data as NSData).bytes.assumingMemoryBound(to: Int8.self), count: Int(compressed_size))
        
        /*
        let raw_data = UnsafePointer<Int8>((self as NSData).bytes)
        let raw_data_size = self.count
        
        
        let compress_bound = LZ4_compressBound(Int32(raw_data_size));
        let compress_data = UnsafeMutablePointer<Int8>.init(allocatingCapacity: 1)
        compress_data.initialize(with:Int8(compress_bound))
        
        let compressed_size = LZ4_compress(raw_data,compress_data,Int32(raw_data_size));
        
        let output = NSData(bytes: compress_data, length: Int(compressed_size))
        
        compress_data.deinitialize()
        compress_data.deallocateCapacity(1)
        
        
        return output as Data
        */
    }
}

extension Date{
    var GMT:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0000")
        dateFormatter.locale = Locale(identifier: "en_US")
        var convertedDate = dateFormatter.string(from: self)
        convertedDate = convertedDate + " GMT"
        return convertedDate
    }
    
}

extension Data  {
    var md5: String! {
        let bytes = (self as NSData).bytes
        let strLen = CUnsignedInt(self.count)
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(bytes, strLen, result)
        
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02X", result[i])
        }
        result.deinitialize()
        return String(format: hash as String)
    }
}
