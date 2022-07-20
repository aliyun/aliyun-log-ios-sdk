//
//  SLSSenderProtocol.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSCredentials.h"
#import "Log.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SLSSenderProtocol <NSObject>

- (void) initialize: (SLSCredentials *) credentials;
- (BOOL) send: (Log *) log;
- (void) setCredentials: (SLSCredentials *) credentials;

@end

NS_ASSUME_NONNULL_END
