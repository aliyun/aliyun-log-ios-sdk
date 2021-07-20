//
//  IFileParser.h
//  AliyunLogCrashReporter
//
//  Created by gordon on 2021/5/19.
//

#import <Foundation/Foundation.h>
#import "IReporterSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface IFileParser : NSObject

@property(nonatomic, strong) IReporterSender *sender;
@property(nonatomic, strong) SLSConfig *config;

- (void) initWithSender: (IReporterSender *)sender andSLSConfig: (SLSConfig *)config;
- (void) parseFileWithType: (NSString *) type andFilePath: (NSString *) filePath;
- (void) updateConfig:(SLSConfig *)config;

@end

NS_ASSUME_NONNULL_END
