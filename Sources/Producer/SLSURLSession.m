//
//  SLSURLSession.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/16.
//

#import "SLSURLSession.h"
static NSURLSession *sharedURLSession = NULL;
static NSMutableURLRequest *(^sharedBeforeSend)(NSMutableURLRequest *request);
@implementation SLSURLSession
+ (void)setBeforeSend:(NSMutableURLRequest *(^)(NSMutableURLRequest *request))beforeSend {
    sharedBeforeSend = beforeSend;
}
+ (void)setURLSession:(NSURLSession *)session {
    sharedURLSession = session;
}
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                             error:(NSError **)error {
    // ref: https://stackoverflow.com/a/37829399/1760982
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);

    NSError __block *err = NULL;
    NSData __block *data;
    NSURLResponse __block *resp;

    NSURLSession *session = sharedURLSession;
    if (nil == session) {
        session = [NSURLSession sharedSession];
    }
    
    __block NSMutableURLRequest *mutableRequest = (NSMutableURLRequest *)request;
    if (nil != sharedBeforeSend) {
        mutableRequest = sharedBeforeSend(mutableRequest);
    }
    
    [[session dataTaskWithRequest:mutableRequest
                completionHandler:^(NSData* _data, NSURLResponse* _response, NSError* _error) {
        NSLog(@"DEBUGGG, data: %@", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding]);
        resp = _response;
        err = _error;
        data = _data;
        dispatch_group_leave(group);
        
    }] resume];

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    if (response)
    {
        *response = resp;
    }
    if (error)
    {
        *error = err;
    }

    return data;
}
@end
