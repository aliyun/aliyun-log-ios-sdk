//
//  HttpHeader.h
//  Pods
//
//  Created by gordon on 2022/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSHttpHeader : NSObject
+ (NSArray<NSString *> *) getHeaders: (NSArray<NSString *> *) srcHeaders, ... NS_REQUIRES_NIL_TERMINATION;
@end

NS_ASSUME_NONNULL_END
