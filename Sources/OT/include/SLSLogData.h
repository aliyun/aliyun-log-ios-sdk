//
//  SLSLogData.h
//  
//
//  Created by gordon on 2023/2/2.
//

#import <Foundation/Foundation.h>
#import "SLSRecord.h"
#import "SLSResource.h"
#import "SLSScope.h"

NS_ASSUME_NONNULL_BEGIN

@class SLSLogDataBuilder;
@interface SLSLogData : NSObject

@property(nonatomic, strong) SLSResource *resource;
@property(nonatomic, strong) SLSScope *scope;
@property(nonatomic, strong) NSArray<SLSRecord *> *logRecords;

+ (SLSLogDataBuilder *) builder;

- (NSDictionary *) toJson;

@end

@interface SLSLogDataBuilder : NSObject

@property(nonatomic, strong, readonly) SLSResource *resource;
@property(copy, readonly) NSString *severityText;
@property(nonatomic, strong, readonly) SLSScope *scope;
@property(atomic, assign, readonly) NSInteger epochNanos;
@property(copy, readonly) NSString *traceId;
@property(copy, readonly) NSString *spanId;
@property(copy, readonly) NSString *logContent;
@property(nonatomic, strong, readonly) NSArray<SLSAttribute *> *attributes;

+ (SLSLogDataBuilder *) builder;

- (SLSLogDataBuilder *) setResource: (SLSResource *) resource;
- (SLSLogDataBuilder *) setSeverityText: (NSString *) severityText;
- (SLSLogDataBuilder *) setScope: (SLSScope *) scope;
- (SLSLogDataBuilder *) setEpochNanos: (NSInteger *) epochNanos;
- (SLSLogDataBuilder *) setTraceId: (NSString *) traceId;
- (SLSLogDataBuilder *) setSpanId: (NSString *) spanId;
- (SLSLogDataBuilder *) setLogContent: (NSString *) content;
- (SLSLogDataBuilder *) setAttribute: (NSArray<SLSAttribute *> *) attributes;

- (SLSLogData *) build;

@end

NS_ASSUME_NONNULL_END
