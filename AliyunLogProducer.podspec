#
# Be sure to run `pod lib lint AliyunLogProducer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AliyunLogProducer'
  s.version          = '2.2.0'
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
  s.source           = { :git => 'https://github.com/aliyun/aliyun-log-ios-sdk.git', :tag => '2.2.0' }
  s.social_media_url = 'http://t.cn/AiRpol8C'

  s.ios.deployment_target = '8.0'
  s.requires_arc  = true
  s.libraries = 'z'

  s.source_files = 'AliyunLogProducer/AliyunLogProducer/*.{h,m}','AliyunLogProducer/aliyun-log-c-sdk/src/*.{h,m}'
  
  s.public_header_files = 'AliyunLogProducer/AliyunLogProducer/*.h','AliyunLogProducer/*/src/log_define.h','AliyunLogProducer/*/src/log_http_interface.h','AliyunLogProducer/*/src/log_inner_include.h','AliyunLogProducer/*/src/log_multi_thread.h','AliyunLogProducer/*/src/log_producer_client.h','AliyunLogProducer/*/src/log_producer_common.h','AliyunLogProducer/*/src/log_producer_config.h'
end

