//
//  IdGenerator.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSIdGenerator.h"
#include <stdlib.h>
#import <limits.h>

static const long INVALID_ID = 0;

@implementation SLSIdGenerator

+ (NSString *) generateTraceId {
    int idHi = 0;
    int idLo = 0;
    do {
        idHi = arc4random_uniform(INT_MAX);
        idLo = arc4random_uniform(INT_MAX);
    } while( idHi == INVALID_ID || idLo == INVALID_ID);
    
    return [NSString stringWithFormat:@"%016d%016d", idHi, idLo];
}

+ (NSString *) generateSpanId {
    int idid = 0;
    do {
        idid = arc4random_uniform(INT_MAX);
    } while( idid == INVALID_ID);
    
    return [NSString stringWithFormat:@"%016d", idid];
}

@end
