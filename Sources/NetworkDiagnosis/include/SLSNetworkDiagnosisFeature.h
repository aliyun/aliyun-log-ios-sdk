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
#import "SLSDiagnosisProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark -- NetSpeed Diagnosis
@interface NetSpeedDiagnosis : NSObject<SLSDiagnosisProtocol>
@end

#pragma mark -- network diagnosis feature
@interface SLSNetworkDiagnosisFeature : SLSSdkFeature<SLSNetworkDiagnosisProtocol>
- (void) updateExtensions: (NSDictionary *) extension;
- (void) setDiagnosis: (id<SLSDiagnosisProtocol>) diagnosis;
@end

NS_ASSUME_NONNULL_END
