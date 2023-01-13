//
//  SLSNetworkDiagnosisFeature.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/10.
//

#if __has_include("AliyunLogCore/SLSSdkFeature.h")
#import "AliyunLogCore/SLSSdkFeature.h"
#else
#import "SLSSdkFeature.h"
#endif

#import "SLSNetworkDiagnosisProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSNetworkDiagnosisFeature : SLSSdkFeature<SLSNetworkDiagnosisProtocol>
- (void) updateExtensions: (NSDictionary *) extension;
@end

NS_ASSUME_NONNULL_END
