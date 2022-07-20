//
//  SLSFeatureProtocol.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import <Foundation/Foundation.h>
#import "SLSCredentials.h"
#import "SLSConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SLSFeatureProtocol <NSObject>

- (NSString *) name;
- (NSString *) version;
- (void) initialize: (SLSCredentials *) credentials configuration: (SLSConfiguration *) configuration;
- (BOOL) isInitialize;
- (void) stop;
- (void) setCredentials: (SLSCredentials *) credentials;
- (void) addCustom: (NSString *) eventId properties: (NSDictionary<NSString *, NSString *> *) proterties;

@end

NS_ASSUME_NONNULL_END
