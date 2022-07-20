//
//  SLSSpan.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import <Foundation/Foundation.h>
#import "SLSResource.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SLSStatusCode){
    UNSET = 0,
    OK = 1,
    ERROR = 2
};

@interface SLSSpan : NSObject

@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong, readonly) NSString* kind;
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
@property(nonatomic, strong, readonly) NSString *service;
@property(nonatomic, strong) NSString *sessionId;
@property(nonatomic, strong) NSString *transactionId;
@property(atomic, assign) BOOL finished;


- (void) addAttribute:(SLSAttribute *)attribute, ... NS_REQUIRES_NIL_TERMINATION;
- (void) addAttributes:(NSArray<SLSAttribute*> *)attributes;
- (BOOL) end;
- (NSDictionary<NSString*, NSString*> *) toDict;

@end

NS_ASSUME_NONNULL_END
