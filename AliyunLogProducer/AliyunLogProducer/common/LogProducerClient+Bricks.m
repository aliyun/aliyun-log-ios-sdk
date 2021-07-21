//
//  LogProducerClient+Bricks.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/7/20.
//  Copyright © 2021 lichao. All rights reserved.
//

#import "LogProducerClient+Bricks.h"

@interface LogProducerClient (Bricks)
@property (nonatomic, assign) bool enableTrack;
@end

@implementation LogProducerClient (Bricks)


- (void)setEnableTrack:(bool)enable {
    self->_enableTrack = enable;
}

- (bool)enableTrack {
    return self->_enableTrack;
}

@end
