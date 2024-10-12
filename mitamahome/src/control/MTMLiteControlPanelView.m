//
//  MTMLiteControlPanelView.m
//  libmitamaui
//
//  Created by Chengming Liao on 7/2/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMLiteControlPanelView.h"

#import "MTMLayout.h"

@interface MTMLiteControlButton : UIControl
+ (instancetype)newWithColor:(UIColor *)color title:(NSString *)title;
- (void)setColor:(UIColor *)color title:(NSString *)title;
@end

@implementation MTMLiteControlButton
{
  UILabel *_label;
}

+ (instancetype)newWithColor:(UIColor *)color title:(NSString *)title
{
  MTMLiteControlButton *c = [[MTMLiteControlButton alloc] initWithFrame:CGRectZero];
  if (c) {
    c->_label = [UILabel new];
    c->_label.textColor = UIColor.whiteColor;
    c->_label.text = title;
    c->_label.translatesAutoresizingMaskIntoConstraints = NO;
    [c addSubview:c->_label];
    MTMActivateLayout(MTMMatchCenterX(c->_label, c, 0),
                      MTMMatchCenterY(c->_label, c, 0));

    c.backgroundColor = color;
    c.layer.cornerRadius = 12.f;
    c.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return c;
}

- (void)setColor:(UIColor *)color title:(NSString *)title
{
  self.backgroundColor = color;
  _label.text = title;
  [self setNeedsLayout];
}

@end

@implementation MTMLiteControlPanelView
{
  MTMLiteControlTapAction _tapAction;

  // A horizontal stack of 3 views

  // PlayToggle  ReadBranch  ViewConsole Status
  MTMLiteControlButton *_autoToggle;
  MTMLiteControlButton *_readBranchBtn;
  MTMLiteControlButton *_viewConsoleBtn;
  MTMLiteControlButton *_statusBtn;

  // SpeedUp AdvancedDiscView AdvancedMetaView MirrorHelper
  MTMLiteControlButton *_speedupBtn;
  MTMLiteControlButton *_advDiscBtn;
  MTMLiteControlButton *_advMetadataBtn;
  MTMLiteControlButton *_mirrorHelperBtn;
}

static MTMLiteControlButton *_BuildControlView(UIColor *color, NSString *text, MTMLiteControlPanelView *host)
{
  MTMLiteControlButton *c = [MTMLiteControlButton newWithColor:color title:text];
  [c addTarget:host action:@selector(_didTap:) forControlEvents:UIControlEventTouchUpInside];
  return c;
}


- (instancetype)initWithFrame:(CGRect)frame
                    tapAction:(MTMLiteControlTapAction)tapAction
{
  if (self = [super initWithFrame:frame]) {
    _tapAction = tapAction;
    // First Row
    _autoToggle = _BuildControlView(RGBA(66.0, 245.0, 147.0, 0.9), @"Toggle Autoplay", self);
    _readBranchBtn = _BuildControlView(RGBA(48, 126, 252, 0.9), @"Quick Settings", self);
    _viewConsoleBtn = _BuildControlView(RGBA(0, 0, 0, 0.7), @"Open Console", self);
    _statusBtn = _BuildControlView(RGBA(105, 79, 255, 0.9), @"Status", self);

    // Second Row
    _speedupBtn = _BuildControlView(RGBA(31, 30, 51, 0.9), @"Toggle SpeedUp", self);
    _advDiscBtn = _BuildControlView(RGBA(156, 31, 116, 0.9), @"[Adv] Disc", self);
    _advMetadataBtn = _BuildControlView(RGBA(29, 116, 173, 0.9), @"[Adv] Metadata", self);
    _mirrorHelperBtn = _BuildControlView(RGBA(170, 69, 237, 0.9), @"[Adv] NewMeta", self);

    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_autoToggle];
    [self addSubview:_readBranchBtn];
    [self addSubview:_viewConsoleBtn];
    [self addSubview:_statusBtn];

    [self addSubview:_speedupBtn];
    [self addSubview:_advDiscBtn];
    [self addSubview:_advMetadataBtn];
    [self addSubview:_mirrorHelperBtn];

    NSArray<NSLayoutConstraint *> *constrains = @[
      // First Row
      MTMMatchLeft(_autoToggle, self, 16.f),
      MTMMatchTop(_autoToggle, self, 12.f),
      MTMMatchHeight(_readBranchBtn, _autoToggle, 1),
      MTMMatchHeight(_viewConsoleBtn, _autoToggle, 1),
      MTMMatchHeight(_statusBtn, _autoToggle, 1),
      MTMMatchTop(_readBranchBtn, _autoToggle, 0),
      MTMMatchTop(_viewConsoleBtn, _autoToggle, 0),
      MTMMatchTop(_statusBtn, _autoToggle, 0),
      MTMConstraintRightFlexShrink(_readBranchBtn, _autoToggle, 64.f),
      MTMConstraintRightFlexShrink(_viewConsoleBtn, _readBranchBtn, 64.f),
      MTMConstraintRightFlexShrink(_statusBtn, _viewConsoleBtn, 64.f),
      MTMMatchRight(_statusBtn, self, 16.f),
      MTMMatchWidth(_autoToggle, _viewConsoleBtn, 1),
      MTMMatchWidth(_readBranchBtn, _viewConsoleBtn, 1),
      MTMMatchWidth(_statusBtn, _viewConsoleBtn, 1),
      MTMSetHeight(_autoToggle, 84.f),
      // Second Row
      MTMConstraintBelow(_speedupBtn, _autoToggle, 36.f),
      MTMMatchLeft(_speedupBtn, self, 16.f),
      MTMMatchBottom(_speedupBtn, self, 12.f),
      MTMMatchHeight(_speedupBtn, _autoToggle, 1),
      MTMMatchHeight(_advDiscBtn, _speedupBtn, 1),
      MTMMatchHeight(_advMetadataBtn, _speedupBtn, 1),
      MTMMatchHeight(_mirrorHelperBtn, _speedupBtn, 1),
      MTMMatchTop(_advDiscBtn, _speedupBtn, 0),
      MTMMatchTop(_advMetadataBtn, _speedupBtn, 0),
      MTMMatchTop(_mirrorHelperBtn, _speedupBtn, 0),
      MTMConstraintRightFlexShrink(_advDiscBtn, _speedupBtn, 64.f),
      MTMConstraintRightFlexShrink(_advMetadataBtn, _advDiscBtn, 64.f),
      MTMConstraintRightFlexShrink(_mirrorHelperBtn, _advMetadataBtn, 64.f),
      MTMMatchRight(_mirrorHelperBtn, self, 16.f),
      MTMMatchWidth(_advMetadataBtn, _speedupBtn, 1),
      MTMMatchWidth(_advDiscBtn, _speedupBtn, 1),
      MTMMatchWidth(_mirrorHelperBtn, _speedupBtn, 1)
    ];
    MTMActivateLayoutArray(constrains);
  }
  return self;
}

- (void)_didTap:(id)sender
{
  if (!_tapAction) {
    return;
  }

  if (sender == _autoToggle) {
    _tapAction(1, nil);
  } else if (sender == _readBranchBtn) {
    _tapAction(2, nil);
  } else if (sender == _viewConsoleBtn) {
    _tapAction(3, nil);
  } else if (sender == _speedupBtn) {
    _tapAction(4, nil);
  } else if (sender == _advDiscBtn) {
    _tapAction(5, nil);
  } else if (sender == _advMetadataBtn) {
    _tapAction(6, nil);
  }
}

@end
