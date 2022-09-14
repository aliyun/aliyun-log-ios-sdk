//
//  SLSURLSessionInstrumentation.h
//  Pods
//
//  Created by gordon on 2022/9/13.
//

#import <Foundation/Foundation.h>
#import "SLSTracer.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SLSCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface SLSURLSessionInstrumentation : NSObject
+ (void) inject;
+ (void) registerInstrumentationDelegate: (id<SLSURLSessionInstrumentationDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
