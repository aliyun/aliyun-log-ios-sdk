//
//  SLSDestination.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSDestination : NSObject

@property(nonatomic, strong) NSString *siteId;
@property(nonatomic, strong) NSString *az;
@property(nonatomic, strong) NSArray<NSString*> *ips;
@property(nonatomic, strong) NSArray<NSString*> *urls;

@end

NS_ASSUME_NONNULL_END
