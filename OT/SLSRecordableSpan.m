//
//  SLSRecordableSpan.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSRecordableSpan.h"
#import "SLSTimeUtils.h"

@interface SLSRecordableSpan ()
@property(nonatomic, strong, readonly) id<SLSSpanProcessorProtocol> processor;
@end

@implementation SLSRecordableSpan

- (instancetype) initWithSpanProcessor: (id<SLSSpanProcessorProtocol>) processor {
    self = [super init];
    if (self) {
        _processor = processor;
    }
    return self;
}

- (BOOL) end {
    self.end = [SLSTimeUtils now];
    BOOL res = [super end];
    if (res) {
        self.start = self.start / 1000;
        self.end = self.end / 1000;
        
        if (nil != _processor) {
            res = [_processor onEnd:self];
        }
    }
    return res;
}
@end
