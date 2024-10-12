//
//  MTMDraggableViewControllerBase.h
//  libmitamaui
//
//  Created by Chengming Liao on 7/29/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MTMDraggableCallback)(void);

@interface MTMDraggableViewControllerBase : UIViewController

- (void)setParentConstraintsWithCenterX:(NSLayoutConstraint *)x
                                centerY:(NSLayoutConstraint *)y
                                  width:(NSLayoutConstraint *)w
                                 height:(NSLayoutConstraint *)h;

- (void)resizeHandler;

@property (nonatomic) UIView *draggableView;
@property (nonatomic) UIView *resizeTargetView;
@property (nonatomic, assign) BOOL canResizeVertically;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;

@end

NS_ASSUME_NONNULL_END
