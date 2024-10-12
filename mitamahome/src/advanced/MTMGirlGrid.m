//
//  MTMGirlGrid.m
//  
//
//  Created by Chengming Liao on 7/26/20.
//

#import "MTMGirlGrid.h"

#import "MTMLayout.h"

@implementation MTMGirlGrid

- (instancetype)initWithFrame:(CGRect)frame
                     gridSize:(CGFloat)size
                       isAlly:(BOOL)isAlly
{
  if (self = [super initWithFrame:frame]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray<UIView *> *arr = [NSMutableArray new];
    for (int i = 1; i < 10; i++) {
      int num = isAlly ? i : 10 - i; // 9, 8, 7, ..., 1 for enemy
      [arr addObject:_SingleGridWithNumber(num, size)];
    }
    for (UIView *sv in arr) {
      [self addSubview:sv];
    }
    MTMActivateLayout(MTMMatchTop(arr[2], self, 0),
                      MTMMatchTop(arr[5], self, 0),
                      MTMMatchTop(arr[8], self, 0),
                      MTMMatchLeft(arr[2], self, 0),
                      MTMMatchLeft(arr[1], self, 0),
                      MTMMatchLeft(arr[0], self, 0),
                      MTMMatchBottom(arr[0], self, 0),
                      MTMMatchBottom(arr[3], self, 0),
                      MTMMatchBottom(arr[6], self, 0),
                      MTMMatchRight(arr[8], self, 0),
                      MTMMatchRight(arr[7], self, 0),
                      MTMMatchRight(arr[6], self, 0),
                      MTMConstraintRight(arr[5], arr[2], 0),
                      MTMConstraintRight(arr[8], arr[5], 0),
                      MTMConstraintBelow(arr[1], arr[2], 0),
                      MTMConstraintBelow(arr[4], arr[5], 0),
                      MTMConstraintBelow(arr[7], arr[8], 0),
                      MTMConstraintRight(arr[4], arr[1], 0),
                      MTMConstraintRight(arr[7], arr[4], 0),
                      MTMConstraintBelow(arr[0], arr[1], 0),
                      MTMConstraintBelow(arr[3], arr[4], 0),
                      MTMConstraintBelow(arr[6], arr[7], 0),
                      MTMConstraintRight(arr[3], arr[0], 0),
                      MTMConstraintRight(arr[6], arr[3], 0)
                      );
  }
  return self;
}

static UIView *_SingleGridWithNumber(NSInteger num, CGFloat size)
{
  UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
  UILabel *label = [UILabel new];
  label.text = [NSString stringWithFormat:@"%ld", num];
  label.textColor = UIColor.blackColor;
  label.font = [UIFont systemFontOfSize:20.f weight:UIFontWeightBold];
  label.numberOfLines = 1;
  label.lineBreakMode = NSLineBreakByTruncatingTail;
  label.translatesAutoresizingMaskIntoConstraints = NO;
  [v addSubview:label];
  v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
  v.layer.borderWidth = 1.0f;
  v.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
  MTMActivateLayout(MTMSetWidth(v, size),
                    MTMSetHeight(v, size),
                    MTMMatchCenterX(label, v, 0),
                    MTMMatchCenterY(label, v, 0));
  v.translatesAutoresizingMaskIntoConstraints = NO;
  return v;
}

@end
