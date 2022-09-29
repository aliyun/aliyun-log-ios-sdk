//
//  Utdid.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/6/1.
//

#import "Utdid.h"
#import "Storage.h"

@interface Utdid ()

@end

@implementation Utdid
+ (NSString *) getUtdid {
    NSString *utdid = [Storage getUtdid];
    if(utdid) {
        return utdid;
    }
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [Storage setUtdid:uuid];
    
    return uuid;
}

@end

