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
{
    @package NSMutableDictionary *content;
}

- (void)PutContent:(NSString *) key value:(NSString *)value;

@end
