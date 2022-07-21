//
//  LogProducerClient+Bricks.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/21.
//

#import <AliyunLogProducer/AliyunLogProducer.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogProducerClient (Bricks)
- (void) setEnableTrack: (BOOL) enable;
- (BOOL) enableTrack;
- (void) appendScheme: (NSMutableDictionary *)target;
@end

NS_ASSUME_NONNULL_END
