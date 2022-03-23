//
//  SLSNetPolicyBuilder.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/3/22.
//

#import <Foundation/Foundation.h>
#import "SLSNetPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@class SLSNetPolicyBuilder;

@interface SLSNetPolicyBuilder : NSObject

- (SLSNetPolicyBuilder *) setEnable: (BOOL) enable;
- (SLSNetPolicyBuilder *) setType: (NSString *) type;
- (SLSNetPolicyBuilder *) setVersion: (int) version;
- (SLSNetPolicyBuilder *) setPeriodicity: (BOOL) periodicity;
- (SLSNetPolicyBuilder *) setInternal: (int) internal;
- (SLSNetPolicyBuilder *) setExpiration: (long) expiration;
- (SLSNetPolicyBuilder *) setRatio: (int) ratio;
- (SLSNetPolicyBuilder *) setWhiteList: (NSArray<NSString*> *) whitelist;
- (SLSNetPolicyBuilder *) addWhiteList: (NSArray<NSString*> *) whitelist;
- (SLSNetPolicyBuilder *) setMethods: (NSArray<NSString*> *) methods;
- (SLSNetPolicyBuilder *) setEnableMtrMethod;
- (SLSNetPolicyBuilder *) setEnablePingMethod;
- (SLSNetPolicyBuilder *) setEnableTcpPingMethod;
- (SLSNetPolicyBuilder *) setEnableHttpMethod;
- (SLSNetPolicyBuilder *) setDestination: (NSArray<SLSDestination*> *) destination;
- (SLSNetPolicyBuilder *) addDestination: (NSArray<NSString*> *) ips urls: (NSArray<NSString*> *) urls;
- (SLSNetPolicy *) create;
@end

NS_ASSUME_NONNULL_END
