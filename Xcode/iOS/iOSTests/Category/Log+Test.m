//
//  Log+Test.m
//  iOSTests
//
//  Created by gordon on 2022/6/17.
//

#import "Log+Test.h"

@implementation Log (Test)
- (void) remove: (NSString *)key {
    [self.getContent removeObjectForKey:key];
}
- (void) clear {
    [self.getContent removeAllObjects];
}
@end
