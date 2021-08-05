//
//  AliyunLog.h
//  AliyunLogProducer
//
//  Created by lichao on 2020/9/27.
//  Copyright © 2020 lichao. All rights reserved.
//

#ifndef AliyunLog_h
#define AliyunLog_h


#endif /* Log_h */

@interface AliyunLog : NSObject
{
    @package unsigned int logTime;
    @package NSMutableDictionary *content;
}

- (void)PutContent:(NSString *) key value:(NSString *)value;

- (NSMutableDictionary *) getContent;

- (void)SetTime:(unsigned int) logTime;

- (unsigned int) getTime;

@end
