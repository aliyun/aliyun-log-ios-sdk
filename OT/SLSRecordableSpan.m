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
@property(nonatomic, strong) NSLock *lock;
@end

@implementation SLSRecordableSpan

- (instancetype) initWithSpanProcessor: (id<SLSSpanProcessorProtocol>) processor {
    self = [super init];
    if (self) {
        _processor = processor;
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (BOOL) end {
    [_lock lock];
    self.end = [SLSTimeUtils now];
    [_lock unlock];
    
    BOOL res = [super end];
    if (res) {
        [_lock lock];
        self.start = self.start / 1000;
        self.end = self.end / 1000;
        [_lock unlock];
        
        if (nil != _processor) {
            res = [_processor onEnd:self];
        }
    }
    return res;
}
@end
