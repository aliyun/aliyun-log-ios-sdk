################################################################################################################################
########################################### podspec file for publish to aliyun-specs ###########################################
################################################################################################################################

Pod::Spec.new do |s|
    isPodLint = ENV['env'].to_s == 'lint'
    
    s.name             = "AliyunLogProducer"
    s.version          = "3.1.1.beta.1"
    s.summary          = "aliyun log service ios producer."
    
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

    s.homepage         = "https://github.com/aliyun/aliyun-log-ios-sdk"
    s.license          = {
        :type => 'Copyright',
        :text => <<-LICENSE
        Alibaba-Inc copyright
        LICENSE
    }
    s.author           = { 'aliyun-log' => 'yulong.gyl@alibaba-inc.com' }
#    s.source           = { :http => "https://ios-repo.oss-cn-shanghai.aliyuncs.com/AliyunLogProducer/3.0.1.beta.3/AliyunLogProducer.zip" }
    s.source           = { :http => "framework_url" }
    s.social_media_url = "http://t.cn/AiRpol8C"
    
    # s.ios.deployment_target = '9.0'
    # s.osx.deployment_target =  '10.8'
    # s.tvos.deployment_target =  '9.0'
    s.platform     = :ios, "9.0"
    
    s.requires_arc  = true
    s.libraries = "z"
    s.default_subspec = 'Producer'
    
    s.subspec 'Producer' do |c|
        c.ios.deployment_target = '9.0'
        c.tvos.deployment_target =  '9.0'
        c.osx.deployment_target =  '10.8'
        if isPodLint
            c.vendored_frameworks = "build/AliyunLogProducer.framework"
        else
            c.vendored_frameworks = "AliyunLogProducer/AliyunLogProducer.framework"
        end
        c.user_target_xcconfig = {
            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
        }
    end
    
    s.subspec 'OT' do |o|
        o.ios.deployment_target = '9.0'
        o.tvos.deployment_target =  '9.0'
        o.osx.deployment_target =  '10.8'
        if isPodLint
            o.vendored_frameworks = "build/AliyunLogOT.framework"
        else
            o.vendored_frameworks = "AliyunLogOT/AliyunLogOT.framework"
        end
        o.user_target_xcconfig = {
            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
        }
    end

    s.subspec 'Core' do |c|
        c.ios.deployment_target = '9.0'
        c.tvos.deployment_target =  '9.0'
        c.osx.deployment_target =  '10.8'
        c.dependency 'AliyunLogProducer/Producer'
        c.dependency 'AliyunLogProducer/OT'
        if isPodLint
            c.vendored_frameworks = "build/AliyunLogCore.framework"
        else
            c.vendored_frameworks = "AliyunLogCore/AliyunLogCore.framework"
        end
        
        c.user_target_xcconfig = {
            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
        }
    end

    s.subspec 'CrashReporter' do |c|
        c.ios.deployment_target = '9.0'
        c.tvos.deployment_target =  '9.0'
        c.osx.deployment_target =  '10.8'
        c.dependency 'AliyunLogProducer/Producer'
        c.dependency 'AliyunLogProducer/OT'
        c.dependency 'AliyunLogProducer/Core'
        if isPodLint
            c.vendored_frameworks = "build/AliyunLogCrashReporter.framework", "build/WPKMobi.xcframework"
            c.exclude_files = "build/WPKMobi.xcframework/**/Headers/*.h"
        else
            c.vendored_frameworks = "AliyunLogCrashReporter/AliyunLogCrashReporter.framework", "WPKMobi/WPKMobi.xcframework"
            c.exclude_files = "WPKMobi/WPKMobi.xcframework/**/Headers/*.h"
        end

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

    s.subspec 'NetworkDiagnosis' do |n|
        n.dependency 'AliyunLogProducer/Producer'
        n.dependency 'AliyunLogProducer/Core'
        n.dependency 'AliyunLogProducer/OT'

        if isPodLint
            n.vendored_frameworks = "build/AliyunLogNetworkDiagnosis.framework", "build/AliNetworkDiagnosis.framework"
            n.exclude_files = 'build/AliNetworkDiagnosis.framework/**/Headers/*.h'
        else
            n.vendored_frameworks = "AliyunLogNetworkDiagnosis/AliyunLogNetworkDiagnosis.framework", "AliNetworkDiagnosis/AliNetworkDiagnosis.framework"
            n.exclude_files = 'AliNetworkDiagnosis/AliNetworkDiagnosis.framework/**/Headers/*.h'
        end
        n.frameworks = "SystemConfiguration", "CoreGraphics"
        n.libraries = "z", "c++", "resolv"
        n.pod_target_xcconfig = {
            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
            'OTHER_LDFLAGS' => '-ObjC',
        }
        n.user_target_xcconfig = {
            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
        }
    end
    
    s.subspec 'Trace' do |c|
        c.ios.deployment_target = '9.0'
        c.tvos.deployment_target =  '9.0'
        c.osx.deployment_target =  '10.8'
        c.dependency 'AliyunLogProducer/Producer'
        c.dependency 'AliyunLogProducer/Core'
        c.dependency 'AliyunLogProducer/OT'
        if isPodLint
            c.vendored_frameworks = "build/AliyunLogTrace.framework"
        else
            c.vendored_frameworks = "AliyunLogTrace/AliyunLogTrace.framework"
        end
        
        c.user_target_xcconfig = {
            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
        }
    end
end
