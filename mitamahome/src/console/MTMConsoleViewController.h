//
//  MTMConsoleViewController.h
//  libmitamaui
//
//  Created by Chengming Liao on 6/28/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTMDraggableViewControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTMConsoleViewController : MTMDraggableViewControllerBase

- (void)reload;
- (void)invalidateLayout;

@property (nonatomic, readonly) UIView *resizeView;

@end

NS_ASSUME_NONNULL_END
