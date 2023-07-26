################################################################################################################################
##################################################### podspec file for dev #####################################################
################################################################################################################################

Pod::Spec.new do |s|
  s.name             = 'AliyunLogProducer'
  s.version          = '3.1.19'
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
  s.author           = { 'aliyun-log' => 'yulong.gyl@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/aliyun/aliyun-log-ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'http://t.cn/AiRpol8C'

  # s.ios.deployment_target = '10.0'
  # s.osx.deployment_target =  '10.12'
  # s.tvos.deployment_target =  '10.0'
  s.platform     = :ios, "10.0"

  s.requires_arc  = true
  s.libraries = 'z'
  s.swift_version = "5.0"
#  s.xcconfig = { 'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES' }

  s.default_subspec = 'Producer'
  
  s.subspec 'Producer' do |c|
    c.ios.deployment_target = '10.0'
    c.tvos.deployment_target =  '10.0'
    c.osx.deployment_target =  '10.12'
    c.source_files = 'Sources/Producer/**/*.{h,m}', 'Sources/aliyun-log-c-sdk/**/*.{c,h}'
    c.public_header_files = 'Sources/Producer/include/*.h', 'Sources/aliyun-log-c-sdk/include/*.h'
  end

  s.subspec 'Core' do |c|
    c.ios.deployment_target = '10.0'
    c.tvos.deployment_target =  '10.0'
    c.osx.deployment_target =  '10.12'
    c.dependency 'AliyunLogProducer/Producer'
    c.dependency 'AliyunLogProducer/OT'
    c.source_files = 'Sources/Core/**/*.{m,h}'
    c.public_header_files = 'Sources/Core/include/*.h'
  end
  
  s.subspec 'OTSwift' do |c|
    c.ios.deployment_target = '10.0'
    c.tvos.deployment_target =  '10.0'
    c.osx.deployment_target =  '10.12'
    c.source_files = 'Sources/OTSwift/**/*.{m,h,swift}'
  end
  
  s.subspec 'OT' do |c|
    c.ios.deployment_target = '10.0'
    c.tvos.deployment_target =  '10.0'
    c.osx.deployment_target =  '10.12'
    c.source_files = 'Sources/OT/**/*.{m,h}'
    c.public_header_files = 'Sources/OT/**/include/*.h'
    
    c.dependency 'AliyunLogProducer/OTSwift'
  end
  
  s.subspec 'CrashReporter' do |c|
    c.ios.deployment_target = '10.0'
    c.tvos.deployment_target =  '10.0'
    c.osx.deployment_target =  '10.12'
    c.dependency 'AliyunLogProducer/Core'
    c.dependency 'AliyunLogProducer/OT'
    c.dependency 'AliyunLogProducer/Trace'
    c.source_files = 'Sources/CrashReporter/**/*.{m,h}'
    c.public_header_files = 'Sources/CrashReporter/include/*.h'
    c.vendored_frameworks = 'Sources/WPKMobi/WPKMobi.xcframework'
    c.exclude_files = 'Sources/WPKMobi/WPKMobi.xcframework/**/Headers/*.h'

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
  
  s.subspec 'NetworkDiagnosis' do |c|
    c.dependency 'AliyunLogProducer/Core'
    c.dependency 'AliyunLogProducer/OT'
    c.source_files = 'Sources/NetworkDiagnosis/**/*.{m,h}'
    c.public_header_files = "Sources/NetworkDiagnosis/include/*.h"
    c.vendored_frameworks = 'Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework'
    c.exclude_files = 'Sources/AliNetworkDiagnosis/AliNetworkDiagnosis.xcframework/**/Headers/*.h'
    c.frameworks = "SystemConfiguration", "CoreGraphics"
    c.libraries = "z", "c++", "resolv"
    c.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'OTHER_LDFLAGS' => '-ObjC',
    }
    c.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  end
  
  s.subspec 'Trace' do |c|
    c.ios.deployment_target = '10.0'
    c.tvos.deployment_target =  '10.0'
    c.osx.deployment_target =  '10.12'
    c.dependency 'AliyunLogProducer/Producer'
    c.dependency 'AliyunLogProducer/Core'
    c.dependency 'AliyunLogProducer/OT'
    c.source_files = 'Sources/Trace/**/*.{m,h}'
    c.public_header_files = "Sources/Trace/include/*.h"
    c.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'OTHER_LDFLAGS' => '-ObjC',
    }
    c.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  end
  
  s.subspec 'URLSessionInstrumentation' do |c|
    c.ios.deployment_target = '10.0'
    c.tvos.deployment_target =  '10.0'
    c.osx.deployment_target =  '10.12'
    c.dependency 'AliyunLogProducer/OT'
    c.dependency 'AliyunLogProducer/Trace'
    c.source_files = 'Sources/Instrumentation/URLSession/**/*.{m,h,swift}'
    c.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'OTHER_LDFLAGS' => '-ObjC',
    }
    c.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  end
end

