//
//  LOGClient.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/29.
//  Copyright © 2016年 wangjwchn. All rights reserved.
//

import Foundation
public class LOGClient:NSObject{
    private var mEndPoint:String
    private var mAccessKeyID:String
    private var mAccessKeySecret:String
    private var mProject:String
    private var mAccessToken:String?
    public init(endPoint:String,accessKeyID:String,accessKeySecret :String,projectName:String) throws{
        
        guard endPoint != "" else{
            throw LogError.NullEndPoint
        }
        if( endPoint.rangeOfString("http://") != nil ||
            endPoint.rangeOfString("Http://") != nil ||
            endPoint.rangeOfString("HTTP://") != nil){
            mEndPoint = endPoint.substringFromIndex(endPoint.startIndex.advancedBy(7))
        }
        else if( endPoint.rangeOfString("https://") != nil ||
            endPoint.rangeOfString("Https://") != nil ||
            endPoint.rangeOfString("HTTPS://") != nil){
            mEndPoint = endPoint.substringFromIndex(endPoint.startIndex.advancedBy(8))
        }
        else{
            mEndPoint = endPoint
        }
        
        guard accessKeyID != "" else{
            throw LogError.NullAKID
        }
        mAccessKeyID = accessKeyID
        
        guard accessKeySecret != "" else{
            throw LogError.NullAKSecret
        }
        mAccessKeySecret = accessKeySecret
        
        guard projectName != "" else{
            throw LogError.NullProjectName
        }
        mProject = projectName
        
    }
    public func SetToken(token:String)throws{
        guard token != "" else{
            throw LogError.NullToken
        }
        mAccessToken = token
    }
    public func GetToken() -> String?{
        return mAccessToken
    }
    public func GetEndPoint() -> String{
        return mEndPoint
    }
    public func GetKeyID() -> String{
        return mAccessKeyID
    }
    public func GetKeySecret() ->String{
        return mAccessKeySecret
    }
    public func PostLog(logGroup:LogGroup,logStoreName:String, call: (NSURLResponse?, NSError?) -> ()){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let httpUrl = "http://\(self.mProject).\(self.mEndPoint)"+"/logstores/\(logStoreName)/shards/lb"
            
            let httpPostBody = logGroup.GetJsonPackage().dataUsingEncoding(NSUTF8StringEncoding)!
            let httpPostBodyZipped = httpPostBody.GZip!
            
            let httpHeaders = self.GetHttpHeadersFrom(logStoreName,url: httpUrl,body: httpPostBody,bodyZipped: httpPostBodyZipped)
            
            self.HttpPostRequest(httpUrl,headers: httpHeaders,body: httpPostBodyZipped, callBack:call)
            
        })
        
    }
    
    private func GetHttpHeadersFrom(logstore:String,url:String,body:NSData,bodyZipped:NSData) -> [String:String]{
        var headers = [String:String]()
        
        headers["x-log-apiversion"] = "0.6.0"
        headers["x-log-signaturemethod"] = "hmac-sha1"
        headers["Content-Type"] = "application/json"
        headers["Date"] = NSDate().GMT
        headers["Content-MD5"] = bodyZipped.md5
        headers["Content-Length"] = "\(bodyZipped.length)"
        headers["x-log-bodyrawsize"] = "\(body.length)"
        headers["x-log-compresstype"] = "deflate"
        headers["Host"] = self.getHostIn(url)
        
        
        var signString = "POST"+"\n"
        signString += headers["Content-MD5"]! + "\n"
        signString += headers["Content-Type"]! + "\n"
        signString += headers["Date"]! + "\n"
        
        if(mAccessToken != nil)
        {
            headers["x-acs-security-token"] = mAccessToken!
            signString += "x-acs-security-token:\(headers["x-acs-security-token"]!)\n"
        }
        
        signString += "x-log-apiversion:0.6.0\n"
        signString += "x-log-bodyrawsize:\(headers["x-log-bodyrawsize"]!)\n"
        signString += "x-log-compresstype:deflate\n"
        signString += "x-log-signaturemethod:hmac-sha1\n"
        signString += "/logstores/\(logstore)/shards/lb"
        let sign  =  hmac_sha1(signString, key: mAccessKeySecret)
        
        headers["Authorization"] = "LOG \(mAccessKeyID):\(sign)"
        return headers
    }
    
    private func HttpPostRequest(url:String,headers:[String:String],body:NSData, callBack: (NSURLResponse?, NSError?) -> ()){
        
        let NSurl: NSURL = NSURL(string: url)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSurl)
        request.HTTPMethod = "POST"
        request.timeoutInterval = 60
        request.HTTPBody=body
        request.HTTPShouldHandleCookies=false
        
        for (key, val) in headers {
            request.setValue(val, forHTTPHeaderField: key)
        }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            callBack(response, error)
            })
        
        task.resume()
        
    }
    private func hmac_sha1(text:String, key:String)->String {
        
        let keydata =  key.dataUsingEncoding(NSUTF8StringEncoding)!
        let keybytes = keydata.bytes
        let keylen = keydata.length
        
        let textdata = text.dataUsingEncoding(NSUTF8StringEncoding)!
        let textbytes = textdata.bytes
        let textlen = textdata.length
        
        let resultlen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(resultlen)
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keybytes, keylen, textbytes, textlen, result)
        
        let resultData = NSData(bytes: result, length: resultlen)
        let base64String = resultData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        result.destroy()
        return base64String
    }
    private func getHostIn(url:String)->String {
        var host = url
        if let idx = url.rangeOfString("://") {
            host = host.substringFromIndex(idx.startIndex.advancedBy(3))
        }
        if let idx = host.rangeOfString("/") {
            host = host.substringToIndex(idx.startIndex)
        }
        return host;
    }
}

