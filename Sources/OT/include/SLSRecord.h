//
//  SLSRecord.h
//  
//
//  Created by gordon on 2023/2/2.
//

#import <Foundation/Foundation.h>
#import "SLSAttribute.h"

NS_ASSUME_NONNULL_BEGIN
@class SLSBody;

@interface SLSRecord : NSObject

@property(atomic, assign) NSInteger timeUnixNano;
@property(copy) NSString *severityNumber;
@property(copy) NSString *severityText;
@property(nonatomic, strong) SLSBody *body;
@property(nonatomic, strong) NSArray<SLSAttribute *> *attributes;
@property(copy) NSString *traceId;
@property(copy) NSString *spanId;

+ (SLSRecord *) record;

- (NSDictionary *) toJson;

+ (NSArray *) toArray: (NSArray<SLSRecord *> *) records;

@end

@interface SLSBody : NSObject
@property(copy) NSString *stringValue;
@end


NS_ASSUME_NONNULL_END
