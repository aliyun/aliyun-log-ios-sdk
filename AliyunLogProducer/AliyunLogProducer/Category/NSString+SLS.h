//
//  NSString+SLS.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SLS)

- (NSString *) base64Encode;

- (NSString *) base64Decode;

- (NSDictionary *) toDictionary;

@end

NS_ASSUME_NONNULL_END
