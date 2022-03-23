//
//  SLSNetPolicyBuilder.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/3/22.
//

#import "SLSNetPolicyBuilder.h"

@interface SLSNetPolicyBuilder()
@property(nonatomic, strong) SLSNetPolicy *policy;
@end

@implementation SLSNetPolicyBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        _policy = [[SLSNetPolicy alloc] init];
        _policy.whitelist = [[NSMutableArray alloc] init];
        _policy.methods = [[NSMutableArray alloc] init];
        _policy.destination = [[NSMutableArray alloc] init];
        
        _policy.enable = true;
        _policy.type = @"";
        _policy.version = 1;
        _policy.periodicity = YES;
        _policy.internal = 3 * 60;
        _policy.expiration = [[NSDate date] timeIntervalSince1970] + 7 * 24 * 60 * 60;
        _policy.ratio = 1000;
    }
    return self;
}


- (SLSNetPolicyBuilder *) setEnable: (BOOL) enable {
    _policy.enable = enable;
    return self;
}

- (SLSNetPolicyBuilder *) setType: (NSString *) type {
    _policy.type = type;
    return self;
}

- (SLSNetPolicyBuilder *) setVersion: (int) version {
    _policy.version = version;
    return self;
}

- (SLSNetPolicyBuilder *) setPeriodicity: (BOOL) periodicity {
    _policy.periodicity = periodicity;
    return self;
}

- (SLSNetPolicyBuilder *) setInternal: (int) internal {
    _policy.internal = internal;
    return self;
}

- (SLSNetPolicyBuilder *) setExpiration: (long) expiration {
    _policy.expiration = expiration;
    return self;
}

- (SLSNetPolicyBuilder *) setRatio: (int) ratio {
    _policy.ratio = ratio;
    return self;
}

- (SLSNetPolicyBuilder *) setWhiteList: (NSArray<NSString*> *) whitelist {
    _policy.whitelist = whitelist;
    return self;
}

- (SLSNetPolicyBuilder *) addWhiteList: (NSArray<NSString*> *) whitelist {
    if (!_policy.whitelist) {
        _policy.whitelist = [[NSMutableArray alloc] init];
    }
    [(NSMutableArray<NSString*>*)_policy.whitelist addObjectsFromArray:whitelist];
    return self;
}

- (SLSNetPolicyBuilder *) setMethods: (NSArray<NSString*> *) methods {
    NSMutableArray<NSString*> *array = [[NSMutableArray<NSString*> alloc] init];
    for (NSString* method in methods) {
        [array addObject:[method lowercaseString]];
    }
    _policy.methods = array;
    return self;
}

- (SLSNetPolicyBuilder *) setEnableMtrMethod {
    if ([_policy.methods containsObject:@"mtr"]) {
        return self;
    }
    
    if (!_policy.methods) {
        _policy.methods = [[NSMutableArray alloc] init];
    }
    
    [(NSMutableArray<NSString*>*)_policy.methods addObject:@"mtr"];
    
    return self;
}

- (SLSNetPolicyBuilder *) setEnablePingMethod {
    if ([_policy.methods containsObject:@"ping"]) {
        return self;
    }
    
    if (!_policy.methods) {
        _policy.methods = [[NSMutableArray alloc] init];
    }
    
    [(NSMutableArray<NSString*>*)_policy.methods addObject:@"ping"];
    
    return self;
}

- (SLSNetPolicyBuilder *) setEnableTcpPingMethod {
    if ([_policy.methods containsObject:@"tcpping"]) {
        return self;
    }
    
    if (!_policy.methods) {
        _policy.methods = [[NSMutableArray alloc] init];
    }
    
    [(NSMutableArray<NSString*>*)_policy.methods addObject:@"tcpping"];
    return self;
}

- (SLSNetPolicyBuilder *) setEnableHttpMethod {
    if ([_policy.methods containsObject:@"http"]) {
        return self;
    }
    
    if (!_policy.methods) {
        _policy.methods = [[NSMutableArray alloc] init];
    }
    
    [(NSMutableArray<NSString*>*)_policy.methods addObject:@"http"];
    return self;
}

- (SLSNetPolicyBuilder *) setDestination: (NSArray<SLSDestination*> *) destination {
    _policy.destination = destination;
    return self;
}

- (SLSNetPolicyBuilder *) addDestination: (NSArray<NSString*> *) ips urls: (NSArray<NSString*> *) urls {
    SLSDestination *destination = [[SLSDestination alloc] init];
    [destination setSiteId:@"public"];
    [destination setAz:@"public"];
    [destination setIps:ips];
    [destination setUrls:urls];
    
    if (!_policy.destination) {
        _policy.destination = [[NSMutableArray alloc] init];
    }
    
    [(NSMutableArray<SLSDestination*>*)_policy.destination addObject:destination];
    return self;
}

- (SLSNetPolicy *) create {
    return _policy;
}

@end
