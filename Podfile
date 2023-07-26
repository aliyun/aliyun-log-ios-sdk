# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'
use_frameworks!

#source 'https://github.com/CocoaPods/Specs.git'
#source 'https://github.com/aliyun/aliyun-specs.git'
#source 'https://github.com/aliyun-sls/Specs.git'

#source_project_path = 'AliyunLogSDK'
test_project_path = 'Tests/AliyunLogSDKTests'

#def all_source_pods
#
#end

def all_test_pods
  pod 'AliyunLogProducer/Producer', :path => './'
  pod 'AliyunLogProducer/Core', :path => './'
  pod 'AliyunLogProducer/OT', :path => './'
  pod 'AliyunLogProducer/CrashReporter', :path => './'
  pod 'AliyunLogProducer/NetworkDiagnosis', :path => './'
  pod 'AliyunLogProducer/Trace', :path => './'
  pod 'AliyunLogProducer/URLSessionInstrumentation', :path => './'
end

workspace 'AliyunLogSDK.xcworkspace'

#target 'AliyunLogProducer' do |t|
#  project source_project_path
#  platform :ios, '10.0'
#  
#  pod 'AliyunLogProducer/Producer', :path => './'
#  pod 'AliyunLogProducer/Core', :path => './'
#  pod 'AliyunLogProducer/OT', :path => './'
#  pod 'AliyunLogProducer/CrashReporter', :path => './'
#  pod 'AliyunLogProducer/NetworkDiagnosis', :path => './'
#  pod 'AliyunLogProducer/Trace', :path => './'
#  pod 'AliyunLogProducer/URLSessionInstrumentation', :path => './'
#end

#target 'AliyunLogCore' do |t|
#  project source_project_path
#  platform :ios, '10.0'
#  pod 'AliyunLogProducer/Core', :path =>'.'
#end

target 'iOSTests' do |t|
  project test_project_path
  platform :ios, '10.0'
  
  all_test_pods
end

# targets = ['iOS','iOSTests']
# targets.each do |t|

#     target t do
#       # Comment the next line if you don't want to use dynamic frameworks
#       use_frameworks!

#       # Pods for Demo
# #      pod 'AliyunLogProducer', '3.1.17', :subspecs => ['CrashReporter', 'NetworkDiagnosis', 'Trace', 'URLSessionInstrumentation']
#       pod 'AliyunLogProducer/Producer', :path =>'.'
#       pod 'AliyunLogProducer/Core', :path =>'.'
#       pod 'AliyunLogProducer/OT', :path =>'.'
#       pod 'AliyunLogProducer/CrashReporter', :path =>'.'
#       pod 'AliyunLogProducer/NetworkDiagnosis', :path =>'.'
#       pod 'AliyunLogProducer/Trace', :path =>'.'
#       pod 'AliyunLogProducer/URLSessionInstrumentation', :path =>'.'

#       if t == 'iOSTests'
#         pod 'OCMock'
#       end
#     end

# end

#target 'iOS' do
#  # Comment the next line if you don't want to use dynamic frameworks
#  use_frameworks!
#
#  # Pods for Demo
##  pod 'AliyunLogProducer', '2.3.8.3.beta.2' , :subspecs => ['Core', 'Bricks', 'CrashReporter', 'NetworkDiagnosis', 'Trace']
#  pod 'AliyunLogProducer/Core', :path =>'.'
#  pod 'AliyunLogProducer/Bricks', :path =>'.'
#  pod 'AliyunLogProducer/CrashReporter', :path =>'.'
#  pod 'AliyunLogProducer/NetworkDiagnosis', :path =>'.'
#  pod 'AliyunLogProducer/Trace', :path =>'.'
#end

post_install do |installer|
    installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
#                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
    end
end
