//
//  WPKThreadBlockChecker.h
//  KSCrash
//
//  Created by li on 2020/12/4.
//  Copyright © 2020 Karl Stenerud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WPKThreadBlockCheckerDelegate <NSObject>
@required
/* @brief 检测到一次卡顿
 * @param blockTime 卡顿的时长
 */
- (void)onMainThreadBlockedWithBlockInterval:(NSTimeInterval)blockInterval;

/* @biref 检测持续发生卡顿（第一次卡顿后，下个检测心跳又一次触发卡顿）。可以在这里做些统计等。
 */
- (void)onMainThreadKeepOnBlocking;

/* @brief 心跳正常。两种情况表示正常：1、心跳正常（主线程正常）； 2、APP被置入后台。
 */
- (void)onMainThreadStayHealthy:(BOOL)mainThreadRespond;

/* @brief 重新启动一轮心跳检测（卡顿计数重置）。
 */
- (void)onMainThreadCheckingReset;

@end


#pragma mark -
@interface WPKThreadBlockCheckerConfig : NSObject
//@param
/* @brief 发送检测心跳的时间间隔。单位：秒。*/
@property (nonatomic, assign) float sendBeatInterval;

/* @brief 检测卡顿的时间间隔 单位是秒。 （发送心跳后checkBeatInterval秒进行检测）*/
@property (nonatomic, assign) float checkBeatInterval;
 
/* @brief 连续多少次没心跳 认为触发卡顿。*/
@property (nonatomic, assign) NSInteger toleranceBeatMissingCount;

@end


#pragma mark -
@interface WPKThreadBlockChecker: NSObject

@property (nonatomic, weak) id<WPKThreadBlockCheckerDelegate> delegate;

- (instancetype)initWithDelegate:(id<WPKThreadBlockCheckerDelegate>)delegate;

/* @brief 启动卡顿检测。
 * @param config 参见WPKThreadBlockCheckerConfig的属性说明
 */
- (void)startWithConfig:(WPKThreadBlockCheckerConfig *)config;

@end
