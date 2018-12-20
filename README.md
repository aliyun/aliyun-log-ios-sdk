# Aliyun LOG iOS SDK
[![Language](https://img.shields.io/badge/swift-3.0-orange.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/aliyun/aliyun-log-ios-sdk.svg?branch=master)](https://github.com/aliyun/aliyun-log-ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
### 简介
###### [阿里云日志服务](https://www.aliyun.com/product/sls/)SDK基于[日志服务API](https://help.aliyun.com/document_detail/29007.html?spm=5176.55536.224569.9.2rvzUk)实现，目前提供以下功能：
  - 写入日志(默认为HTTPS)
  - 断点续传(默认为HTTPS)
  
### 目前提供一下几种使用方式：



##### 导入source code
 - 下载并将Source/AliyunLOGiOS文件夹拖入目标项目中.
 - 下载FMDB并添加到工程依赖中,SDK目前引用FMDB的2.7.5版本。

##### 导入framework

 - 打开**终端**,cd到工程目录,然后执行
   ```
   sh build_both.sh
   ```
   ,然后会在工程根目录下生成Products文件夹,AliyunLOGiOS.framework,FMDB.framework均位于其中。
 - 将AliyunLOGiOS.framework,FMDB.framework拖入您的xcode project中
 - 确保General--Embedded Binaries中含有AliyunLOGiOS.framework以及依赖的FMDB.framework
 - 如果拖入framework没有选择copy,确保Build Phases--Embed Frameworks中含有此framework,并在Build Settings--Search Paths--Framework Search Paths中添加AliyunLOGiOS.framework,FMDB.framework的文件路径
 
 **打包脚本编译出来的framework库是Release版本,支持i386,x86_64,armv7,arm64的fat库。Fat方式暂不支持xcode10，详见：https://forums.developer.apple.com/thread/109583。如果用xcode10 开发请选择源码方式**

## 常见问题

1.工程编译出来的iOS库怎么没有支持armv7s的架构？

​	Xcode9中默认支持的架构是armv7/arm64,由于arm是向下兼容的，armv7的库在需要支持armv7s的app中也是适用的，如果仍然需要针对armv7s进行优化，那么需要如下图进行设置

![list1](https://github.com/aliyun/aliyun-oss-ios-sdk/blob/master/Images/list1.png)

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
    myClient.PostLog(logGroup,logStoreName: ""){ response, error in

        // handle response however you want

        if error?.domain == NSURLErrorDomain && error?.code == NSURLErrorTimedOut {
            print("timed out") // note, `response` is likely `nil` if it timed out
        }
    }
```


##### Objective-C
``` OC
	// - 如果是Objective-C工程的话，需要设置Build Settings -- Embedded Content Contains Swift Code 为 Yes


    NSString * ENDPOINT = @"******";
    NSString * PROJECTNAME = @"******";
    NSString * LOGSTORENAME = @"******";
    
    //        移动端是不安全环境，不建议直接使用阿里云主账号ak，sk的方式。建议使用STS方式。具体参见 https://help.aliyun.com/document_detail/62643.html
    //        注意：只建议在测试环境或者用户可以保证阿里云主账号AK，SK安全的前提下使用。
    
    //通过STS使用日志服务
    NSString * STS_AK = @"******";
    NSString * STS_SK = @"******";
    NSString * STS_TOKEN = @"******";
    
    LOGClient * client = [[LOGClient alloc] initWithEndPoint:ENDPOINT accessKeyID:STS_AK accessKeySecret:STS_SK token:STS_TOKEN projectName:PROJECTNAME];
    
    //  log调试开关
    client.mIsLogEnable = true;
    
    Log * loginfo = [[Log alloc] init];
    [loginfo PutContent:@"key001" value:@"value001"];
    
    LogGroup * group = [[LogGroup alloc] initWithTopic:@"topic" source:@"object-c"];
    [group PutLog:loginfo];
    
    [client PostLog:group logStoreName:LOGSTORENAME call:^(NSURLResponse *response,NSError *error) {
        NSLog(@"response %@", [response debugDescription]);
        NSLog(@"error %@",[error debugDescription]);
    }];

```

