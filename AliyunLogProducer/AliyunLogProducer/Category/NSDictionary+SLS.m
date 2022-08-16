//
//  NSDictionary+SLS.m
//  AliyunLogProducer
//
//  Created by gordon on 2022/8/16.
//

#import "NSDictionary+SLS.h"

@implementation NSDictionary (SLS)
+ (NSDictionary *) dictionaryWithNSString: (NSString *) string {
    if (!string) {
        return nil;
    }
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error
    ];
    if (!error) {
        return nil;
    }
    
    return dict;
}
@end
