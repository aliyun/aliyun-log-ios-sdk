//
//  AliIntervalDetection.h
//  AliNetworkDiagnosis
//
//  Created by colin on 2021/11/21.
//


#import <Foundation/Foundation.h>
#import <AliNetworkDiagnosis/AliProtocols.h>

@interface AliDetectConfig: NSObject

@property NSString* host;
@property AliNetDiagNetworkInterfaceType interfaceType;
@property NSInteger prefer;
@property (nonatomic, strong) id context;
@property NSString* traceID;
@property NSString* src;

@property NSMutableDictionary *detectExtension;

@property NSInteger count;

@end
