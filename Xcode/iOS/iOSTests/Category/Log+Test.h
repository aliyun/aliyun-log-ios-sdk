//
//  Log+Test.h
//  iOSTests
//
//  Created by gordon on 2022/6/17.
//

#import <AliyunLogProducer/AliyunLogProducer.h>

NS_ASSUME_NONNULL_BEGIN

@interface Log (Test)
- (void) remove: (NSString *)key;
- (void) clear;
@end

NS_ASSUME_NONNULL_END
