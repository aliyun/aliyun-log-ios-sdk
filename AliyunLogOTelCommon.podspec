################################################################################################################################
##################################################### podspec file for dev #####################################################
################################################################################################################################

Pod::Spec.new do |s|
    s.name             = 'AliyunLogOTelCommon'
    s.version          = "4.3.3"
    s.summary          = 'aliyun log service ios otel common library.'

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

    s.default_subspec = 'AliyunLogOTelCommon'
  
    s.subspec 'AliyunLogOTelCommon' do |c|
        c.ios.deployment_target = '10.0'
        #    c.tvos.deployment_target =  '10.0'
        #    c.osx.deployment_target =  '10.12'
        c.dependency 'AliyunLogOTelCommon/OpenTelemetryApi'
        c.dependency 'AliyunLogOTelCommon/OpenTelemetrySdk'
        c.dependency 'AliyunLogOTelCommon/URLSessionInstrumentation'
        c.source_files = 'Sources/OTelCommon/**/*.{m,h,swift}'
        c.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386',
          'OTHER_LDFLAGS' => '-ObjC',
        }
        c.user_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386'
        }
    end
  
    s.subspec 'OpenTelemetryApi' do |c|
        c.ios.deployment_target = '10.0'
        #    c.tvos.deployment_target =  '10.0'
        #    c.osx.deployment_target =  '10.12'
        c.vendored_frameworks = 'Sources/OpenTelemetryApi/OpenTelemetryApi.xcframework'
        c.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386',
        }
        c.user_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386'
        }
    end
  
    s.subspec 'OpenTelemetrySdk' do |c|
        c.ios.deployment_target = '10.0'
        #    c.tvos.deployment_target =  '10.0'
        #    c.osx.deployment_target =  '10.12'
        c.vendored_frameworks = 'Sources/OpenTelemetrySdk/OpenTelemetrySdk.xcframework'
        c.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386',
        }
        c.user_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386'
        }
    end

    s.subspec 'URLSessionInstrumentation' do |c|
        c.ios.deployment_target = '10.0'
        #    c.tvos.deployment_target =  '10.0'
        #    c.osx.deployment_target =  '10.12'
        c.vendored_frameworks = 'Sources/URLSessionInstrumentation/URLSessionInstrumentation.xcframework'
        c.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386',
        }
        c.user_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386'
        }
    end
end

