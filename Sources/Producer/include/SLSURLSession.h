//
//  SLSURLSession.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSURLSession : NSObject
+ (void)setBeforeSend:(NSMutableURLRequest *(^)(NSMutableURLRequest *request))beforeSend;
+ (void)setURLSession:(NSURLSession *)session;
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                             error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
