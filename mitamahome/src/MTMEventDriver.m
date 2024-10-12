//
//  MTMEventDriver.m
//  libmitamaui
//
//  Created by Chengming Liao on 7/4/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMEventDriver.h"

#import "MTMRecord.h"
#import "MTMPreference.h"
#import "MTMUIStore.h"

#import "MTMSceneRecognizer.h"
#import "MTMGameActuator.h"

@implementation MTMEventDriver
{
  NSTimer *_currentEventLoop;
  NSTimer *_speedupEventLoop;
}

+ (instancetype)get
{
  static MTMEventDriver *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    shared = [[MTMEventDriver alloc] init];
  });
  return shared;
}

// Main event driver

- (CGFloat)getLoopInterval
{
  return [[MTMPreference get] getNumberValueForKey:@"timer"].floatValue;
}

- (void)start
{
  CGFloat timerInterval = [self getLoopInterval];
  if (timerInterval <= 1.0f) {
    [[MTMRecord get] record:@"[driver] ignored invalid time interval %f.", timerInterval];
    return;
  }
  [[MTMRecord get] record:@"[driver] starting main driver: interval %f.", timerInterval];
  if (_currentEventLoop) {
    [_currentEventLoop invalidate];
  }
  __weak __typeof(self) weakSelf = self;
  _currentEventLoop =
  [NSTimer scheduledTimerWithTimeInterval:[self getLoopInterval]
                                  repeats:YES
                                    block:^(NSTimer * _Nonnull timer) {
    [weakSelf execute];
  }];
}

- (void)stop
{
  [[MTMRecord get] record:@"[driver] stop main driver."];
  [_currentEventLoop invalidate];
  _currentEventLoop = nil;
}

- (BOOL)isActive
{
  return _currentEventLoop != nil;
}

- (void)execute
{
  [MTMSceneRecognizer matchScene:^(MTMSceneName sceneName) {
    MTMActuateGameScene(sceneName);
  }];
}

// Speed up functionality

- (CGFloat)getSpeedupInterval
{
  return [[MTMPreference get] getNumberValueForKey:@"speedup"].floatValue;
}

- (void)speedup
{
  [[MTMRecord get] record:@"[driver] starting speedup."];
  CGFloat interval = [self getSpeedupInterval];
  if (interval <= 0.01f) {
    [[MTMRecord get] record:@"[driver] ignored invalid speedup interval %f.", interval];
    return;
  }
  if (_speedupEventLoop) {
    [_speedupEventLoop invalidate];
  }
  __weak __typeof(self) weakSelf = self;
  _speedupEventLoop =
  [NSTimer scheduledTimerWithTimeInterval:interval
                                  repeats:YES
                                    block:^(NSTimer * _Nonnull timer) {
    [weakSelf doSpeedup];
  }];
}

- (void)stopSpeedup
{
  [[MTMRecord get] record:@"[driver] stop speedup."];
  [_speedupEventLoop invalidate];
  _speedupEventLoop = nil;
}

- (BOOL)isSpeedupActive
{
  return _speedupEventLoop != nil;
}

- (void)doSpeedup
{
  [[MTMUIStore get].rootView setNeedsLayout];
}

@end
