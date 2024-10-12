//
//  MTMLiteControlViewController.h
//  libmitamaui
//
//  Created by Chengming Liao on 7/2/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTMDraggableViewControllerBase.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MTMLiteControlCommitAction)(NSInteger, id _Nullable);

@interface MTMLiteControlViewController : MTMDraggableViewControllerBase

- (instancetype)initWithAction:(MTMLiteControlCommitAction)action;

@end

NS_ASSUME_NONNULL_END
