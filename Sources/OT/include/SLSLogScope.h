//
//  SLSLogScope.h
//  
//
//  Created by gordon on 2023/2/2.
//

#import <Foundation/Foundation.h>
#import "SLSAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSLogScope : NSObject

@property(copy) NSString *name;
@property(atomic, assign) NSInteger version;
@property(copy) NSArray<SLSAttribute *> *attributes;

+ (SLSLogScope *) getDefault NS_SWIFT_NAME(getDefault());
+ (SLSLogScope *) scope: (NSString *) name version: (NSInteger) version attributes: (NSArray<SLSAttribute *> *) attributes NS_SWIFT_NAME(scope(_:_:_:));
- (NSDictionary *) toJson NS_SWIFT_NAME(toJson());
@end

NS_ASSUME_NONNULL_END
