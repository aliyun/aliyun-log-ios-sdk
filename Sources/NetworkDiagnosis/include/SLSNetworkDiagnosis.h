//
//  SLSNetworkDiagnosis.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/10.
//

#import <Foundation/Foundation.h>
#import "SLSNetworkDiagnosisProtocol.h"
#import "SLSNetworkDiagnosisFeature.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSNetworkDiagnosis : NSObject<SLSNetworkDiagnosisProtocol>
+ (instancetype) sharedInstance;
- (void) setNetworkDiagnosisFeature: (SLSNetworkDiagnosisFeature *) feature;
- (void) updateExtensions: (NSDictionary *) extension;

@end

NS_ASSUME_NONNULL_END
