//
//  MTMDraggableViewControllerBase.m
//  libmitamaui
//
//  Created by Chengming Liao on 7/29/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMDraggableViewControllerBase.h"

#import "MTMLayout.h"

@interface MTMDraggableViewControllerBase ()

@end

@implementation MTMDraggableViewControllerBase
{
  NSLayoutConstraint *_x;
  NSLayoutConstraint *_y;
  NSLayoutConstraint *_w;
  NSLayoutConstraint *_h;
}

- (instancetype)init
{
  if (self = [super init]) {
    _canResizeVertically = YES;
    _minWidth = 100;
    _minHeight = 100;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIPanGestureRecognizer *dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_didDrag:)];
  [self.draggableView addGestureRecognizer:dragRecognizer];

  UIPanGestureRecognizer *resizeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_didResize:)];
  [self.resizeTargetView addGestureRecognizer:resizeRecognizer];
}

- (void)setParentConstraintsWithCenterX:(NSLayoutConstraint *)x
                                centerY:(NSLayoutConstraint *)y
                                  width:(NSLayoutConstraint *)w
                                 height:(NSLayoutConstraint *)h
{
  _x = x;
  _y = y;
  _w = w;
  _h = h;
  MTMActivateLayout(x, y, w, h);
}

- (void)_didDrag:(UIPanGestureRecognizer *)sender
{
  CGPoint translation = [sender translationInView:self.view];
    _x.constant += translation.x;
    _y.constant += translation.y;
    [sender setTranslation:CGPointZero inView:self.view];
}

- (void)_didResize:(UIPanGestureRecognizer *)sender
{
  CGPoint translation = [sender translationInView:self.view];
  if (!(translation.x < 0) || _w.constant > _minWidth) {
    _x.constant += translation.x / 2;
    _w.constant += translation.x;
  }
  if (_canResizeVertically) {
    if (!(translation.y < 0) || _h.constant > _minHeight) {
      _y.constant += translation.y / 2;
      _h.constant += translation.y;
    }
  }
  [self.view setNeedsLayout];
  [self resizeHandler];
  [sender setTranslation:CGPointZero inView:self.view];
}

- (void)resizeHandler
{
  NSException *e = [[NSException alloc] initWithName:@"MTMNotImplementedException" reason:@"Cannot use base class directly!" userInfo:nil];
  @throw e;
}

@end
