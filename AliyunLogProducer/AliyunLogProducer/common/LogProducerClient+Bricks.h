//
//  LogProducerClient+Bricks.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/7/20.
//  Copyright © 2021 lichao. All rights reserved.
//

#import <AliyunLogProducer/AliyunLogProducer.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogProducerClient (Bricks)

- (void) setEnableTrack: (bool) enable;

- (bool) enableTrack;

@end

NS_ASSUME_NONNULL_END
