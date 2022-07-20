//
//  SlSKeyValue.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSKeyValue : NSObject

@property(nonatomic, strong) NSString* key;
@property(nonatomic, strong) NSString* value;

+ (SLSKeyValue *) create: (NSString*) key value: (NSString*) value;

@end

NS_ASSUME_NONNULL_END
