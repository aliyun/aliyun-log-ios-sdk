# Aliyun LOG iOS SDK
[![Language](https://img.shields.io/badge/swift-3.0-orange.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/aliyun/aliyun-log-ios-sdk.svg?branch=master)](https://github.com/aliyun/aliyun-log-ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
### 简介
###### [阿里云日志服务](https://www.aliyun.com/product/sls/)SDK基于[日志服务API](https://help.aliyun.com/document_detail/29007.html?spm=5176.55536.224569.9.2rvzUk)实现，目前提供以下功能：
  - 写入日志
  
### 目前提供一下几种使用方式：

##### 使用CocoaPods
  - 敬请期待

##### 使用Carthage
 - 创建一个 `Cartfile`，列出所需要的framework，运行`carthage bootstrap`.
 - 根据这个[说明](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) 来添加 `$(SRCROOT)/Carthage/Build/iOS/AliyunLOGiOS.framework` 到iOS项目中

##### 导入source code
 - 下载并将Source/AliyunLOGiOS文件夹拖入目标项目中.

##### 导入framework

``` bash
cd aliyun-log-ios-sdk
cd Source
bash buildFramework.sh
cd Products
ls

```

 - 执行之后，会在Products文件夹下生成AliyunLOGiOS.framework文件.
 - 将framework拖入xcode project中
 - 确保General--Embedded Binaries中含有此framework
 - 如果拖入framework没有选择copy,确保Build Phases--Embed Frameworks中含有此framework,并在Build Settings--Search Paths--Framework Search Paths中添加aliyun-log-ios-sdk.framework的文件路径
 - 修改安全协议：
 	- 由于目前SDK只支持http协议，所以需要进行如下修改：
 	- 右键点击项目的Info.plist选择open as -- source code ,添加类似如下的配置:
 	
 		```
 		<key>NSAppTransportSecurity</key>
		<dict>
			<key>NSAllowsArbitraryLoads</key>
			<true/>
		</dict>
		```


### 示例

##### Swift:

``` swift
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

##### Objective-C:

``` objective-c
/*
    通过EndPoint、accessKeyID、accessKeySecret 构建日志服务客户端
    @endPoint: 服务访问入口，参见 https://help.aliyun.com/document_detail/29008.html
*/
LOGClient *myClient = [[LOGClient alloc]initWithEndPoint:@"XXX" accessKeyID:@"XXX" accessKeySecret:@"XXX" projectName:@"XXX" error:NULL];
    
/* 创建logGroup */    
LogGroup *logGroup = [[LogGroup alloc] initWithTopic:@"topic_test" source:@"source_test"];

	/* 存入一条log */
    Log *log1 = [Log alloc];
    [log1 PutContent:@"K11" value:@"V11" error:NULL];
    [log1 PutContent:@"K12" value:@"V12" error:NULL];
    [log1 PutContent:@"K13" value:@"V13" error:NULL];
    [logGroup PutLog:log1];
    
    /* 存入一条log */
    Log *log2 = [Log alloc];
    [log2 PutContent:@"K21" value:@"V21" error:NULL];
    [log2 PutContent:@"K22" value:@"V22" error:NULL];
    [log2 PutContent:@"K23" value:@"V23" error:NULL];
    [logGroup PutLog:log2];

 /* 发送 log */    
[myClient PostLog:logGroup logStoreName:@"XXX"];

```
