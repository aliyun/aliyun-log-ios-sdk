# Aliyun SLS iOS SDK
[![Language](https://img.shields.io/badge/swift-2.3-orange.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/aliyun/aliyun-log-ios-sdk.svg?branch=master)](https://github.com/aliyun/aliyun-log-ios-sdk)
### 简介
###### [阿里云日志服务](https://www.aliyun.com/product/sls/)SDK基于[日志服务API](https://help.aliyun.com/document_detail/29007.html?spm=5176.55536.224569.9.2rvzUk)实现，目前提供以下功能：
  - 写入日志
  
### 使用
#### 目前提供一下几种方式：

##### 通过导入framework

 - 执行Source文件夹下的buildFramework.sh，生成的framwork在Products文件夹下


##### 通过CocoaPods



##### 通过Carthage



### 示例

```
 /*
    通过EndPoint、accessKeyID、accessKeySecret 构建日志服务客户端
    @endPoint: 服务访问入口，参见 https://help.aliyun.com/document_detail/29008.html
  */
let myClient = try! LOGClient(endPoint: "",
                              accessKeyID: "",
                              accessKeySecret: "",
                              projectName:"")
        
/* 创建logGroup */
let logGroup = try! LogGroup(topic: "mTopic",source: "mSource")
        
   /* 存入一条log */
    let log1 = Log()
     	 try! log1.PutContent("K11", value: "V11")
         try! log1.PutContent("K12", value: "V12")
         try! log1.PutContent("K13", value: "V13")
    logGroup.PutLog(log1)
        
   /* 存入一条log */
    let log2 = Log()
     	 try! log2.PutContent("K21", value: "V21")
         try! log2.PutContent("K22", value: "V22")
         try! log2.PutContent("K23", value: "V23")
    logGroup.PutLog(log2)
        
 /* 发送 log */
 myClient.PostLog(logGroup,logStoreName: "")

```
