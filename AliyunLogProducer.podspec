#
# Be sure to run `pod lib lint AliyunLogProducer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AliyunLogProducer'
  s.version          = '2.3.7'
  s.summary          = 'aliyun log service ios producer.'

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
  s.author           = { 'aliyun-log' => 'davidzhang.zc@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/aliyun/aliyun-log-ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'http://t.cn/AiRpol8C'

  s.ios.deployment_target = '9.0'
  s.default_subspec = 'Core'

  s.requires_arc  = true
  s.libraries = 'z'
  
  s.subspec 'Core' do |c|
      c.source_files =
          'AliyunLogProducer/AliyunLogProducer/*.{h,m}',
          'AliyunLogProducer/aliyun-log-c-sdk/src/*.{c,h}',
          'AliyunLogProducer/AliyunLogProducer/utils/*.{m,h}'
      
      c.public_header_files =
          'AliyunLogProducer/AliyunLogProducer/*.h',
          'AliyunLogProducer/AliyunLogProducer/utils/*.h',
          'AliyunLogProducer/aliyun-log-c-sdk/src/log_define.h',
          'AliyunLogProducer/aliyun-log-c-sdk/src/log_http_interface.h',
          'AliyunLogProducer/aliyun-log-c-sdk/src/log_inner_include.h',
          'AliyunLogProducer/aliyun-log-c-sdk/src/log_multi_thread.h',
          'AliyunLogProducer/aliyun-log-c-sdk/src/log_producer_client.h',
          'AliyunLogProducer/aliyun-log-c-sdk/src/log_producer_common.h',
          'AliyunLogProducer/aliyun-log-c-sdk/src/log_producer_config.h'
  end
  
  s.subspec 'Bricks' do |b|
      b.dependency 'AliyunLogProducer/Core'
      b.source_files =
      'AliyunLogProducer/AliyunLogProducer/common/**/*.{m,h}'
      b.public_header_files =
      'AliyunLogProducer/AliyunLogProducer/common/**/*.h'
      b.frameworks = "SystemConfiguration"
      b.dependency 'Reachability', '~> 3.2'
  end
  
  s.subspec 'CrashReporter' do |r|
      r.dependency 'AliyunLogProducer/Bricks'
      r.source_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.{m,h}'
      r.public_header_files = "AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.h"
      r.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/WPKMobi.framework'
      r.frameworks = "SystemConfiguration", "CoreGraphics"
      r.libraries = "z", "c++"
      r.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
          'OTHER_LDFLAGS' => '-ObjC'
      }
      r.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end
  
  s.subspec 'NetworkDiagnosis' do |n|
    n.dependency 'AliyunLogProducer/Bricks'
    n.source_files = 'AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/**/*.{m,h}'
    n.public_header_files = "AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/**/*.h"
    n.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/AliNetworkDiagnosis.framework'
    n.project_header_files = 'AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/AliNetworkDiagnosis.framework/Headers/**/*.h'
    n.frameworks = "SystemConfiguration", "CoreGraphics"
    n.libraries = "z", "c++"
    n.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
        'OTHER_LDFLAGS' => '-ObjC',
    }
    n.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'  }
  end
  
  s.subspec 'Trace' do |t|
      t.ios.deployment_target = '10.0'
      t.dependency 'AliyunLogProducer/Bricks'
      t.dependency "OpenTelemetryApi", "0.0.7"
      t.dependency "OpenTelemetrySdk", "0.0.16"
      t.source_files = 'AliyunLogProducer/AliyunLogProducer/Trace/**/*.{m,h}'
      t.public_header_files = "AliyunLogProducer/AliyunLogProducer/Trace/**/*.h"
#      t.exclude_files = 'AliyunLogProducer/AliyunLogProducer/Trace/**/OpenTelemetrySdk-Swift.h'
#      t.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/Trace/*.{xcframework}'
#      t.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/Trace/OpenTelemetryApi.xcframework'
#      t.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/Trace/OpenTelemetrySdk.framework'
#      t.frameworks = "SystemConfiguration", "CoreGraphics"
#      t.libraries = "z", "c++"
      t.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
          'DEFINES_MODULE' => 'YES',
          'OTHER_LDFLAGS' => '-ObjC'
      }
      t.user_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
      }
  end
end

