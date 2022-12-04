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

/// Put string value to log with NSString key. This method will be removed in the future.
/// @param key NSString
/// @param value BOOL
/// swift compile error, ref: https://stackoverflow.com/questions/52557738/objective-c-framework-used-in-swift-ambiguous-use-of-method-error
- (void) PutContent: (NSString *) key value: (NSString *) value __attribute__((deprecated("use method putContent:value:"))) NS_SWIFT_UNAVAILABLE("deprecated method not available in Swift");

/// Put string value to log with NSString key.
/// @param key NSString
/// @param value BOOL
- (void) putContent: (NSString *) key value: (NSString *) value;

/// Put int value to log with NSString key.
/// @param key NSString
/// @param value BOOL
- (void) putContent: (NSString *) key intValue: (int) value;

/// Put long value to log with NSString key.
/// @param key NSString
/// @param value BOOL
- (void) putContent: (NSString *) key longValue: (long) value;

/// Put long long value to log with NSString key.
/// @param key NSString
/// @param value BOOL
- (void) putContent: (NSString *) key longlongValue: (long long) value;

/// Put float value to log with NSString key.
/// @param key NSString
/// @param value BOOL
- (void) putContent: (NSString *) key floatValue: (float) value;

/// Put double value to log with NSString key.
/// @param key NSString
/// @param value BOOL
- (void) putContent: (NSString *) key doubleValue: (double) value;

/// Put bool value to log with NSString key.
/// @param key NSString
/// @param value BOOL
- (void) putContent: (NSString *) key boolValue: (BOOL) value;

/// Put NSData contents to log. All K-V from this dictionaray will be added to the root node.
/// @param value NSData, must be able to convert to JSON, if not will return NO.
/// @return BOOL YES, put success; NO, put fails.
- (BOOL) putContent: (NSData *) value;

/// Put NSData with key to log. All K-V from this array will be added to the node with the given specified key.
/// @param key NSString
/// @param value NSData, must be able to convert to JSON, if not will return NO.
- (BOOL) putContent: (NSString *) key dataValue: (NSData *) value;

/// Put NSArray with key to log. All K-V from this array will be added to the node with the given specified key.
/// @param key NSString
/// @param value NSArray, must be able to convert to JSON, if not will return NO.
- (BOOL) putContent: (NSString *) key arrayValue: (NSArray *) value;

/// Put NSDictionaray with key to log. All K-V from this dictionaray will be added to the node with the given specified key.
/// @param key NSString
/// @param value NSDictionaray, must be able to convert to JSON, if not will return NO.
- (BOOL) putContent: (NSString *) key dictValue: (NSDictionary *) value;

/// Put NSDictionaray contents to log. All K-V from this dictionaray will be added to the root node.
/// @param dict NSDictionaray, must be able to convert to JSON, if not will return NO.
/// @return BOOL YES, put success; NO, put fails.
- (BOOL) putContents: (NSDictionary *) dict;

- (NSMutableDictionary *) getContent;

/// Should not SetTime directly. This method will be removed in the future.
- (void)SetTime:(unsigned int) logTime;

- (unsigned int) getTime;

@end
