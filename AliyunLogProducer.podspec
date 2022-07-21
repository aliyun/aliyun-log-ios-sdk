#
# Be sure to run `pod lib lint AliyunLogProducer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AliyunLogProducer'
  s.version          = '2.3.10.3'
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
#  s.osx.deployment_target =  '10.8'
#  s.tvos.deployment_target =  '9.0'

  s.requires_arc  = true
  s.libraries = 'z'
#  s.xcconfig = { 'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES' }

  s.default_subspec = 'Producer'
  
  s.subspec 'Producer' do |c|
    c.ios.deployment_target = '9.0'
    c.tvos.deployment_target =  '9.0'
    c.osx.deployment_target =  '10.8'
    c.source_files =
      'AliyunLogProducer/AliyunLogProducer/**/*.{h,m}',
      'AliyunLogProducer/aliyun-log-c-sdk/**/*.{c,h}'

    c.public_header_files =
      'AliyunLogProducer/AliyunLogProducer/*.h',
      'AliyunLogProducer/AliyunLogProducer/Utils/*.h',
      'AliyunLogProducer/aliyun-log-c-sdk/src/log_define.h',
      'AliyunLogProducer/aliyun-log-c-sdk/src/log_http_interface.h',
      'AliyunLogProducer/aliyun-log-c-sdk/src/log_inner_include.h',
      'AliyunLogProducer/aliyun-log-c-sdk/src/log_multi_thread.h',
      'AliyunLogProducer/aliyun-log-c-sdk/src/log_producer_client.h',
      'AliyunLogProducer/aliyun-log-c-sdk/src/log_producer_common.h',
      'AliyunLogProducer/aliyun-log-c-sdk/src/log_producer_config.h'
  end
  
#  s.subspec 'Bricks' do |b|
#    b.ios.deployment_target = '9.0'
#    b.tvos.deployment_target =  '9.0'
#    b.osx.deployment_target =  '10.8'
#    b.dependency 'AliyunLogProducer/Core'
#    b.source_files = 'AliyunLogProducer/AliyunLogProducer/common/**/*.{m,h}'
#    b.public_header_files = 'AliyunLogProducer/AliyunLogProducer/common/**/*.h'
#    b.frameworks = "SystemConfiguration"
#  end
  
  s.subspec 'Core' do |c|
    c.ios.deployment_target = '9.0'
    c.tvos.deployment_target =  '9.0'
    c.osx.deployment_target =  '10.8'
    c.dependency 'AliyunLogProducer/Producer'
    c.dependency 'AliyunLogProducer/OT'
    c.source_files = 'Core/**/*.{m,h}'
    c.public_header_files = 'Core/**/*.h'
  end
  
  s.subspec 'OT' do |o|
    o.ios.deployment_target = '9.0'
    o.tvos.deployment_target =  '9.0'
    o.osx.deployment_target =  '10.8'
    o.source_files = 'OT/**/*.{m,h}'
    o.public_header_files = 'OT/**/*.h'
  end
  
  s.subspec 'CrashReporter' do |c|
    c.ios.deployment_target = '9.0'
    c.tvos.deployment_target =  '9.0'
    c.osx.deployment_target =  '10.8'
    c.dependency 'AliyunLogProducer/Core'
    c.dependency 'AliyunLogProducer/OT'
    c.source_files = 'CrashReporter/**/*.{m,h}'
    c.public_header_files = 'CrashReporter/**/*.h'
    c.vendored_frameworks = 'CrashReporter/WPKMobi.xcframework'
    c.exclude_files = 'CrashReporter/WPKMobi.xcframework/**/Headers/*.h'

    c.ios.frameworks = "SystemConfiguration", "CoreGraphics"
    c.tvos.frameworks = "SystemConfiguration", "CoreGraphics"
    c.osx.frameworks = "SystemConfiguration", "Cocoa"
    
    c.ios.libraries = "z", "c++"
    c.tvos.libraries = "z", "c++"
    c.osx.libraries = "z", "c++"

    c.ios.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
        'OTHER_LDFLAGS' => '-ObjC'
    }
    c.ios.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }

    c.tvos.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
        'OTHER_LDFLAGS' => '-ObjC'
    }
    c.tvos.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64'
    }

    c.osx.pod_target_xcconfig = {
       'OTHER_LDFLAGS' => '-ObjC'
    }
  end
  
  
