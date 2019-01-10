//
//  Tools.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/8/1.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation

extension Data{
    var GZip:Data!{
        if(self.count == 0){return nil}
        var zStream = z_stream(
            next_in: UnsafeMutablePointer<Bytef>(mutating: (self as NSData).bytes.bindMemory(to: Bytef.self, capacity: self.count)),
            avail_in: uint(self.count),
            total_in: 0,
            next_out: nil,
            avail_out: 0,
            total_out: 0,
            msg: nil,
            state: nil,
            zalloc: nil,
            zfree: nil,
            opaque: nil,
            data_type: 0,
            adler: 0,
            reserved: 0
        )
        var status = deflateInit2_(&zStream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15), 8, Z_DEFAULT_STRATEGY,ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        
        if (status != Z_OK) { return nil;}
        
        let bytes = UnsafeMutablePointer<Bytef>(mutating: (self as NSData).bytes.bindMemory(to: Bytef.self, capacity: self.count))
        zStream.next_in = bytes;
        zStream.avail_in = uInt(self.count);
        zStream.avail_out = 0;
        zStream.total_out = 0;
        
        let halfLen = self.count / 2;
        var output = Data(capacity:halfLen)
        
        while (zStream.avail_out == 0) {
            if Int(zStream.total_out) >= output.count {
                output.count += halfLen
            }
            output.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<Bytef>) in
                zStream.next_out = bytes.advanced(by: Int(zStream.total_out))
            })
            zStream.avail_out = uInt(output.count) - uInt(zStream.total_out)
            status = deflate(&zStream,Z_FINISH);
            
            if (status == Z_STREAM_END) {
                break;
            } else if (status != Z_OK) {
                deflateEnd(&zStream);
                return nil;
            }
        }
        output.count = Int(zStream.total_out)
//        bytes.deinitialize()
//        bytes.deallocate(capacity: self.count)
        deflateEnd(&zStream)
        return output as Data!;
    }
    var GUnZip:Data!{
        if(self.count == 0){return nil}
        var zStream = z_stream(
            next_in: UnsafeMutablePointer<Bytef>(mutating: (self as NSData).bytes.bindMemory(to: Bytef.self, capacity: self.count)),
            avail_in: uint(self.count),
            total_in: 0,
            next_out: nil,
            avail_out: 0,
            total_out: 0,
            msg: nil,
            state: nil,
            zalloc: nil,
            zfree: nil,
            opaque: nil,
            data_type: 0,
            adler: 0,
            reserved: 0
        )
        var status = inflateInit2_(&zStream, (15+32), ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        
        if (status != Z_OK) { return nil;}
        
        let bytes = UnsafeMutablePointer<Bytef>(mutating: (self as NSData).bytes.bindMemory(to: Bytef.self, capacity: self.count))
        zStream.next_in = bytes;
        zStream.avail_in = uInt(self.count);
        zStream.avail_out = 0;
        zStream.total_out = 0;
        
        let halfLen = self.count / 2;
        var output = Data(capacity:(halfLen+self.count))
        
        while zStream.avail_out == 0 {
            if Int(zStream.total_out) >= output.count {
                output.count += halfLen
            }
            output.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) in
                zStream.next_out = bytes.advanced(by: Int(zStream.total_out))
            }
            zStream.avail_out = uInt(output.count) - uInt(zStream.total_out)
            status = inflate(&zStream,Z_NO_FLUSH);
            
            if (status == Z_STREAM_END) {
                break;
            } else if (status != Z_OK) {
                inflateEnd(&zStream);
                return nil;
            }
        }
        output.count = Int(zStream.total_out)
//        bytes.deinitialize()
//        bytes.deallocate(capacity: self.count)
        inflateEnd(&zStream);
        return output as Data!;
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
        result.deallocate(capacity: digestLen)
        return String(format: hash as String)
    }
}
