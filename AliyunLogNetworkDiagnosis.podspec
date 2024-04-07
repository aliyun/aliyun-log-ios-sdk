################################################################################################################################
##################################################### podspec file for dev #####################################################
################################################################################################################################

Pod::Spec.new do |s|
    s.name             = 'AliyunLogNetworkDiagnosis'
    s.version          = "4.3.3"
    s.summary          = 'aliyun log service ios network diagnosis.'

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

    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386',
        'OTHER_LDFLAGS' => '-ObjC',
    }

    s.user_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386'
    }

#    s.dependency 'AliyunLogProducer/Core'
#    s.dependency 'AliyunLogProducer/OT'
    s.dependency 'AliyunLogProducer', "#{s.version}"
    s.dependency 'AliyunLogOtlpExporter', "#{s.version}"
    s.dependency 'AliyunLogOTelCommon', "#{s.version}"
    s.source_files = 'Sources/NetworkDiagnosis/**/*.{m,h}', 'Sources/NetworkDiagnosisSwift/**/*.{m,h,swift}', 'Sources/Core/**/*.{m,h}', 'Sources/OT/**/*.{m,h}'
    s.public_header_files = "Sources/NetworkDiagnosis/include/*.h", 'Sources/Core/include/*.h', 'Sources/OT/**/include/*.h'
    s.resource_bundles = { s.name => ['Sources/NetworkDiagnosis/PrivacyInfo.xcprivacy'] }
    s.vendored_frameworks = 'Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework'
    s.exclude_files = 'Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework/**/Headers/*.h'
    s.frameworks = "SystemConfiguration", "CoreGraphics"
    s.libraries = "z", "c++", "resolv"
end

