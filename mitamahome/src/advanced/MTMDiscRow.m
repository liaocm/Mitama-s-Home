//
//  MTMDiscRow.m
//  libmitamaui
//
//  Created by Chengming Liao on 7/25/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMDiscRow.h"

#import "MTMLayout.h"

@implementation MTMDiscRowModel

+ (instancetype)newWithTypes:(NSArray<NSString *> *)types title:(NSUInteger)title enabled:(BOOL)enabled
{
  MTMDiscRowModel *m = [[MTMDiscRowModel alloc] init];
  if (m) {
    m->_discTypes = types;
    m->_title = title;
    m->_enabled = enabled;
  }
  return m;
}

+ (instancetype)defaultModel
{
  return [MTMDiscRowModel newWithTypes:@[@"A", @"Bv", @"Bh", @"Bh", @"C"] title:1 enabled:NO];
}

@end

@implementation MTMDiscRow
{
  UILabel *_title;
  UIControl *_enable;
  UILabel *_enableText;

  NSMutableArray<UIControl *> *_discArr;
  MTMDiscRowModel *_model;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  /**
      | Title |  [Enable/Disable]  [A][A][C][B][B]
   */
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    UILabel *title = [UILabel new];
    title.textColor = UIColor.blackColor;
    title.font = [UIFont systemFontOfSize:36.f weight:UIFontWeightBold];
    title.numberOfLines = 1;
    title.lineBreakMode = NSLineBreakByTruncatingTail;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    _title = title;
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_title];

    _enable = [[UIControl alloc] initWithFrame:CGRectZero];
    _enableText = [UILabel new];
    _enableText.font = [UIFont systemFontOfSize:24.f weight:UIFontWeightRegular];
    [_enable addSubview:_enableText];
    _enableText.translatesAutoresizingMaskIntoConstraints = NO;
    _enable.translatesAutoresizingMaskIntoConstraints = NO;
    MTMActivateLayout(MTMMatchCenterX(_enableText, _enable, 0),
                      MTMMatchCenterY(_enableText, _enable, 0));
    _enable.layer.cornerRadius = 12.f;
    [_enable addTarget:self action:@selector(handleEnableTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_enable];

    MTMActivateLayout(MTMMatchCenterY(title, self, 0),
                      MTMMatchLeft(title, self, 24),
                      MTMSetWidth(title, 30),
                      //MTMMatchLeft(_enable, self, 180),
                      MTMConstraintRight(_enable, title, 64),
                      MTMMatchCenterY(_enable, self, 0),
                      MTMSetHeight(_enable, 60),
                      MTMSetWidth(_enable, 120));

    _discArr = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
      UIControl *disc = DiscControl(self);
      [_discArr addObject:disc];
      [self addSubview:disc];
    }
    MTMActivateLayout(MTMConstraintRight(_discArr[0], _enable, 72),
                      MTMMatchCenterY(_discArr[0], _enable, 0));
    for (int i = 1; i < 5; i++) {
      MTMActivateLayout(MTMConstraintRight(_discArr[i], _discArr[i-1], 24),
                        MTMMatchCenterY(_discArr[i], _discArr[i-1], 0));
    }

    self.model = [MTMDiscRowModel defaultModel];
  }
  return self;
}

// Properties

- (void)reload
{
  for (int i = 0; i < 5; i++) {
    UILabel *label = [self _getLabelForDiscControl:_discArr[i]];
    label.text = _model.discTypes[i];
    _discArr[i].backgroundColor = ColorForDiscModel(_model.discTypes[i]);
  }
  _title.text = @(_model.title).stringValue;
  if (_model.enabled) {
    self.alpha = 1;
    _enableText.text = @"Enabled";
    //117, 255, 120
    _enable.backgroundColor = RGBA(117, 255, 120, 1);
  } else {
    self.alpha = 0.35;
    _enableText.text = @"Disabled";
    _enable.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
  }
}

- (void)setModel:(MTMDiscRowModel *)model
{
  _model = model;
  [self reload];
}

- (void)handleEnableTap:(UIControl *)sender
{
  _model.enabled = !_model.enabled;
  [self reload];
}

- (UILabel *)_getLabelForDiscControl:(UIControl *)control
{
  UILabel *label = nil;
  for (UIView *v in control.subviews) {
    if ([v isKindOfClass:UILabel.class]) {
      label = (UILabel *)v;
      break;
    }
  }
  return label;
}

- (void)handleDiscControlTap:(UIControl *)sender
{
  UILabel *label = [self _getLabelForDiscControl:sender];
  if (!label) {
    return;
  }
  NSInteger idx = 0;
  for (int i = 0; i < 5; i++) {
    if (_discArr[i] == sender) {
      idx = i;
      break;
    }
  }
  NSString *newDiscType = nil;
  if ([label.text isEqualToString:@"A"]) {
    newDiscType = @"Bv";
  } else if ([label.text isEqualToString:@"Bv"]) {
    newDiscType = @"Bh";
  } else if ([label.text isEqualToString:@"Bh"]) {
    newDiscType = @"Bs";
  } else if ([label.text isEqualToString:@"Bs"]) {
    newDiscType = @"Bb";
  } else if ([label.text isEqualToString:@"Bb"]) {
    newDiscType = @"C";
  } else {
    newDiscType = @"A";
  }
  NSMutableArray *currTypes = [_model.discTypes mutableCopy];
  currTypes[idx] = newDiscType;
  self.model.discTypes = [currTypes copy];
  [self reload];
}

static UIColor *ColorForDiscModel(NSString * model)
{
  if ([model isEqualToString:@"Bv"] ||
      [model isEqualToString:@"Bh"] ||
      [model isEqualToString:@"Bs"] ||
      [model isEqualToString:@"Bb"]) {
    return RGBA(255, 0, 72, 1);
  } else if ([model isEqualToString:@"C"]) {

    return RGBA(255, 145, 0, 1);
  } else {
    return RGBA(0, 140, 255, 1);
  }
}

static UIControl *DiscControl(MTMDiscRow *self)
{
  UIControl *c = [[UIControl alloc] initWithFrame:CGRectZero];
  UILabel *label = [UILabel new];
  label.text = @"A";
  label.font = [UIFont systemFontOfSize:36.f weight:UIFontWeightSemibold];
  label.textColor = UIColor.whiteColor;
  label.translatesAutoresizingMaskIntoConstraints = NO;
  c.translatesAutoresizingMaskIntoConstraints = NO;
  [c addSubview:label];
  MTMActivateLayout(MTMMatchCenterX(label, c, 0),
                    MTMMatchCenterY(label, c, 0));
  c.backgroundColor = ColorForDiscModel(@"A");
  c.layer.cornerRadius = 12;

  MTMActivateLayout(MTMSetWidth(c, 60),
                    MTMSetHeight(c, 60));
  [c addTarget:self action:@selector(handleDiscControlTap:) forControlEvents:UIControlEventTouchUpInside];
  return c;
}

@end
