#
# Be sure to run `pod lib lint AliyunLogProducer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AliyunLogProducer'
  s.version          = '2.5.0.beta.11'
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
  s.source           = { :git => 'http://gitlab.alibaba-inc.com/yulong.gyl/AliyunLogProducer.git', :tag => s.version.to_s }
  s.social_media_url = 'http://t.cn/AiRpol8C'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
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
  end
  
#  s.subspec 'CrashReporter' do |i|
#      i.dependency 'AliyunLogProducer/Bricks'
#
#      i.ios.source_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.{m,h}'
#      i.ios.public_header_files = "AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.h"
#      i.ios.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/iOS/WPKMobi.framework'
#      i.ios.frameworks = "SystemConfiguration", "CoreGraphics"
#      i.ios.libraries = "z", "c++"
#      i.ios.pod_target_xcconfig = {
#          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
#          'OTHER_LDFLAGS' => '-ObjC'
#      }
#      i.ios.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
#  end
#
#  s.subspec 'CrashReporter_tvOS' do |tv|
#    tv.dependency 'AliyunLogProducer/Bricks'
#    tv.tvos.source_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.{m,h}'
#    tv.tvos.public_header_files = "AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.h"
#    tv.tvos.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/tvOS/WPKMobi.framework'
#    tv.tvos.frameworks = "SystemConfiguration", "CoreGraphics"
#    tv.tvos.libraries = "z", "c++"
#
#    tv.tvos.pod_target_xcconfig = {
#        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
#        'OTHER_LDFLAGS' => '-ObjC'
#    }
#    tv.tvos.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64' }
#
#  end


#  s.subspec 'CrashReporter' do |r|
#      r.dependency 'AliyunLogProducer/Bricks'
#
#      r.subspec 'iOS' do |i|
#
#          i.ios.source_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.{m,h}'
#          i.ios.public_header_files = "AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.h"
#          i.ios.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/iOS/WPKMobi.framework'
#          i.ios.frameworks = "SystemConfiguration", "CoreGraphics"
#          i.ios.libraries = "z", "c++"
#          i.ios.pod_target_xcconfig = {
#              'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
#              'OTHER_LDFLAGS' => '-ObjC'
#          }
#          i.ios.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
#      end
#
#      r.subspec 'tvOS' do |t|
#
#         t.tvos.source_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.{m,h}'
#         t.tvos.public_header_files = "AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.h"
#         t.tvos.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/tvOS/WPKMobi.framework'
#         t.tvos.frameworks = "SystemConfiguration", "CoreGraphics"
#         t.tvos.libraries = "z", "c++"
#
#         t.tvos.pod_target_xcconfig = {
#             'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
#             'OTHER_LDFLAGS' => '-ObjC'
#         }
#         t.tvos.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64' }
#      end
#
#  end


  s.subspec 'CrashReporter' do |i|
      i.dependency 'AliyunLogProducer/Bricks'

      i.source_files = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.{m,h}'
      i.public_header_files = "AliyunLogProducer/AliyunLogProducer/CrashReporter/**/*.h"
      i.vendored_frameworks = 'AliyunLogProducer/AliyunLogProducer/CrashReporter/WPKMobi.xcframework'
      i.frameworks = "SystemConfiguration", "CoreGraphics"
      i.libraries = "z", "c++"
      i.ios.pod_target_xcconfig = {
          'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
          'OTHER_LDFLAGS' => '-ObjC'
      }
      i.ios.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

      i.tvos.pod_target_xcconfig = {
         'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
         'OTHER_LDFLAGS' => '-ObjC'
      }
      i.tvos.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64' }
  end
  
end

