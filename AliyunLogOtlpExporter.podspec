################################################################################################################################
##################################################### podspec file for dev #####################################################
################################################################################################################################

Pod::Spec.new do |s|
  s.name             = 'AliyunLogOtlpExporter'
  s.version          = '4.0.0-beta.4'
  s.summary          = 'aliyun log service ios otlp exporter.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

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

  s.default_subspec = 'AliyunLogOtlpExporter'
  
  s.subspec 'AliyunLogOtlpExporter' do |c|
    c.ios.deployment_target = '10.0'
#    c.tvos.deployment_target =  '10.0'
#    c.osx.deployment_target =  '10.12'
    c.dependency 'AliyunLogProducer/Producer', '4.0.0-beta.4'
    c.dependency 'AliyunLogOTelCommon/OpenTelemetryApi', '4.0.0-beta.4'
    c.dependency 'AliyunLogOTelCommon/OpenTelemetrySdk', '4.0.0-beta.4'
    c.dependency 'AliyunLogOTelCommon/AliyunLogOTelCommon', '4.0.0-beta.4'
    c.source_files = 'Sources/OtlpExporter/**/*.{m,h,swift}'
    c.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'OTHER_LDFLAGS' => '-ObjC',
    }
    c.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  end
end

