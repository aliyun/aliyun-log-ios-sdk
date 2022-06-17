//
//  Log.h
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#ifndef Log_h
#define Log_h


#endif /* Log_h */

@interface Log : NSObject

+ (instancetype) log;

- (void) PutContent: (NSString *) key value: (NSString *) value;
- (void) putContent: (NSString *) key value: (NSString *) value;
- (void) putContent: (NSString *) key intValue: (int) value;
- (void) putContent: (NSString *) key longValue: (long) value;
- (void) putContent: (NSString *) key longlongValue: (long long) value;
- (void) putContent: (NSString *) key floatValue: (float) value;
- (void) putContent: (NSString *) key doubleValue: (double) value;
- (void) putContent: (NSString *) key boolValue: (BOOL) value;
- (BOOL) putContent: (NSData *) value;
- (BOOL) putContent: (NSString *) key dataValue: (NSData *) value;
- (BOOL) putContent: (NSString *) key arrayValue: (NSArray *) value;
- (BOOL) putContent: (NSString *) key dictValue: (NSDictionary *) value;
- (BOOL) putContents: (NSDictionary *) dict;

- (NSMutableDictionary *) getContent;

- (void)SetTime:(unsigned int) logTime;

- (unsigned int) getTime;

@end
