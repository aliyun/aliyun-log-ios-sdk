//
//  SLSNetworkDiagnosisResult.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/28.
//

#import "SLSNetworkDiagnosisResult.h"

@implementation SLSNetworkDiagnosisResult

+ (instancetype) successWithDict: (NSDictionary *) data {
    return [self success:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data
                                                                                        options:0 error:nil] encoding:NSUTF8StringEncoding]];
}

+ (instancetype) successWithArray: (NSArray *)data {
    return [self success:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data
                                                                                        options:0 error:nil] encoding:NSUTF8StringEncoding]];
}

+ (instancetype) success: (NSString *) data {
    SLSNetworkDiagnosisResult *result = [[SLSNetworkDiagnosisResult alloc] init];
    result.success = YES;
    result.data = data;
    return result;
}

@end
