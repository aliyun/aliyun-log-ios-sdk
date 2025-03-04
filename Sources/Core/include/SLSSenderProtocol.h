//
//  SLSSenderProtocol.h
//  AliyunLogCore
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSCredentials.h"
//#import "AliyunLogProducer/Log.h"

@class AliyunLog;
NS_ASSUME_NONNULL_BEGIN

@protocol SLSSenderProtocol <NSObject>

- (void) initialize: (SLSCredentials *) credentials;
- (BOOL) send: (AliyunLog *) log;
- (void) setCredentials: (SLSCredentials *) credentials;
- (void) setCallback: (nullable CredentialsCallback) callback;
@end

NS_ASSUME_NONNULL_END