#  s.subspec 'CrashReporter' do |r|
#    r.ios.deployment_target = '9.0'
#    r.tvos.deployment_target =  '9.0'
#    r.osx.deployment_target =  '10.8'
#    r.dependency 'AliyunLogProducer/Bricks'
#    r.source_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.{m,h}'
#    r.public_header_files = "AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.h"
#    r.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/WPKMobi.xcframework'
#    r.exclude_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/WPKMobi.xcframework/**/Headers/*.h'
#
#    r.ios.frameworks = "SystemConfiguration", "CoreGraphics"
#    r.tvos.frameworks = "SystemConfiguration", "CoreGraphics"
#    r.osx.frameworks = "SystemConfiguration", "Cocoa"
#
#    r.ios.libraries = "z", "c++"
#    r.tvos.libraries = "z", "c++"
#    r.osx.libraries = "z", "c++"
#
#    r.ios.pod_target_xcconfig = {
#        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
#        'OTHER_LDFLAGS' => '-ObjC'
#    }
#    r.ios.user_target_xcconfig = {
#      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
#    }
#
#    r.tvos.pod_target_xcconfig = {
#        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
#        'OTHER_LDFLAGS' => '-ObjC'
#    }
#    r.tvos.user_target_xcconfig = {
#      'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64'
#    }
#
#    r.osx.pod_target_xcconfig = {
#       'OTHER_LDFLAGS' => '-ObjC'
#    }
#
#  end
#
#  s.subspec 'NetworkDiagnosis' do |n|
#    n.dependency 'AliyunLogProducer/Bricks'
#    n.source_files = 'AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/**/*.{m,h}'
#    n.public_header_files = "AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/**/*.h"
#    n.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/AliNetworkDiagnosis.framework'
#    n.project_header_files = 'AliyunLogProducer/AliyunLogProducer/NetworkDiagnosis/AliNetworkDiagnosis.framework/Headers/**/*.h'
#    n.frameworks = "SystemConfiguration", "CoreGraphics"
#    n.libraries = "z", "c++"
#    n.pod_target_xcconfig = {
#      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
#      'OTHER_LDFLAGS' => '-ObjC',
#    }
#    n.user_target_xcconfig = {
#      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
#    }
#  end
#
#  s.subspec 'Trace' do |t|
#    t.ios.deployment_target = '10.0'
#    t.ios.dependency 'AliyunLogProducer/Bricks'
#    t.ios.dependency "OpenTelemetryApi", "0.0.7"
#    t.ios.dependency "OpenTelemetrySdk", "0.0.16"
#    t.ios.source_files = 'AliyunLogProducer/AliyunLogProducer/Trace/**/*.{m,h}'
#    t.ios.public_header_files = "AliyunLogProducer/AliyunLogProducer/Trace/**/*.h"
##      t.exclude_files = 'AliyunLogProducer/AliyunLogProducer/Trace/**/OpenTelemetrySdk-Swift.h'
##      t.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/Trace/*.{xcframework}'
##      t.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/Trace/OpenTelemetryApi.xcframework'
##      t.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/Trace/OpenTelemetrySdk.framework'
##      t.frameworks = "SystemConfiguration", "CoreGraphics"
##      t.libraries = "z", "c++"
#    t.ios.pod_target_xcconfig = {
#      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
#      'DEFINES_MODULE' => 'YES',
#      'OTHER_LDFLAGS' => '-ObjC'
#    }
#    t.ios.user_target_xcconfig = {
#      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
#    }
#  end
end

