//
//  SLSCrashReporter.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/7/20.
//

#import "SLSCrashReporter.h"

@interface SLSCrashReporter ()
@property(nonatomic, strong) SLSCrashReporterFeature *feature;

@end

@implementation SLSCrashReporter
+ (instancetype) sharedInstance {
    static SLSCrashReporter * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[SLSCrashReporter alloc] init];
    });
    return ins;
}

- (void) setCrashReporterFeature: (SLSCrashReporterFeature *) feature {
    _feature = feature;
}

- (void) addCustomError: (NSString *) eventId properties: (NSDictionary<NSString*, NSString*> *) properties {
    if (!_feature) {
        return;
    }
    if (!eventId || eventId.length <= 0) {
        return;
    }
    if (!properties) {
        return;
    }
    
    [_feature addCustom:eventId properties:properties];
}
@end
