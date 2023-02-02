//
//  SLSScope.h
//  
//
//  Created by gordon on 2023/2/2.
//

#import <Foundation/Foundation.h>
#import "SLSAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLSScope : NSObject

@property(copy) NSString *name;
@property(atomic, assign) NSInteger version;
@property(copy) NSArray<SLSAttribute *> *attributes;

+ (SLSScope *) getDefault;
- (NSDictionary *) toJson;
@end

NS_ASSUME_NONNULL_END
