//
//  NSURLSession+SLS.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (SLS)
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse **)response
                             error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
