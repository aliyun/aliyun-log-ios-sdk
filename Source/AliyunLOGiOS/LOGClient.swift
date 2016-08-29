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
    private var mAccessToken:String
    private var mExpireDate:Date
    public init(endPoint:String,accessKeyID:String,accessKeySecret :String,projectName:String) throws{
        
        guard endPoint != "" else{
            throw LogError.nullEndPoint
        }
        if( endPoint.range(of: "http://") != nil ||
            endPoint.range(of: "Http://") != nil ||
            endPoint.range(of: "HTTP://") != nil){
            mEndPoint = endPoint.substring(from: endPoint.characters.index(endPoint.startIndex, offsetBy: 7))
        }
        else if( endPoint.range(of: "https://") != nil ||
            endPoint.range(of: "Https://") != nil ||
            endPoint.range(of: "HTTPS://") != nil){
            mEndPoint = endPoint.substring(from: endPoint.characters.index(endPoint.startIndex, offsetBy: 8))
        }
        else{
            mEndPoint = endPoint
        }
        
        guard accessKeyID != "" else{
            throw LogError.nullAKID
        }
        mAccessKeyID = accessKeyID
        
        guard accessKeySecret != "" else{
            throw LogError.nullAKSecret
        }
        mAccessKeySecret = accessKeySecret
        
        guard projectName != "" else{
            throw LogError.nullProjectName
        }
        mProject = projectName
        
        mAccessToken = ""
        mExpireDate = Date().addingTimeInterval(60*15)//default: 15 min
    }
    public func SetToken(_ token:String,expireDate:Date)throws{
        mAccessToken = token
        guard mAccessToken != "" else{
            throw LogError.nullToken
        }
        guard expireDate.compare(Date())==ComparisonResult.orderedDescending else{
            throw LogError.illegalValueTime
        }
        mExpireDate = expireDate
    }
    public func GetExpireDate() -> Date{
        return mExpireDate
    }
    public func GetToken() -> String{
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
    
    
    
    public func PostLog(_ logGroup:LogGroup,logStoreName:String){
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async(execute: {
            
            let httpUrl = "http://\(self.mProject).\(self.mEndPoint)"+"/logstores/\(logStoreName)/shards/lb"

            let httpPostBody = Data(bytes:logGroup.GetProtoBufPackage(),count:logGroup.GetProtoBufPackage().count)

            let httpPostBodyZipped = httpPostBody.LZ4!
            
            let httpHeaders = self.GetHttpHeadersFrom(logStoreName,url: httpUrl,body: httpPostBody,bodyZipped: httpPostBodyZipped)
        
            self.HttpPostRequest(httpUrl,headers: httpHeaders,body: httpPostBodyZipped)
        })

    }
    
    private func GetHttpHeadersFrom(_ logstore:String,url:String,body:Data,bodyZipped:Data) -> [String:String]{
        var headers = [String:String]()
        
        headers["x-log-apiversion"] = "0.6.0"
        headers["x-log-signaturemethod"] = "hmac-sha1"
        headers["Content-Type"] = "application/x-protobuf"
        headers["Date"] = Date().GMT
        headers["Content-MD5"] = bodyZipped.md5
        headers["Content-Length"] = "\(bodyZipped.count)"
        headers["x-log-bodyrawsize"] = "\(body.count)"
        headers["x-log-compresstype"] = "lz4"
        headers["Host"] = self.getHostIn(url)
        
        
        var signString = "POST"+"\n"
        signString += headers["Content-MD5"]! + "\n"
        signString += headers["Content-Type"]! + "\n"
        signString += headers["Date"]! + "\n"
        
        if(mAccessToken != "" && mExpireDate.timeIntervalSince(Date())<=0)
        {
            headers["x-acs-security-token"] = mAccessToken
            signString += "x-acs-security-token:\(headers["x-acs-security-token"]!)\n"
        }
        
        signString += "x-log-apiversion:0.6.0\n"
        signString += "x-log-bodyrawsize:\(headers["x-log-bodyrawsize"]!)\n"
        signString += "x-log-compresstype:lz4\n"
        signString += "x-log-signaturemethod:hmac-sha1\n"
        signString += "/logstores/\(logstore)/shards/lb"
        let sign  =  hmac_sha1(signString, key: mAccessKeySecret)
        
        headers["Authorization"] = "LOG \(mAccessKeyID):\(sign)"
        return headers
    }
    
    private func HttpPostRequest(_ url:String,headers:[String:String],body:Data){
        
        let NSurl: URL = URL(string: url)!
        
        var request = URLRequest(url: NSurl);
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.httpBody=body
        request.httpShouldHandleCookies=false
        
        for (key, val) in headers {
            request.setValue(val, forHTTPHeaderField: key)
        }
        
        URLSession.shared().dataTask(with: request) {data, response, error in
            if(response != nil){
                let httpResponse = response as! HTTPURLResponse
                if(httpResponse.statusCode != 200){
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                            print("Result:\(jsonResult)")
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }//else{print("Success.")}
            }else{print("Invalid address:\(url)")}
        }.resume()
        
    }
    private func hmac_sha1(_ text:String, key:String)->String {
        
        let keydata =  key.data(using: String.Encoding.utf8)!
        let keybytes = (keydata as NSData).bytes
        let keylen = keydata.count
        
        let textdata = text.data(using: String.Encoding.utf8)!
        let textbytes = (textdata as NSData).bytes
        let textlen = textdata.count
        
        let resultlen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>(allocatingCapacity: resultlen)
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keybytes, keylen, textbytes, textlen, result)
        
        let resultData = Data(bytes: UnsafePointer<UInt8>(result), count: resultlen)
        let base64String = resultData.base64EncodedString(NSData.Base64EncodingOptions(rawValue: 0))
        
        result.deinitialize()
        return base64String
    }
    private func getHostIn(_ url:String)->String {
        var host = url
        if let idx = url.range(of: "://") {
            host = host.substring(from: url.index(idx.lowerBound, offsetBy: 3))
        }
        if let idx = host.range(of: "/") {
            host = host.substring(to: idx.lowerBound)
        }
        return host;
    }
}

