//
//  DemoUtils.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/17.
//

#import "DemoUtils.h"

@implementation DemoUtils

+ (instancetype)sharedInstance {
    static DemoUtils * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[DemoUtils alloc] init];
    });
    return ins;
}
@end
