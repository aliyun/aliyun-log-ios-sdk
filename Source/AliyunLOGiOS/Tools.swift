//
//  Tools.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/8/1.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
extension NSData{
    var GZip:NSData!{
        if(self.length == 0){return nil}
        var zStream = z_stream(
            next_in: UnsafeMutablePointer<Bytef>(self.bytes),
            avail_in: uint(self.length),
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
        var status = deflateInit2_(&zStream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15), 8, Z_DEFAULT_STRATEGY,ZLIB_VERSION, Int32(sizeof(z_stream)))
        
        if (status != Z_OK) { return nil;}
        
        let bytes = UnsafeMutablePointer<Bytef>(self.bytes)
        zStream.next_in = bytes;
        zStream.avail_in = uInt(self.length);
        zStream.avail_out = 0;
        zStream.total_out = 0;
        
        let halfLen = self.length / 2;
        let output = NSMutableData(length:halfLen)!
        
        while (zStream.avail_out == 0) {
            if (zStream.total_out >= uLong(output.length)) {
                output.increaseLengthBy(halfLen)
            }
            zStream.next_out = UnsafeMutablePointer<Bytef>(output.mutableBytes).advancedBy(Int(zStream.total_out))
            zStream.avail_out = uInt(output.length) - uInt(zStream.total_out)
            status = deflate(&zStream,Z_FINISH);
            
            if (status == Z_STREAM_END) {
                break;
            } else if (status != Z_OK) {
                deflateEnd(&zStream);
                return nil;
            }
        }
        output.length = Int(zStream.total_out)
        deflateEnd(&zStream);
        bytes.destroy()
        return output;
    }
    var GUnZip:NSData!{
        if(self.length == 0){return nil}
        var zStream = z_stream(
            next_in: UnsafeMutablePointer<Bytef>(self.bytes),
            avail_in: uint(self.length),
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
        var status = inflateInit2_(&zStream, (15+32), ZLIB_VERSION, Int32(sizeof(z_stream)))
        
        if (status != Z_OK) { return nil;}
        
        let bytes = UnsafeMutablePointer<Bytef>(self.bytes)
        zStream.next_in = bytes;
        zStream.avail_in = uInt(self.length);
        zStream.avail_out = 0;
        zStream.total_out = 0;
        
        let halfLen = self.length / 2;
        let output = NSMutableData(length:(halfLen+self.length))!
        
        while (zStream.avail_out == 0) {
            if (zStream.total_out >= uLong(output.length)) {
                output.increaseLengthBy(halfLen)
            }
            zStream.next_out = UnsafeMutablePointer<Bytef>(output.mutableBytes).advancedBy(Int(zStream.total_out))
            zStream.avail_out = uInt(output.length) - uInt(zStream.total_out)
            status = inflate(&zStream,Z_NO_FLUSH);
            
            if (status == Z_STREAM_END) {
                break;
            } else if (status != Z_OK) {
                inflateEnd(&zStream);
                return nil;
            }
        }
        output.length = Int(zStream.total_out)
        inflateEnd(&zStream);
        bytes.destroy()
        return output;
    }
}

extension NSDate{
    var GMT:String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0000")
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        var convertedDate = dateFormatter.stringFromDate(self)
        convertedDate = convertedDate + " GMT"
        return convertedDate
    }
    
}

extension NSData  {
    var md5: String! {
        let bytes = self.bytes
        let strLen = CUnsignedInt(self.length)
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(bytes, strLen, result)
        
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02X", result[i])
        }
        result.destroy()
        return String(format: hash as String)
    }
}