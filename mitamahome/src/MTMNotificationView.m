//
//  MTMNotificationView.m
//  libmitamaui
//
//  Created by Chengming Liao on 8/2/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMNotificationView.h"

#import "MTMLayout.h"

@implementation MTMNotificationView
{
  UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _label = [UILabel new];
    _label.textColor = UIColor.whiteColor;
    _label.numberOfLines = 0;
    _label.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightSemibold];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_label];
    MTMActivateLayoutArray(MTMInsetView(_label, self, UIEdgeInsetsMake(4.f, 24.f, 4.f, 24.f)));
    self.layer.cornerRadius = 12.f;
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
}

- (void)setText:(NSString *)text
{
  _text = text;
  _label.text = text;
}

- (void)setTextColor:(UIColor *)textColor
{
  _textColor = textColor;
  _label.textColor = textColor;
}

@end
