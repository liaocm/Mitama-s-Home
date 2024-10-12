//
//  MTMConsoleLogCell.m
//  libmitamaui
//
//  Created by Chengming Liao on 6/28/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMConsoleLogCell.h"

@implementation MTMConsoleLogCell
{
  UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _label = [UILabel new];
    _label.textColor = UIColor.whiteColor;
    _label.font = [UIFont fontWithName:@"Menlo" size:14.0f];
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:_label];
  }
  return self;
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  _label.text = nil;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _label.frame = self.contentView.bounds;
}

- (void)setModel:(NSString *)model
{
  _label.text = model;
}

+ (CGSize)sizeWithModel:(NSString *)model thatFits:(CGSize)size
{
  CGRect rect =
  [model
    boundingRectWithSize:size
    options:NSStringDrawingUsesLineFragmentOrigin
    attributes:@{
     NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:14.0f]
    }
    context:nil];
  return rect.size;
}

@end
