//
//  MTMEventDriver.h
//  libmitamaui
//
//  Created by Chengming Liao on 7/4/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTMEventDriver : NSObject

+ (instancetype)get;
- (void)start;
- (void)stop;
- (BOOL)isActive;

- (void)speedup;
- (void)stopSpeedup;
- (BOOL)isSpeedupActive;

@end

NS_ASSUME_NONNULL_END
