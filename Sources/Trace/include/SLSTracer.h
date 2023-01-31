//
//  SLSTracer.h
//  AliyunLogProducer
//
//  Created by gordon on 2022/9/13.
//

#import <Foundation/Foundation.h>
#import "SLSTraceFeature.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SLSURLSessionInstrumentationDelegate <NSObject>
- (BOOL) shouldInstrument: (NSURLRequest *) request;
- (NSDictionary<NSString *, NSString *> *) injectCustomeHeaders;
@end

@interface SLSTracer : NSObject
/// Returns a SLSSpanBuilder to create and start a new SLSSpan.
/// @param spanName The name of the returned SLSSpan.
+ (SLSSpanBuilder *) spanBuilder: (NSString *) spanName;

/// Returns a started SLSSpan.
/// @param spanName The name of the returned SLSSpan.
+ (SLSSpan *) startSpan: (NSString *) spanName;

/// Returns a started SLSSpan and set it as  the active span in the current context. The current context will end when the active span end.
/// @param spanName The name of the returned SLSSpan.
/// @param active whether or not set the active span in the current context.
+ (SLSSpan *) startSpan: (NSString *) spanName active: (BOOL) active;

/// Start a SLSSpan with a wrapped function block.
/// @param spanName The name of the SLSSpan created around the function block.
/// @param block the function block traced by this newly created SLSSpan.
+ (void) withinSpan: (NSString *) spanName block: (void (^)(void)) block;

/// Start a SLSSpan with a wrapped function block.
/// @param spanName The name of the SLSSpan created around the function block.
/// @param active whethe or not set the active span in the function block context.
/// @param block the function block traced by this newly created SLSSpan.
+ (void) withinSpan: (NSString *) spanName active: (BOOL) active block: (void (^)(void)) block;

/// Start a SLSSpan with a wrapped function block.
/// @param spanName The name of the SLSSpan created around the function block.
/// @param active whethe or not set the active span in the function block context.
/// @param parent the parent SLSSpan the created SLSSpan around the function block.
/// @param block the function block traced by this newly created SLSSpan.
+ (void) withinSpan: (NSString *) spanName active: (BOOL) active parent: (nullable SLSSpan *) parent block: (void (^)(void)) block;

/// Register the NSURLSession instrumentation delegate.
/// @param delegate the NSURLSession instrumetation delegate.
+ (void) registerURLSessionInstrumentationDelegate: (id<SLSURLSessionInstrumentationDelegate>) delegate;
@end

NS_ASSUME_NONNULL_END
