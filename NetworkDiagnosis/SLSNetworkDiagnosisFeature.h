//
//  SLSNetworkDiagnosisFeature.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/10.
//

#import <AliyunLogProducer/AliyunLogProducer.h>
#import "SLSSdkFeature.h"
#import "SLSNetworkDiagnosisProtocol.h"

#import "SLSSdkSender.h"
#import "SLSCredentials.h"
//#import "AliNetworkDiagnosis/AliNetworkDiagnosis.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSNetworkDiagnosisFeature : SLSSdkFeature<SLSNetworkDiagnosisProtocol>

@end

//@interface SLSNetworkDiagnosisSender : SLSSdkSender<AliNetworkDiagnosisDelegate>
//- (instancetype) initWithFeature: (SLSSdkFeature *) feature;
//+ (instancetype) sender: (SLSCredentials *) credentials feature: (SLSSdkFeature *) feature;
//@end

NS_ASSUME_NONNULL_END
