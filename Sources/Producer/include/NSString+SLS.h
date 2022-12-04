//
//  NSString+SLS.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SLS)

/**
 * Encode string with base64.
 */
- (NSString *) base64Encode;

/**
 * Decode string with base64.
 */
- (NSString *) base64Decode;

/**
 * String to dictionary.
 */
- (NSDictionary *) toDictionary;

/**
 * String with dictionary.
 */
+ (NSString *) stringWithDictionary: (NSDictionary *) dictionary;

@end

NS_ASSUME_NONNULL_END
