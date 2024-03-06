//
//  AliIntervalDetection.h
//  AliNetworkDiagnosis
//
//  Created by colin on 2021/11/21.
//


#import <Foundation/Foundation.h>
#import <AliNetworkDiagnosis/AliProtocols.h>

@interface AliFlowNode: NSObject

@property NSString* nodeName;
@property NSString* traceId;
@property NSString* spanId;
@property NSString* parentSpanId;
@property (nonatomic, strong) id context;
@property NSMutableDictionary *tags;

+(instancetype)init:(NSString*)nodeName
            traceId:(NSString*)traceId
             spanId:(NSString*)spanId
       parentSpanId:(NSString*)parentSpanId;

@end
