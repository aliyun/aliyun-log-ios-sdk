//
//  SLSSpan.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSResource.h"
#import "SLSEvent.h"
#import "SLSLink.h"

NS_ASSUME_NONNULL_BEGIN
typedef NSString *SLSKind NS_STRING_ENUM;
FOUNDATION_EXPORT SLSKind const SLSINTERNAL;
FOUNDATION_EXPORT SLSKind const SLSSERVER;
FOUNDATION_EXPORT SLSKind const SLSCLIENT;
FOUNDATION_EXPORT SLSKind const SLSPRODUCER;
FOUNDATION_EXPORT SLSKind const SLSCONSUMER;

typedef NS_ENUM(NSInteger, SLSStatusCode){
    UNSET = 0,
    OK = 1,
    ERROR = 2
};

@interface SLSSpan : NSObject

@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) SLSKind kind;
@property(nonatomic, strong) NSString* traceID;
@property(nonatomic, strong) NSString* spanID;
@property(nonatomic, strong) NSString* parentSpanID;
@property(nonatomic, assign) long start;
@property(nonatomic, assign, getter=getEndTime) long end;
@property(nonatomic, assign) long duration;
@property(nonatomic, strong) NSDictionary<NSString*, NSString*>* attribute;
@property(nonatomic, strong, readonly) NSArray<SLSEvent*> *evetns;
@property(nonatomic, strong, readonly) NSArray<SLSLink*> *links;
@property(nonatomic, assign) SLSStatusCode statusCode;
@property(nonatomic, strong) NSString *statusMessage;
@property(nonatomic, strong) NSString *host;
@property(nonatomic, strong) SLSResource *resource;
@property(nonatomic, strong) NSString *service;
@property(nonatomic, strong) NSString *sessionId;
@property(nonatomic, strong) NSString *transactionId;
@property(atomic, assign, readonly) BOOL isEnd;
@property(atomic, assign, readonly) BOOL isGlobal;

- (instancetype) setParent: (SLSSpan *) parent NS_SWIFT_NAME(setParnet(_:));

/// Add SLSAttributes to SLSSpan
/// @param attribute SLSAttribute
- (SLSSpan *) addAttribute:(SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addAttributes instead.");

/// Add SLSAttributes to SLSSpan.
/// @param attributes SLSAttribute array.
- (SLSSpan *) addAttributes:(NSArray<SLSAttribute*> *)attributes NS_SWIFT_NAME(addAttributes(_:));

/// Add SLSResource to current SLSSpan.
/// @param resource SLSResource
- (SLSSpan *) addResource: (SLSResource *) resource;

- (SLSSpan *) addEvent:(NSString *)name;
- (SLSSpan *) addEvent:(NSString *)name attribute: (SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION;
- (SLSSpan *) addEvent:(NSString *)name attributes:(NSArray<SLSAttribute *> *)attributes;

- (SLSSpan *) addLink: (SLSLink *)link, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addLinks instead.");
- (SLSSpan *) addLinks: (NSArray<SLSLink *> *)links NS_SWIFT_NAME(addLinks(_:));

- (SLSSpan *) recordException:(NSException *)exception NS_SWIFT_NAME(recordException(_:));
- (SLSSpan *) recordException:(NSException *)exception attribute: (SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use recordException(_:attributes) instead.");
- (SLSSpan *) recordException:(NSException *)exception attributes:(NSArray<SLSAttribute *> *)attribute NS_SWIFT_NAME(recordException(_:attributes:));
/// End current SLSSpan
- (BOOL) end;

/// Convert current SLSSpan to NSDictionary
- (NSDictionary<NSString*, NSString*> *) toDict;

- (SLSSpan *) setGlobal: (BOOL) global;

- (SLSSpan *) setScope: (void (^)(void)) scope;

@end

NS_ASSUME_NONNULL_END
