//
//  MTMLiteControlViewController.m
//  libmitamaui
//
//  Created by Chengming Liao on 7/2/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMLiteControlViewController.h"

#import "MTMLiteControlPanelView.h"
#import "MTMLayout.h"
#import "MTMRecord.h"
#import "MTMUIStore.h"

@interface MTMLiteControlViewController ()

@end

@implementation MTMLiteControlViewController
{
  MTMLiteControlPanelView *_contentView;
  UILabel *_titleLabel;
  UIButton *_closeBtn;

  MTMLiteControlCommitAction _callback;
}

- (instancetype)initWithAction:(MTMLiteControlCommitAction)action
{
  if (self = [super init]) {
    _callback = action;
    self.canResizeVertically = NO;
  }
  return self;
}

- (void)loadView
{
  __weak __typeof(self) weakSelf = self;
  _contentView = [[MTMLiteControlPanelView alloc] initWithFrame:CGRectZero tapAction:^(NSInteger type, id _Nullable model) {
    __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    // [[MTMRecord get] record:@"[control] commiting action: %@, model %@", @(type), model];
    strongSelf->_callback(type, nil);
    [strongSelf didTapCloseButton:strongSelf];
  }];
  _contentView.translatesAutoresizingMaskIntoConstraints = NO;
  self.view = [[UIView alloc] initWithFrame:CGRectZero];
  [self.view addSubview:_contentView];
  self.view.backgroundColor = [[UIColor alloc] initWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
  self.view.layer.cornerRadius = 36.f;

  _titleLabel = [UILabel new];
  _titleLabel.textColor = UIColor.blackColor;
  _titleLabel.font = [UIFont systemFontOfSize:36.f weight:UIFontWeightBold];
  _titleLabel.numberOfLines = 1;
  _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  _titleLabel.text = @"Control Panel";
  _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_titleLabel];

  _closeBtn = MTMGenericButtonCreate(@"Close");
  [_closeBtn addTarget:self action:@selector(didTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:_closeBtn];

  MTMActivateLayout(MTMMatchRight(_closeBtn, self.view, 32.f),
                    MTMMatchTop(_closeBtn, self.view, 20.f));

  MTMActivateLayout(MTMMatchLeft(_titleLabel, self.view, 32.f),
                    MTMMatchTop(_titleLabel, self.view, 20.f),
                    );

  MTMActivateLayoutArray(MTMInsetView(_contentView, self.view, UIEdgeInsetsMake(72.f, 16.f, 16.f, 16.f)));

  self.resizeTargetView = [[UIView alloc] initWithFrame:CGRectZero];
  self.resizeTargetView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.resizeTargetView];
  MTMActivateLayout(MTMSetWidth(self.resizeTargetView, 48),
                    MTMSetHeight(self.resizeTargetView, 48),
                    MTMMatchBottom(self.resizeTargetView, self.view, 0),
                    MTMMatchRight(self.resizeTargetView, self.view, 0));

  self.draggableView = self.view;
  self.minWidth = 640;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)didTapCloseButton:(id)sender
{
  self.view.hidden = YES;
}

- (void)resizeHandler
{
  [self.view setNeedsLayout];
}

@end
