//
//  SLSURLSession.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/16.
//

#import "SLSURLSession.h"

@implementation SLSURLSession
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse *_Nullable*_Nullable)response
                             error:(NSError **)error {
    // ref: https://stackoverflow.com/a/37829399/1760982
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);

    NSError __block *err = NULL;
    NSData __block *data;
    NSURLResponse __block *resp;

    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData* _data, NSURLResponse* _response, NSError* _error) {
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
