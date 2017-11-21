//
//  LOGClient.swift
//  AliyunLOGiOS
//
//  Created by 王佳玮 on 16/7/29.
//  edited by zhuoqin on 17/11/20
//  Copyright © 2016年 wangjwchn. All rights reserved.

import Foundation
public class LOGClient:NSObject{
    var mEndPoint:String
    var mAccessKeyID:String
    var mAccessKeySecret:String
    var mProject:String
    var mAccessToken:String?
    
    //重试相关逻辑
    var retryCount:Int
    let retryMax:Int = 3
    
    public init(endPoint:String,accessKeyID:String,accessKeySecret :String,projectName:String) throws{
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
        
        retryCount = 0
    }
    
    
    public convenience init(endPoint:String, accessKeyID:String, accessKeySecret:String, token:String, projectName:String) throws{
        
        try! self.init(endPoint: endPoint, accessKeyID: accessKeyID, accessKeySecret: accessKeySecret, projectName: projectName)
        
        guard token != "" else{
            throw LogError.nullToken
        }
        mAccessToken = token
    }
    
    private func impl(endPoint:String)throws{
        guard endPoint != "" else{
            throw LogError.nullEndPoint
        }
    }
    
    
    
    open func SetToken(_ token:String)throws{
        guard token != "" else{
            throw LogError.nullToken
        }
        mAccessToken = token
    }
    open func GetToken() -> String?{
        return mAccessToken
    }
    open func GetEndPoint() -> String{
        return mEndPoint
    }
    open func GetKeyID() -> String{
        return mAccessKeyID
    }
    open func GetKeySecret() ->String{
        return mAccessKeySecret
    }
    open func PostLog(_ logGroup:LogGroup,logStoreName:String, call: @escaping (URLResponse?, Error?) -> ()){
        
        DispatchQueue.global(qos: .default).async(execute: {
            
            let httpUrl = "http://\(self.mProject).\(self.mEndPoint)"+"/logstores/\(logStoreName)/shards/lb"
            
            let httpPostBody = logGroup.GetJsonPackage().data(using: String.Encoding.utf8)!
            let httpPostBodyZipped = httpPostBody.GZip!
            
            let httpHeaders = self.GetHttpHeadersFrom(logStoreName,url: httpUrl,body: httpPostBody,bodyZipped: httpPostBodyZipped)
            
            self.HttpPostRequest(httpUrl,headers: httpHeaders,body: httpPostBodyZipped, callBack:call)
            
        })
        
    }
    
    fileprivate func GetHttpHeadersFrom(_ logstore:String,url:String,body:Data,bodyZipped:Data) -> [String:String]{
        var headers = [String:String]()
        
        headers["x-log-apiversion"] = "0.6.0"
        headers["x-log-signaturemethod"] = "hmac-sha1"
        headers["Content-Type"] = "application/json"
        headers["Date"] = Date().GMT
        headers["Content-MD5"] = bodyZipped.md5
        headers["Content-Length"] = "\(bodyZipped.count)"
        headers["x-log-bodyrawsize"] = "\(body.count)"
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
    
    fileprivate func HttpPostRequest(_ url:String,headers:[String:String],body:Data, callBack: @escaping (URLResponse?, Error?) -> ()){
        
        let NSurl: URL = URL(string: url)!
        
        var request = URLRequest(url: NSurl)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.httpBody=body
        request.httpShouldHandleCookies=false
        
        for (key, val) in headers {
            request.setValue(val, forHTTPHeaderField: key)
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        SLSLog.logDebug("request : ", request)
        
        session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            
            SLSLog.logDebug("response header : " ,(String(describing: response)))
            var responseBody:String?
            if (data != nil){
                responseBody = String(data:data!, encoding: String.Encoding.utf8)!
            }
            SLSLog.logDebug("response body  : ", responseBody ?? "")
            SLSLog.logDebug("error : ", (String(describing: error)))
            
            if let httpResponse = response as? HTTPURLResponse , error == nil{
                var serviceError = error;
                SLSLog.logDebug("check retry")
                let needRetry = self.shouldRetry(error:error,httpResponse:httpResponse,retryCount:self.retryCount)
                if needRetry {
                    SLSLog.logDebug("need retry")
                    self.retryCount += 1
                    self.HttpPostRequest(url, headers:headers, body:body, callBack:callBack)
                }else{
                    if (httpResponse.statusCode > 300){
                        let jsonArr = try! JSONSerialization.jsonObject(with:data!,
                                                                        options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: String]
                        if (jsonArr.count > 0){
                            let errorCode = jsonArr["errorCode"]
                            let errorMessage = jsonArr["errorMessage"]
                            let requestID = httpResponse.allHeaderFields["x-log-requestid"]
                            serviceError = LogError.ServiceError(errorCode: errorCode!, errorMessage: errorMessage!, requesetID: requestID as! String)
                        }
                    }
                }
                callBack(response, serviceError)
            }else{
                callBack(response, error)
            }
        }).resume()
    }
    
    fileprivate func hmac_sha1(_ text:String, key:String)->String {
        
        let keydata =  key.data(using: String.Encoding.utf8)!
        let keybytes = (keydata as NSData).bytes
        let keylen = keydata.count
        
        let textdata = text.data(using: String.Encoding.utf8)!
        let textbytes = (textdata as NSData).bytes
        let textlen = textdata.count
        
        let resultlen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: resultlen)
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keybytes, keylen, textbytes, textlen, result)
        
        let resultData = Data(bytes: UnsafePointer<UInt8>(result), count: resultlen)
        let base64String = resultData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        result.deinitialize()
        return base64String
    }
    
    fileprivate func getHostIn(_ url:String)->String {
        var host = url
        if let idx = url.range(of: "://") {
            host = host.substring(from: url.index(idx.lowerBound, offsetBy: 3))
        }
        if let idx = host.range(of: "/") {
            host = host.substring(to: idx.lowerBound)
        }
        return host;
    }
    
    /*
     *  判断是否需要重试。
     *  目前重试的逻辑是当返回的responsecode > 500才进行重试，其他的暂不重试。
     *  1.  服务器内部错误造成的的500 response
     */
    func shouldRetry(error: Error?, httpResponse:HTTPURLResponse, retryCount:Int) -> Bool{
        if error != nil{
            return  false
        }
        if (retryCount >= retryMax){
            return  false
        }
        let statusCode = httpResponse.statusCode
        if (statusCode >= 500){
            return  true
        }
        return false;
    }
}

