//
//  AliDns.h
//  AliNetworkDiagnosis
//
//  Created by colin on 2022/7/29.
//

#import <Foundation/Foundation.h>
#import <AliNetworkDiagnosis/AliProtocols.h>
#import <AliNetworkDiagnosis/AliDetectConfig.h>

@interface AliDnsResult : NSObject
@property (readonly) NSDictionary* result;
@property (nonatomic,strong) NSString* content;
@end

typedef void (^AliDnsCompleteHandler)(id context, NSString *traceID, AliDnsResult *result);

@interface AliDnsConfig : AliDetectConfig
@property NSString *type;
@property NSString *domain;
@property NSString *nameServer;
@property NSInteger timeout;
@property AliDnsCompleteHandler complete;

-(instancetype)init:(NSString*)domain
         nameServer:(NSString*)nameServer
               type:(NSString*)type
            timeout:(NSInteger)timeout
      interfaceType:(AliNetDiagNetworkInterfaceType)interfaceType
            traceID:(NSString*)traceID
           complete:(AliDnsCompleteHandler)complete
            context:(id)context;
@end

@interface AliDns : NSObject
+(void)execute:(AliDnsConfig*)config;
@end
