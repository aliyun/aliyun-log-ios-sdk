//
//  SLSNetPolicy.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/3/22.
//

#import <Foundation/Foundation.h>
#import "SLSDestination.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSNetPolicy : NSObject

@property(nonatomic, assign) BOOL enable;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, assign) int version;
@property(nonatomic, assign) BOOL periodicity;
@property(nonatomic, assign) int internal;
@property(nonatomic, assign) long expiration;
@property(nonatomic, assign) int ratio;
@property(nonatomic, strong) NSArray<NSString*> *whitelist;
@property(nonatomic, strong) NSArray<NSString*> *methods;
@property(nonatomic, strong) NSArray<SLSDestination*> *destination;

@end

NS_ASSUME_NONNULL_END
