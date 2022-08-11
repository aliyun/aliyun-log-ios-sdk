//
//  SLSResource.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/4/27.
//

#import "SLSResource.h"
#import "Utdid.h"
#import "SLSDeviceUtils.h"
#import "HttpConfigProxy.h"
#import "SLSKeyValue.h"

@interface SLSResource()

@end

static SLSResource *DEFAULT = nil;

@implementation SLSResource

+ (void)initialize
{
    if (!DEFAULT) {
        DEFAULT = [[SLSResource alloc] init];
        [DEFAULT add:@"sdk.language" value:@"Objective-C"];
        [DEFAULT add:@"host.name" value:@"iOS"];
        
        // device specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/device.md
        [DEFAULT add:@"device.id" value:[Utdid getUtdid]];
        [DEFAULT add:@"device.model.identifier" value:[SLSDeviceUtils getDeviceModelIdentifier]];
        [DEFAULT add:@"device.model.name" value:[SLSDeviceUtils getDeviceModelIdentifier]];
        [DEFAULT add:@"device.manufacturer" value:@"Apple"];
        [DEFAULT add:@"device.resolution" value:[SLSDeviceUtils getResolution]];
        
        // os specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/os.md
        NSString *systemName = [[UIDevice currentDevice] systemName];
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        [DEFAULT add:@"os.type" value: @"darwin"];
        [DEFAULT add:@"os.description" value: [NSString stringWithFormat:@"%@ %@", systemName, systemVersion]];
        [DEFAULT add:@"os.name" value: @"iOS"];
        [DEFAULT add:@"os.version" value: systemVersion];
        [DEFAULT add:@"os.root" value: [SLSDeviceUtils isJailBreak]];
    //        @"os.sdk": [[TelemetryAttributeValue alloc] initWithStringValue:@"iOS"],
        
        // host specification, ref: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/host.md
        [DEFAULT add:@"host.name" value: @"iOS"];
        [DEFAULT add:@"host.type" value: systemName];
        [DEFAULT add:@"host.arch" value: [SLSDeviceUtils getCPUArch]];
        
        [DEFAULT add:@"sls.sdk.language" value: @"Objective-C"];
        [DEFAULT add:@"sls.sdk.name" value: @"tracesdk"];
        [DEFAULT add:@"sls.sdk.version" value: [[HttpConfigProxy sharedInstance] getVersion]];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        if (!appName) {
            appName = [infoDictionary objectForKey:@"CFBundleName"];
        }
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *buildCode = [infoDictionary objectForKey:@"CFBundleVersion"];
        
        [DEFAULT add:@"app.version" value:(!appVersion ? @"-" : appVersion)];
        [DEFAULT add:@"app.build_code" value:(!buildCode ? @"-" : buildCode)];
        [DEFAULT add:@"app.name" value:(!appName ? @"-" : appName)];
        
        [DEFAULT add:@"net.access" value: [SLSDeviceUtils getNetworkTypeName]];
        [DEFAULT add:@"net.access_subtype" value: [SLSDeviceUtils getNetworkSubTypeName]];
        [DEFAULT add:@"carrier" value: [SLSDeviceUtils getCarrier]];
        
    }
}

+ (instancetype) resource {
    return [[SLSResource alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        _attributes = [NSMutableArray array];
    }
    return self;
}

- (void) add: (NSString *)key value: (NSString *)value {
    NSMutableArray<SLSAttribute*> *array = (NSMutableArray<SLSAttribute*>*) _attributes;
    [array addObject:[SLSAttribute of:key value:value]];
}

- (void) add: (NSArray<SLSAttribute *> *)attributes {
    NSMutableArray<SLSAttribute*> *array = (NSMutableArray<SLSAttribute*>*) _attributes;
    [array addObjectsFromArray:attributes];
}

- (void) merge: (SLSResource *)resource {
    if (!resource || !resource.attributes) {
        return;
    }
    
    NSMutableArray<SLSAttribute*> *array = (NSMutableArray<SLSAttribute*>*) _attributes;
    [array addObjectsFromArray:resource.attributes];
}

+ (SLSResource*) of: (NSString *)key value: (NSString *)value {
    SLSResource *resource = [[SLSResource alloc] init];
    [resource add:key value:value];
    return resource;
}

+ (SLSResource*) of: (SLSKeyValue*)keyValue, ...NS_REQUIRES_NIL_TERMINATION {
    SLSResource *resource = [[SLSResource alloc] init];
    [resource add:keyValue.key value:keyValue.value];
    
    va_list args;
    SLSKeyValue *arg;
    va_start(args, keyValue);
    while ((arg = va_arg(args, SLSKeyValue*))) {
        [resource add:arg.key value:arg.value];
    }
    va_end(args);
    
    return resource;
}
+ (SLSResource *) ofAttributes: (NSArray<SLSAttribute *> *)attributes {
    SLSResource *resource = [SLSResource resource];
    NSMutableArray<SLSAttribute *> *attrs = (NSMutableArray<SLSAttribute *> *) resource.attributes;
    [attrs addObjectsFromArray:attributes];
    return resource;
}

+ (SLSResource*) getDefault {
    return [DEFAULT copy];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SLSResource *r = [SLSResource resource];
    r.attributes = [NSMutableArray arrayWithArray:self.attributes];
    return r;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    SLSResource *r = [SLSResource resource];
    r.attributes = [NSMutableArray arrayWithArray:self.attributes];
    return r;
}

@end
