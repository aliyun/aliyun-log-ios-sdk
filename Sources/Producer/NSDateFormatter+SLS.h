//
//  NSDateFormatter+SLS.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDateFormatter (SLS)

+ (instancetype) sharedInstance;

- (NSDate *) fromString: (NSString *) date;
- (NSDate *) fromString: (NSString *) date formatter: (NSString *) formatter;
- (NSDate *) fromStringZ: (NSString *) date;
- (NSString *) fromDate: (NSDate *) date;
- (NSString *) fromDate: (NSDate *) date formatter: (NSString *) formatter;

@end

NS_ASSUME_NONNULL_END
