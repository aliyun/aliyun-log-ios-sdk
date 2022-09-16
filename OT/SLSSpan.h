//
//  SLSSpan.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSResource.h"

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
@property(nonatomic, assign) SLSStatusCode statusCode;
@property(nonatomic, strong) NSString *statusMessage;
@property(nonatomic, strong) NSString *host;
@property(nonatomic, strong) SLSResource *resource;
@property(nonatomic, strong) NSString *service;
@property(nonatomic, strong) NSString *sessionId;
@property(nonatomic, strong) NSString *transactionId;
@property(atomic, assign, readonly) BOOL isEnd;


/// Add SLSAttributes to SLSSpan
/// @param attribute SLSAttribute
- (void) addAttribute:(SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION NS_SWIFT_UNAVAILABLE("use addAttributes instead.");

/// Add SLSAttributes to SLSSpan.
/// @param attributes SLSAttribute array.
- (void) addAttributes:(NSArray<SLSAttribute*> *)attributes NS_SWIFT_NAME(addAttributes(_:));

/// Add SLSResource to current SLSSpan.
/// @param resource SLSResource
- (void) addResource: (SLSResource *) resource;

/// End current SLSSpan
- (BOOL) end;

/// Convert current SLSSpan to NSDictionary
- (NSDictionary<NSString*, NSString*> *) toDict;

@end

NS_ASSUME_NONNULL_END
