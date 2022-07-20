//
//  SLSSpanProviderProtocol.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSResource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SLSSpanProviderProtocol <NSObject>

- (SLSResource *) provideResource;

- (NSArray<SLSAttribute *> *) provideAttribute;

@end

NS_ASSUME_NONNULL_END
