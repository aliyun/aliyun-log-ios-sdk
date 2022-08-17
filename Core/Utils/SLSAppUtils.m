//
//  SLSAppUtils.m
//  AliyunLogCore
//
//  Created by gordon on 2022/4/28.
//

#import "SLSAppUtils.h"

@implementation SLSAppUtils

+ (instancetype) sharedInstance {
    static SLSAppUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SLSAppUtils alloc] init];
    });
    return instance;
}
@end
