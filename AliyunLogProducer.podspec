################################################################################################################################
##################################################### podspec file for dev #####################################################
################################################################################################################################

Pod::Spec.new do |s|
    s.name             = 'AliyunLogProducer'
    s.version          = "4.2.6-dev.3"
    s.summary          = 'aliyun log service ios producer.'

    s.description      = <<-DESC
    log service ios producer.
    https://help.aliyun.com/document_detail/29063.html
    https://help.aliyun.com/product/28958.html
    DESC

    s.homepage         = 'https://github.com/aliyun/aliyun-log-ios-sdk'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'aliyun-log' => 'yulong.gyl@alibaba-inc.com' }
    s.source           = { :git => 'https://gitee.com/aliyun-sls/aliyun-log-ios-sdk.git', :tag => s.version.to_s }
    s.social_media_url = 'http://t.cn/AiRpol8C'

    # s.ios.deployment_target = '10.0'
    # s.osx.deployment_target =  '10.12'
    # s.tvos.deployment_target =  '10.0'
    s.platform     = :ios, "10.0"

    s.requires_arc  = true
    s.libraries = 'z'
    s.swift_version = "5.0"
    #  s.xcconfig = { 'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES' }

    #  s.default_subspec = 'Producer'
  
    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386',
    }
  
    s.user_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386'
    }

    s.ios.deployment_target = '10.0'
    s.tvos.deployment_target =  '10.0'
    s.osx.deployment_target =  '10.12'
    s.source_files = 'Sources/Producer/**/*.{h,m}', 'Sources/aliyun-log-c-sdk/**/*.{c,h}'
    s.public_header_files = 'Sources/Producer/include/*.h', 'Sources/aliyun-log-c-sdk/include/*.h'
    s.resource_bundles = { s.name => ['Sources/Producer/PrivacyInfo.xcprivacy'] }
end
