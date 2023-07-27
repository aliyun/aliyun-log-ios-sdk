# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'
use_frameworks!

#source 'https://github.com/aliyun-sls/Specs.git'

#source_project_path = 'AliyunLogSDK'
example_project_path = 'Examples/Examples'

test_project_path = 'Tests/AliyunLogSDKTests'

def all_example_pods
#  pod 'AliyunLogProducer', '3.2.0-alpha.1', :subspecs => ['CrashReporter', 'NetworkDiagnosis', 'Trace', 'URLSessionInstrumentation']
  pod 'AliyunLogProducer/Producer', :path => './'
  pod 'AliyunLogProducer/Core', :path => './'
  pod 'AliyunLogProducer/OT', :path => './'
  pod 'AliyunLogProducer/CrashReporter', :path => './'
  pod 'AliyunLogProducer/NetworkDiagnosis', :path => './'
  pod 'AliyunLogProducer/Trace', :path => './'
  pod 'AliyunLogProducer/URLSessionInstrumentation', :path => './'
end

def all_test_pods
  pod 'OCMock'
  pod 'Quick'
  pod 'Nimble'
 
# pod 'AliyunLogProducer', '3.2.0-alpha.1', :subspecs => ['CrashReporter', 'NetworkDiagnosis', 'Trace', 'URLSessionInstrumentation']
  pod 'AliyunLogProducer/Producer', :path => './'
  pod 'AliyunLogProducer/Core', :path => './'
  pod 'AliyunLogProducer/OT', :path => './'
  pod 'AliyunLogProducer/CrashReporter', :path => './'
  pod 'AliyunLogProducer/NetworkDiagnosis', :path => './'
  pod 'AliyunLogProducer/Trace', :path => './'
  pod 'AliyunLogProducer/URLSessionInstrumentation', :path => './'
end

workspace 'AliyunLogSDK.xcworkspace'

# Example Project
target 'iOS Examples' do |t|
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
