//
//  SLSSpanExporter.m
//  AliyunLogProducer
//
//  Created by gordon on 2021/8/17.
//  Copyright © 2021 lichao. All rights reserved.
//

#import "SLSSpanExporter.h"
#import "HttpConfigProxy.h"
#import "OpenTelemetrySdk/OpenTelemetrySdk-Swift.h"
#import "AliyunLogProducer/AliyunLogProducer.h"

@interface SLSSpanExporter () <TelemetrySpanExporter>
@property(nonatomic, strong) LogProducerClient *client;
@property(nonatomic, strong) LogProducerConfig *config;
@property(nonatomic, strong) SLSConfig *slsConfig;

- (Log *) spanToLog: (TelemetrySpanData *)span;
- (NSArray *) linksToArray: (NSArray<TelemetryLink *> *) links;
- (NSDictionary *) eventsToArray: (NSArray<TelemetryEvent *> *)events;
- (NSDictionary *) attributeToDictionaray: (NSDictionary<NSString *, TelemetryAttributeValue *> *) attributes;
- (NSDictionary *) contextToDictionaray: (TelemetrySpanContext *) context;
- (NSString *) toJSON: (NSObject *) data;
- (NSTimeInterval) toTime: (NSDate *) date;
- (NSString *) toTimeStringValue: (NSDate *) date;
- (NSDictionary *) resourceToDictionary: (TelemetryResource *)resource;
@end

@implementation SLSSpanExporter

- (void) initWithSLSConfig: (SLSConfig *)slsConfig {
    _slsConfig = slsConfig;
    
    NSString *endpoint = slsConfig.traceEndpoint;
    NSString *logproject = slsConfig.traceLogproject;
    NSString *logstore = slsConfig.traceLogstore;

    if (!endpoint && !logproject && !logstore) {
        endpoint = slsConfig.endpoint;
        logproject = slsConfig.pluginLogproject;
        logstore = slsConfig.pluginLogstore;

        SLSLog(@"SLSSpanExporter init. use global SLSConfig project configuration.");
    }
    
    self.config = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:logproject logstore:logstore accessKeyID:slsConfig.accessKeyId accessKeySecret:slsConfig.accessKeySecret securityToken:slsConfig.securityToken];

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

    self.client = [[LogProducerClient alloc] initWithLogProducerConfig:self.config callback:_on_log_send_done];
}

- (BOOL) sendDada: (Log *)log {
    LogProducerResult res = [[self client] AddLog:log];
    SLSLogV(@"add trace log res: %ld", (long)res);
    return res == LogProducerOK;
}

- (void) resetSecurityToken:(NSString *)accessKeyId secret:(NSString *)accessKeySecret token:(NSString *)token {
    if ([token length] == 0) {
        [self.config setAccessKeyId:accessKeyId];
        [self.config setAccessKeySecret:accessKeySecret];
    } else {
        [self.config ResetSecurityToken:accessKeyId accessKeySecret:accessKeySecret securityToken:token];
    }
}

- (void) resetProject: (NSString *)endpoint project:(NSString *)project logstore:(NSString *)logstore {
    NSString *_endpoint = _slsConfig.traceEndpoint;
    NSString *_logproject = _slsConfig.traceLogproject;
    NSString *_logstore = _slsConfig.traceLogstore;

    if (!_endpoint && !_logproject && !_logstore) {
        _endpoint = endpoint;
        _logproject = project;
        _logstore = logstore;

        SLSLog(@"SLSSpanExporter resetProject. use global SLSConfig project configuration.");
    }
    
    [self.config setEndpoint:_endpoint];
    [self.config setProject:_logproject];
    [self.config setLogstore:_logstore];
}

- (void) updateConfig: (SLSConfig *)config {
    NSString *_endpoint = _slsConfig.traceEndpoint;
    NSString *_logproject = _slsConfig.traceLogproject;
    NSString *_logstore = _slsConfig.traceLogstore;

    if (!_endpoint && !_logproject && !_logstore) {
        SLSLog(@"SLSSpanExporter updateConfig. use global SLSConfig project configuration.");
        return;
    }
    
    _endpoint = config.endpoint;
    _logproject = config.pluginLogproject;
    _logstore = config.pluginLogstore;
    
    [self.config setEndpoint:_endpoint];
    [self.config setProject:_logproject];
    [self.config setLogstore:_logstore];
}

- (TelemetrySpanExporterResultCode *)exportTelemetrySpanWithSpans:(NSArray<TelemetrySpanData *> *)spans {
    for (TelemetrySpanData *span in spans) {
        Log *log  = [self spanToLog: span];
        [self sendDada:log];
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
    [log PutContent:@"otlp.version" value:[[HttpConfigProxy sharedInstance] getVersion]];

    [log PutContent:@"name" value:[span name]];
    [log PutContent:@"kind" value:[[span kind] name]];
    [log PutContent:@"traceID" value:[span traceId]];
    [log PutContent:@"spanID" value:[span spanId]];
    if ([span parentSpanId]) {
        [log PutContent:@"parentSpanID" value:[span parentSpanId]];
    } else {
        [log PutContent:@"parentSpanID" value:@"0000000000000000"];
    }
    
    if ([span links]) {
        [log PutContent:@"links" value:[self toJSON:[self linksToArray:[span links]]]];
    }

    if ([span events]) {
        [log PutContent:@"logs" value:[self toJSON:[self eventsToArray:[span events]]]];
    }
    

//    if (null != span.getSpanContext()) {
//        put(log, "traceState", traceStateToLog(span.getSpanContext().getTraceState()));
//    }
//    [log PutContent:@"traceState" value:@"{}"];
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

- (NSArray *) linksToArray: (NSArray<TelemetryLink *> *) links {
    NSMutableArray *array = [NSMutableArray array];
    
    for (TelemetryLink *link in links) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[self contextToDictionaray:[link context]] forKey:@"context"];
        [dict setObject: [self attributeToDictionaray:[link attributes]] forKey:@"attributes"];
        [array addObject: dict];
    }
    
    return array;
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

- (NSDictionary *) contextToDictionaray: (TelemetrySpanContext *) context {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[context traceId] forKey:@"traceId"];
    [dict setObject:[context spanId] forKey:@"spanId"];
    [dict setObject:[NSString stringWithFormat:@"%d", [context isRemote]] forKey:@"isRemote"];
    return dict;
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

static void _on_log_send_done(const char * config_name, log_producer_result result, size_t log_bytes, size_t compressed_bytes, const char * req_id, const char * message, const unsigned char * raw_buffer, void * userparams) {
    if (result == LOG_PRODUCER_OK) {
        SLSLogV(@"send trace log success. config: %s, result: %d, log bytes: %d, compressed bytes: %d, request id: %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id);
    } else {
        SLSLogV(@"send trace log fail. config: %s, result: %d, log bytes: %d, compressed bytes: %d, request id: %s, error message : %s", config_name, (result), (int)log_bytes, (int)compressed_bytes, req_id, message);
    }
}
@end
