//
//  ISender.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/27.
//

#import <Foundation/Foundation.h>
#import "SLSConfig.h"
#import "SLSLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface ISender : NSObject
- (void) initWithSLSConfig: (SLSConfig *)config;
- (BOOL) sendDada: (SLSLog *)log;
- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token;
- (void) resetProject: (NSString *)endpoint project:(NSString *)project logstore:(NSString *)logstore;
- (void) updateConfig: (SLSConfig *)config;
@end

NS_ASSUME_NONNULL_END
