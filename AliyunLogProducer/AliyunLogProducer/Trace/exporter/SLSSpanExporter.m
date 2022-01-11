//
//  SLSSpanExporter.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/8/17.
//  Copyright © 2021 lichao. All rights reserved.
//

#import "SLSSpanExporter.h"
#import "OpenTelemetrySdk/OpenTelemetrySdk-Swift.h"

@interface SLSSpanExporter () <TelemetrySpanExporter>
@property(nonatomic, strong) LogProducerClient *client;
@property(nonatomic, strong) LogProducerConfig *config;

- (Log *) spanToLog: (TelemetrySpanData *)span;
- (NSDictionary *) eventsToArray: (NSArray<TelemetryEvent *> *)events;
- (NSDictionary *) attributeToDictionaray: (NSDictionary<NSString *, TelemetryAttributeValue *> *) attributes;
- (NSString *) toJSON: (NSObject *) data;
- (NSTimeInterval) toTime: (NSDate *) date;
- (NSString *) toTimeStringValue: (NSDate *) date;
- (NSDictionary *) resourceToDictionary: (TelemetryResource *)resource;
@end

@implementation SLSSpanExporter

- (instancetype)init
{
    if ( self = [super init]) {
        self.config = [[LogProducerConfig alloc] initWithEndpoint:nil project:nil logstore:nil];
        
        [self.config SetTopic:@"trace"];
        [self.config SetPacketLogBytes:(1024 * 1024 * 5)];
        [self.config SetPacketLogCount: 4096];
        [self.config SetMaxBufferLimit:(64*1024*1024)];
        [self.config SetSendThreadCount:1];
        
        [self.config SetPersistent:1];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths lastObject] stringByAppendingString:@"/trace_log.dat"];
        [self.config SetPersistentFilePath:path];
        [self.config SetPersistentForceFlush:0];
        [self.config SetPersistentMaxFileCount:10];
        [self.config SetPersistentMaxFileSize:(1024*1024*10)];
        [self.config SetPersistentMaxLogCount:65536];
        [self.config SetDropDelayLog:0];
        [self.config SetDropUnauthorizedLog:0];
        
        self.client = [[LogProducerClient alloc] initWithLogProducerConfig:self.config];
    }
    return self;
}
- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    if ([token length] == 0) {
        [self.config setAccessKeyId:accessKeyId];
        [self.config setAccessKeySecret:accessKeySecret];
    } else {
        [self.config ResetSecurityToken:accessKeyId accessKeySecret:accessKeySecret securityToken:token];
    }
}

- (void) resetProject: (NSString*)endpoint project: (NSString *)project logstore:(NSString *)logstore {
    [self.config setEndpoint:endpoint];
    [self.config setProject:project];
    [self.config setLogstore:logstore];
}

- (TelemetrySpanExporterResultCode *)exportTelemetrySpanWithSpans:(NSArray<TelemetrySpanData *> *)spans {
    for (TelemetrySpanData *span in spans) {
        Log *log  = [self spanToLog: span];
        for (id key in [log getContent]) {
            NSLog(@"test. key: %@, value: %@", key, [[log getContent] objectForKey:key]);
        }
        
        LogProducerResult res = [[self client] AddLog:log];
        NSLog(@"test. %ld", res);
       
    }
    // TODO force success
    return [[TelemetrySpanExporterResultCode alloc] init:@"success"];
}

- (TelemetrySpanExporterResultCode *)flushTelemetrySpan {
    return [[TelemetrySpanExporterResultCode alloc] init:@"success"];
}

- (void)shudownTelemetrySpan {
    
}

- (Log *)spanToLog:(TelemetrySpanData *)span {
    Log *log = [[Log alloc] init];
    
    if ([span resource]) {
        TelemetryResource *resource = [span resource];
        TelemetryAttributeValue *host = [[resource attributes] objectForKey:@"host.name"];
        if (host) {
            [log PutContent:@"host" value:host.value];
        }
        
        TelemetryAttributeValue *service = [[resource attributes] objectForKey:@"service.name"];
        if (service) {
            [log PutContent:@"service" value:service.value];
        }
        
        [log PutContent:@"resource" value:[self toJSON:[self resourceToDictionary:resource]]];
    }
    
    [log PutContent:@"otlp.name" value:@"ios-sdk"];
    [log PutContent:@"otlp.version" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

    [log PutContent:@"name" value:[span name]];
    [log PutContent:@"kind" value:[[span kind] name]];
    [log PutContent:@"traceID" value:[span traceId]];
    [log PutContent:@"spanID" value:[span spanId]];
    if ([span parentSpanId]) {
        [log PutContent:@"parentSpanID" value:[span parentSpanId]];
    } else {
        [log PutContent:@"parentSpanID" value:@"0000000000000000"];
    }
    

//    if (null != span.getLinks()) {
//        put(log, "links", linksToLog(span.getLinks()));
//    }
    [log PutContent:@"links" value:@"[]"];
    if ([span events]) {
        [log PutContent:@"logs" value:[self toJSON:[self eventsToArray:[span events]]]];
    }
    

//    if (null != span.getSpanContext()) {
//        put(log, "traceState", traceStateToLog(span.getSpanContext().getTraceState()));
//    }
    [log PutContent:@"traceState" value:@"{}"];
    [log PutContent:@"start" value:[NSString stringWithFormat:@"%@", [self toTimeStringValue:[span startTime]]]];
    [log PutContent:@"end" value:[NSString stringWithFormat:@"%@", [self toTimeStringValue:[span endTime]]]];
    NSTimeInterval duration = [self toTime:[span endTime]] - [self toTime:[span startTime]];
    [log PutContent:@"duration" value:[NSString stringWithFormat:@"%@", [[NSNumber numberWithLong:duration] stringValue]]];

    if ([span attributes]) {
        [log PutContent:@"attribute" value:[self toJSON:[self attributeToDictionaray:[span attributes]]]];
    }
    
    [log PutContent:@"statusCode" value:span.status.name];
    [log PutContent:@"statusMessage" value:span.status.name];
    return log;
}
- (NSArray *)eventsToArray:(NSArray<TelemetryEvent *> *)events {
    NSMutableArray *array = [NSMutableArray array];
    
    for (TelemetryEvent *event in events) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[event name] forKey:@"name"];
        [dictionary setObject:[NSString stringWithFormat:@"%@", [self toTimeStringValue:[event timestamp]]] forKey:@"epochNanos"];
        [dictionary setObject:[self attributeToDictionaray:[event attributes]] forKey:@"attributes"];
        
        [array addObject:dictionary];
    }
    
    return array;
}

- (NSDictionary *)attributeToDictionaray:(NSDictionary<NSString *, TelemetryAttributeValue *> *) attributes {
    NSMutableDictionary *dictionaray = [NSMutableDictionary dictionary];
    for (NSString *key in attributes) {
        [dictionaray setObject: [[attributes objectForKey:key] value] forKey:key];
    }
    return dictionaray;
}


- (NSString *)toJSON:(NSObject *)data {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
}

- (NSTimeInterval)toTime:(NSDate *)date {
    return [date timeIntervalSince1970] * 1000000;
}

- (NSString *)toTimeStringValue:(NSDate *)date {
    return [[NSNumber numberWithDouble:[self toTime:date]] stringValue];
}

- (NSDictionary *)resourceToDictionary:(TelemetryResource *)resource {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self attributeToDictionaray:resource.attributes]];
    
    [dictionary removeObjectForKey:@"host.name"];
    [dictionary removeObjectForKey:@"service.name"];
    
    return dictionary;
}
@end
