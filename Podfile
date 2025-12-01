# Uncomment the next line to define a global platform for your project
#platform :ios, '10.0'
use_frameworks!
#source 'https://cdn.cocoapods.org/'
#source 'https://github.com/CocoaPods/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

##集团内部仓库
#ali_source 'alibaba-specs'
##官方镜像仓库
#ali_source 'alibaba-specs-mirror'
#ali_source 'cdn.podspec.alibaba-inc'

#source 'https://github.com/aliyun-sls/Specs.git'
source 'https://gitee.com/aliyun-sls/Specs.git'

ALIYUN_SLS_VERSION = '4.3.2'
OTEL_VERSION = '1.2.0-dev.1'

USE_LOCAL_PODS = true

#source_project_path = 'AliyunLogSDK'
example_project_path = 'Examples/Examples'

test_project_path = 'Tests/AliyunLogSDKTests'

def all_example_pods
  pod 'OpenTelemetryApiObjc', OTEL_VERSION
  pod 'OpenTelemetrySdkObjc', OTEL_VERSION
    
  if USE_LOCAL_PODS
    pod 'AliyunLogProducer', :path => './'
    pod 'AliyunLogOTelCommon', :path => './'
    pod 'AliyunLogOtlpExporter', :path => './'
    pod 'AliyunLogCrashReporter', :path => './'
    pod 'AliyunLogNetworkDiagnosis', :path => './'
    pod 'AliyunLogURLSessionInstrumentation', :path => './'
    pod 'AliyunLogWKWebViewInstrumentation', :path => './'
  else
    pod 'AliyunLogProducer', ALIYUN_SLS_VERSION
    pod 'AliyunLogOTelCommon', ALIYUN_SLS_VERSION
    pod 'AliyunLogOtlpExporter', ALIYUN_SLS_VERSION
    pod 'AliyunLogCrashReporter', ALIYUN_SLS_VERSION
    pod 'AliyunLogNetworkDiagnosis', ALIYUN_SLS_VERSION
    pod 'AliyunLogURLSessionInstrumentation', ALIYUN_SLS_VERSION
    pod 'AliyunLogWKWebViewInstrumentation', ALIYUN_SLS_VERSION
  end
end

def all_test_pods
  if ENV['build_env']
    pod 'OCMock', '3.8.1-cn'
    pod 'Quick', '5.0.1-cn'
    pod 'Nimble', '10.0.0-cn'
  else
    pod 'OCMock', '3.8.1'
    pod 'Quick', '5.0.1'
    pod 'Nimble', '10.0.0'
  end
  
  pod 'OpenTelemetryApiObjc', OTEL_VERSION
  pod 'OpenTelemetrySdkObjc', OTEL_VERSION

  if USE_LOCAL_PODS
    pod 'AliyunLogProducer', :path => './'
    pod 'AliyunLogOTelCommon', :path => './'
    pod 'AliyunLogOtlpExporter', :path => './'
    pod 'AliyunLogCrashReporter', :path => './'
    pod 'AliyunLogNetworkDiagnosis', :path => './'
    pod 'AliyunLogURLSessionInstrumentation', :path => './'
    pod 'AliyunLogWKWebViewInstrumentation', :path => './'
  else
    pod 'AliyunLogProducer', ALIYUN_SLS_VERSION
    pod 'AliyunLogOTelCommon', ALIYUN_SLS_VERSION
    pod 'AliyunLogOtlpExporter', ALIYUN_SLS_VERSION
    pod 'AliyunLogCrashReporter', ALIYUN_SLS_VERSION
    pod 'AliyunLogNetworkDiagnosis', ALIYUN_SLS_VERSION
    pod 'AliyunLogURLSessionInstrumentation', ALIYUN_SLS_VERSION
    pod 'AliyunLogWKWebViewInstrumentation', ALIYUN_SLS_VERSION
  end
end

workspace 'AliyunLogSDK.xcworkspace'

# Example Project
target 'iOSExamples' do |t|
  project example_project_path
  platform :ios, '10.0'
  
  all_example_pods
end

# NetworkDiagnosis Example Project
target 'NetworkDiagnosisExamples' do |t|
  project 'Examples/NetworkDiagnosisExamples/NetworkDiagnosisExamples'
  platform :ios, '10.0'
  
  if USE_LOCAL_PODS
    pod 'AliyunLogProducer', :path => './'
    pod 'AliyunLogNetworkDiagnosis', :path => './'
  else
    pod 'AliyunLogProducer', ALIYUN_SLS_VERSION
    pod 'AliyunLogNetworkDiagnosis', ALIYUN_SLS_VERSION
  end
end

# NetowrkDiagnosis With Trace Swift Example Project
target 'NetworkTraceSwiftExamples' do |t|
  project 'Examples/NetworkTraceSwiftExamples/NetworkTraceSwiftExamples'
  platform :ios, '10.0'
  
  if USE_LOCAL_PODS
      pod 'AliyunLogProducer', :path => './'
      pod 'AliyunLogOTelCommon/URLSessionInstrumentation', :path => './'
      pod 'AliyunLogOtlpExporter', :path => './'
      pod 'AliyunLogNetworkDiagnosis', :path => './'
  else
    pod 'AliyunLogProducer', ALIYUN_SLS_VERSION
    pod 'AliyunLogOTelCommon', ALIYUN_SLS_VERSION
    pod 'AliyunLogOtlpExporter', ALIYUN_SLS_VERSION
    pod 'AliyunLogNetworkDiagnosis', ALIYUN_SLS_VERSION
  end
end

# Test Project
target 'iOSTests' do |t|
  project test_project_path
  platform :ios, '10.0'
  
  all_test_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
#                config.build_settings['ENABLE_BITCODE'] = 'NO'
# fix error under xcode 15
# error: DT_TOOLCHAIN_DIR cannot be used to evaluate LIBRARY_SEARCH_PATHS, use TOOLCHAIN_DIR instead (in target 'OpenTelemetryApiObjc' from project 'Pods')
                xcconfig_path = config.base_configuration_reference.real_path
                xcconfig = File.read(xcconfig_path)
                xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
                File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
            end
    end
end
