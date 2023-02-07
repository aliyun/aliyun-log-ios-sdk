//
//  SLSLogData.h
//  
//
//  Created by gordon on 2023/2/2.
//

#import <Foundation/Foundation.h>
#import "SLSRecord.h"
#import "SLSResource.h"
#import "SLSLogScope.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SLSLogsLevel){
    SLS_LOGS_UNDEFINED_SEVERITY_NUMBER = 0,
    SLS_LOGS_TRACE = 1,
    SLS_LOGS_DEBUG = 5,
    SLS_LOGS_INFO = 9,
    SLS_LOGS_WARN = 13,
    SLS_LOGS_ERROR = 17,
    SLS_LOGS_FATAL = 21
};


@class SLSLogDataBuilder;
@interface SLSLogData : NSObject

@property(nonatomic, strong) SLSResource *resource;
@property(nonatomic, strong) SLSLogScope *scope;
@property(nonatomic, strong) NSArray<SLSRecord *> *logRecords;

+ (SLSLogDataBuilder *) builder NS_SWIFT_NAME(builder());

- (SLSLogData *) addRecord: (SLSRecord *) record NS_SWIFT_NAME(addRecord(_:));

- (NSDictionary *) toJson NS_SWIFT_NAME(toJson());

@end

@interface SLSLogDataBuilder : NSObject

@property(nonatomic, strong, readonly) SLSResource *resource;
@property(atomic, assign) SLSLogsLevel level;
@property(copy, readonly) NSString *severityText;
@property(nonatomic, strong, readonly) SLSLogScope *scope;
@property(atomic, assign, readonly) NSInteger epochNanos;
@property(copy, readonly) NSString *traceId;
@property(copy, readonly) NSString *spanId;
@property(copy, readonly) NSString *logContent;
@property(nonatomic, strong, readonly) NSArray<SLSAttribute *> *attributes;

+ (SLSLogDataBuilder *) builder NS_SWIFT_NAME(builder());

- (SLSLogDataBuilder *) setResource: (SLSResource *) resource NS_SWIFT_NAME(setResource(_:));
- (SLSLogDataBuilder *) setLogsLevel: (SLSLogsLevel) level NS_SWIFT_NAME(setLogsLevel(_:));
- (SLSLogDataBuilder *) setSeverityText: (NSString *) severityText NS_SWIFT_NAME(setSeverityText(_:));
- (SLSLogDataBuilder *) setScope: (SLSLogScope *) scope NS_SWIFT_NAME(setScope(_:));
- (SLSLogDataBuilder *) setEpochNanos: (NSInteger *) epochNanos NS_SWIFT_NAME(setEpochNanos(_:));
- (SLSLogDataBuilder *) setTraceId: (NSString *) traceId NS_SWIFT_NAME(setTraceId(_:));
- (SLSLogDataBuilder *) setSpanId: (NSString *) spanId NS_SWIFT_NAME(setSpanId(_:));
- (SLSLogDataBuilder *) setLogContent: (NSString *) content NS_SWIFT_NAME(setLogContent(_:));
- (SLSLogDataBuilder *) setAttribute: (NSArray<SLSAttribute *> *) attributes NS_SWIFT_NAME(setAttribute(_:));

- (SLSLogData *) build NS_SWIFT_NAME(build());

@end

NS_ASSUME_NONNULL_END
