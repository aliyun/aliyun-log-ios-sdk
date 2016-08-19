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
    private var mExpireDate:NSDate
    public init(endPoint:String,accessKeyID:String,accessKeySecret :String,projectName:String) throws{
        
        guard !endPoint.isEmpty else{
            throw LogError.NullEndPoint
        }
        let endPoint_L = endPoint.lowercaseString.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
        
        if( endPoint_L.rangeOfString("http://") != nil){
             mEndPoint = endPoint.substringFromIndex(endPoint.startIndex.advancedBy(7))
        }
        else if(endPoint_L.rangeOfString("https://") != nil){
             mEndPoint = endPoint.substringFromIndex(endPoint.startIndex.advancedBy(8))
        }
        else{
            mEndPoint = endPoint_L
        }
        
        guard !accessKeyID.isEmpty else{
            throw LogError.NullAKID
        }
        mAccessKeyID = accessKeyID
        
        guard !accessKeySecret.isEmpty else{
            throw LogError.NullAKSecret
        }
        mAccessKeySecret = accessKeySecret
        
        guard !projectName.isEmpty else{
            throw LogError.NullProjectName
        }
        mProject = projectName
        
        mAccessToken = String()
        mExpireDate = NSDate().dateByAddingTimeInterval(Double(TOKEN_EXPIRE_TIME))//default: 15 min
    }
    public func SetToken(token:String,expireDate:NSDate)throws{
        mAccessToken = token
        guard !mAccessToken.isEmpty else{
            throw LogError.NullToken
        }
        guard expireDate.compare(NSDate())==NSComparisonResult.OrderedDescending else{
            throw LogError.IllegalValueTime
        }
        mExpireDate = expireDate
    }
    public func GetExpireDate() -> NSDate{
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
    public func PostLog(logGroup:LogGroup,logStoreName:String){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let httpUrl = "http://\(self.mProject).\(self.mEndPoint)"+"/logstores/\(logStoreName)/shards/lb"
            
            let httpPostBody = logGroup.GetJsonPackage().dataUsingEncoding(NSUTF8StringEncoding)!
            let httpPostBodyZipped = httpPostBody.GZip!
            
            let httpHeaders = self.GetHttpHeadersFrom(logStoreName,url: httpUrl,body: httpPostBody,bodyZipped: httpPostBodyZipped)
            
            self.HttpPostRequest(httpUrl,headers: httpHeaders,body: httpPostBodyZipped)
            
        })
        
    }
    
    private func GetHttpHeadersFrom(logstore:String,url:String,body:NSData,bodyZipped:NSData) -> [String:String]{
        var headers = [String:String]()
        
        headers[KEY_LOG_APIVERSION] = POST_VALUE_LOG_APIVERSION
        headers[KEY_LOG_SIGNATUREMETHOD] = POST_VALUE_LOG_SIGNATUREMETHOD
        headers[KEY_CONTENT_TYPE] = POST_VALUE_LOG_CONTENTTYPE
        headers[KEY_DATE] = NSDate().GMT
        headers[KEY_CONTENT_MD5] = bodyZipped.md5
        headers[KEY_CONTENT_LENGTH] = "\(bodyZipped.length)"
        headers[KEY_LOG_BODYRAWSIZE] = "\(body.length)"
        headers[KEY_LOG_COMPRESSTYPE] = POST_VALUE_LOG_COMPRESSTYPE
        headers[KEY_HOST] = self.getHostIn(url)
        
        
        var signString = POST_METHOD_NAME + "\n"
        signString += headers[KEY_CONTENT_MD5]! + "\n"
        signString += headers[KEY_CONTENT_TYPE]! + "\n"
        signString += headers[KEY_DATE]! + "\n"
        
        if(!mAccessToken.isEmpty && mExpireDate.timeIntervalSinceDate(NSDate())<=0)
        {
            headers[KEY_ACS_SECURITY_TOKEN] = mAccessToken
            signString += "\(KEY_ACS_SECURITY_TOKEN):\(headers[KEY_ACS_SECURITY_TOKEN]!)\n"
        }
        
        signString += "\(KEY_LOG_APIVERSION):\(headers[KEY_LOG_APIVERSION]!)"
        signString += "\(KEY_LOG_BODYRAWSIZE):\(headers[KEY_LOG_BODYRAWSIZE]!)\n"
        signString += "\(KEY_LOG_COMPRESSTYPE):\(headers[KEY_LOG_COMPRESSTYPE]!)\n"
        signString += "\(KEY_LOG_SIGNATUREMETHOD):\(headers[KEY_LOG_SIGNATUREMETHOD]!)\n"
        signString += "/logstores/\(logstore)/shards/lb"
        let sign  =  hmac_sha1(signString, key: mAccessKeySecret)
        
        headers[KEY_AUTHORIZATION] = "LOG \(mAccessKeyID):\(sign)"
        return headers
    }

    private func HttpPostRequest(url:String,headers:[String:String],body:NSData){
        
        let NSurl: NSURL = NSURL(string: url)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSurl)
        request.HTTPMethod = POST_METHOD_NAME
        request.timeoutInterval = 60
        request.HTTPBody=body
        request.HTTPShouldHandleCookies=false
        
        for (key, val) in headers {
            request.setValue(val, forHTTPHeaderField: key)
        }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            if(response != nil){
                let httpResponse = response as! NSHTTPURLResponse
                if(httpResponse.statusCode != 200){
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                            print("Result:\(jsonResult)")
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }//else: success
            }else{print("Invalid address:\(url)")}
        });
        
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

