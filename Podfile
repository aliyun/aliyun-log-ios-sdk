# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'
use_frameworks!
source 'https://cdn.cocoapods.org/'

##集团内部仓库
#ali_source 'alibaba-specs'
##官方镜像仓库
#ali_source 'alibaba-specs-mirror'
#ali_source 'cdn.podspec.alibaba-inc'

#source 'https://github.com/aliyun-sls/Specs.git'

#source_project_path = 'AliyunLogSDK'
example_project_path = 'Examples/Examples'

test_project_path = 'Tests/AliyunLogSDKTests'

def all_example_pods
#  pod 'AliyunLogProducer', '4.0.0-beta.1', :subspecs => ['NetworkDiagnosis', 'Trace', 'URLSessionInstrumentation']
#  pod 'AliyunLogOTelCommon', '4.0.0-beta.1'
#  pod 'AliyunLogOtlpExporter', '4.0.0-beta.1'
#  pod 'AliyunLogCrashReporter', '4.0.0-beta.1'
  pod 'AliyunLogProducer/Producer', :path => './'
#  pod 'AliyunLogProducer/Core', :path => './'
#  pod 'AliyunLogProducer/OT', :path => './'
#  pod 'AliyunLogProducer/CrashReporter', :path => './'
  pod 'AliyunLogProducer/NetworkDiagnosis', :path => './'
  pod 'AliyunLogProducer/Trace', :path => './'
  pod 'AliyunLogProducer/URLSessionInstrumentation', :path => './'
  pod 'AliyunLogOTelCommon', :path => './'
  pod 'AliyunLogOtlpExporter', :path => './'
  pod 'AliyunLogCrashReporter', :path => './'
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
 
#  pod 'AliyunLogProducer', '4.0.0-beta.1', :subspecs => ['NetworkDiagnosis', 'Trace', 'URLSessionInstrumentation']
#  pod 'AliyunLogOTelCommon', '4.0.0-beta.1'
#  pod 'AliyunLogOtlpExporter', '4.0.0-beta.1'
#  pod 'AliyunLogCrashReporter', '4.0.0-beta.1'
  pod 'AliyunLogProducer/Producer', :path => './'
#  pod 'AliyunLogProducer/Core', :path => './'
#  pod 'AliyunLogProducer/OT', :path => './'
#  pod 'AliyunLogProducer/CrashReporter', :path => './'
#  pod 'AliyunLogProducer/NetworkDiagnosis', :path => './'
  pod 'AliyunLogProducer/Trace', :path => './'
  pod 'AliyunLogProducer/URLSessionInstrumentation', :path => './'
  pod 'AliyunLogOTelCommon', :path => './'
  pod 'AliyunLogOtlpExporter', :path => './'
  pod 'AliyunLogCrashReporter', :path => './'
end

workspace 'AliyunLogSDK.xcworkspace'

# Example Project
target 'iOSExamples' do |t|
  project example_project_path
  platform :ios, '10.0'
  
  all_example_pods
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
            end
    end
end
