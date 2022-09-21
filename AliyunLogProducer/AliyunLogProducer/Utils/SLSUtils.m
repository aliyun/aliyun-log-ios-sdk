//
//  SLSUtils.m
//  Pods
//
//  Created by gordon on 2022/9/21.
//

#import "SLSUtils.h"

@implementation SLSUtils
+ (NSString *) getSdkVersion {
    return [[[NSBundle bundleForClass:SLSUtils.class] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
@end
