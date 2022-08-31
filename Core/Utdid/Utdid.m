//
//  Utdid.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/6/1.
//

#import "Utdid.h"
#import "SLSStorage.h"

@interface Utdid ()

@end

@implementation Utdid
+ (NSString *) getUtdid {
    NSString *utdid = [SLSStorage getUtdid];
    if(utdid.length > 0) {
        return utdid;
    }
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [SLSStorage setUtdid:uuid];
    
    return uuid;
}

@end

