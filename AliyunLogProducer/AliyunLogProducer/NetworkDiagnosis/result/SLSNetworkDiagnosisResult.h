//
//  SLSNetworkDiagnosisResult.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSNetworkDiagnosisResult : NSObject

@property(nonatomic, strong) NSString *data;
@property(nonatomic, assign) BOOL success;

+ (instancetype) success: (NSString *) data;

+ (instancetype) successWithDict: (NSDictionary *) data;

+ (instancetype) successWithArray: (NSArray *)data;

@end

NS_ASSUME_NONNULL_END
