//
//  HttpConfigProxy.h
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpConfigProxy : NSObject
@property(nonatomic, strong) NSString *userAgent;

- (void) addPluginUserAgent: (NSString *) key value: (NSString *) value;
- (NSString *) getVersion;

+ (instancetype) sharedInstance;

@end

NS_ASSUME_NONNULL_END
