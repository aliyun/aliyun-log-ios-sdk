//
//  HttpHeader.m
//  Pods
//
//  Created by gordon on 2022/9/21.
//

#import "SLSHttpHeader.h"
#import "SLSUtils.h"

@implementation SLSHttpHeader
+ (NSArray<NSString *> *) getHeaders: (NSArray<NSString *> *) srcHeaders, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray<NSString *> *headers = [srcHeaders mutableCopy];
#if SLS_HOST_MAC
    NSMutableString *userAgent = [NSMutableString stringWithFormat:@"sls-ios-sdk/%@/macOS", [SLSUtils getSdkVersion]];
#elif SLS_HOST_TV
    NSMutableString *userAgent = [NSMutableString stringWithFormat:@"sls-ios-sdk/%@/tvOS", [SLSUtils getSdkVersion]];
#else
    NSMutableString *userAgent = [NSMutableString stringWithFormat:@"sls-ios-sdk/%@", [SLSUtils getSdkVersion]];
#endif
    
    [userAgent appendString:@";"];
    [headers addObject:@"User-agent"];
    
    va_list args;
    NSString *arg;
    va_start(args, srcHeaders);
    while ((arg = va_arg(args, NSString*))) {
        [userAgent appendString:arg];
        [userAgent appendString:@";"];
    }
    va_end(args);
    
    [headers addObject:[userAgent substringToIndex:userAgent.length-1]];
    return headers;
}
@end
