//
//  HttpConfigProxy.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/12/21.
//

#import "HttpConfigProxy.h"

@interface HttpConfigProxy ()
@end

@implementation HttpConfigProxy

+ (instancetype)sharedInstance {
    static HttpConfigProxy * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[HttpConfigProxy alloc] init];
    });
    return ins;
}

- (instancetype)init {
    self = [super init];
    if (self) {
#if __has_include("LogProducerClient+Bricks.h")
        _userAgent = [NSString stringWithFormat:@"sls-ios-sdk/%@", [NSString stringWithFormat:@"bricks_%@", [self  getVersion]]];
#else
        _userAgent = [NSString stringWithFormat:@"sls-ios-sdk/%@", [self  getVersion]];
#endif
    }
    return self;
}

- (NSString *) getVersion {
    return [[[NSBundle bundleForClass:HttpConfigProxy.self] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (void) addPluginUserAgent: (NSString *) key value: (NSString *) value {
    _userAgent = [NSString stringWithFormat:@"%@;%@/%@", _userAgent, key, value];
}

@end
