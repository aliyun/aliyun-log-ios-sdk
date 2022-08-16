//
//  SLSURLSession.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSURLSession : NSObject
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                             error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
