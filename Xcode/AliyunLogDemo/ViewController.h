//
//  ViewController.h
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/17.
//

#import <UIKit/UIKit.h>
#import <AliyunLogProducer/AliyunLogProducer.h>

@interface ViewController : UIViewController
{
    @private
    LogProducerConfig *_config;
    LogProducerClient *_client;
}

- (void) initLogProducer;

@end

