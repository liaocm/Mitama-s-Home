#import "MTMAdvancedDiscView.h"
#import "MTMDiscRow.h"
#import "MTMGirlGrid.h"

#import "MTMLayout.h"
#import "MTMHookManager.h"

@implementation MTMAdvancedDiscView
{
  UIScrollView *_scrollView;
  UIView *_content;

  // UIView *_gridBaseline;
  NSMutableArray<MTMDiscRow *> *_discs;
  MTMGirlGrid *_grid;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _discs = [NSMutableArray new];

    UILabel *title = [UILabel new];
    title.text = @"Advanced Disc Settings";
    title.textColor = UIColor.blackColor;
    title.font = [UIFont systemFontOfSize:36.f weight:UIFontWeightBold];
    title.numberOfLines = 1;
    title.lineBreakMode = NSLineBreakByTruncatingTail;
    title.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:title];

    MTMActivateLayout(MTMMatchTop(title, self, 20),
                      MTMMatchLeft(title, self, 20)
                      );

    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    [confirmBtn setBackgroundColor:RGBA(0, 0, 0, 0.2)];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightBold];
    [confirmBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    confirmBtn.contentEdgeInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    [confirmBtn addTarget:self action:@selector(didTapConfirm:) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.cornerRadius = 6.f;
    [self addSubview:confirmBtn];
    MTMActivateLayout(MTMMatchCenterY(confirmBtn, title, 0),
                      MTMMatchRight(confirmBtn, self, 20));

    UIButton *hookBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    hookBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [hookBtn setTitle:@"Inject Hook" forState:UIControlStateNormal];
    [hookBtn setBackgroundColor:RGBA(0, 0, 0, 0.2)];
    hookBtn.titleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightBold];
    [hookBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    hookBtn.contentEdgeInsets = UIEdgeInsetsMake(4, 16, 4, 16);
    [hookBtn addTarget:self action:@selector(didTapInject:) forControlEvents:UIControlEventTouchUpInside];
    hookBtn.layer.cornerRadius = 6.f;
    [self addSubview:hookBtn];
    MTMActivateLayout(MTMMatchCenterY(hookBtn, title, 0),
                      MTMConstraintRight(hookBtn, title, 36));

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:_scrollView];
    MTMActivateLayout(MTMMatchLeft(_scrollView, self, 0),
                      MTMMatchRight(_scrollView, self, 0),
                      MTMMatchBottom(_scrollView, self, 0),
                      MTMConstraintBelow(_scrollView, title, 12.f));

    self.backgroundColor = [UIColor colorWithRed:232.f/255 green:232.f/255 blue:232.f/255 alpha:1];
    self.layer.cornerRadius = 12.f;

    _content = [[UIView alloc] initWithFrame:CGRectZero];
    _content.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_content];
    MTMActivateLayoutArray(MTMInsetView(_content, _scrollView, UIEdgeInsetsZero));

    NSLayoutConstraint *height = MTMMatchHeight(_content, _scrollView, 1);
    height.priority = UILayoutPriorityDefaultLow;
    MTMActivateLayout(MTMMatchWidth(_content, _scrollView, 1),
                      height);

    [self _initDemoGridRow];
    [self _initDiscRows];
  }
  return self;
}

- (void)_initDemoGridRow
{
  _grid = [[MTMGirlGrid alloc] initWithFrame:CGRectZero
                                    gridSize:32.f
                                      isAlly:YES];
  [_content addSubview:_grid];
  MTMActivateLayout(MTMMatchTop(_grid, _content, 8),
                    MTMMatchLeft(_grid, _content, 20));

  UILabel *label = [UILabel new];
  label.text = @"Refer to the number for magical girl position. Effects are deactivated by default.\nBlast Discs: Bh = horizontal; Bv = vertical; \
  Bs = diagonal slash; Bb = diagonal backslash.";
  label.textColor = UIColor.blackColor;
  label.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightLight];
  label.numberOfLines = 3;
  label.lineBreakMode = NSLineBreakByTruncatingTail;
  label.translatesAutoresizingMaskIntoConstraints = NO;
  [_content addSubview:label];
  MTMActivateLayout(MTMConstraintRight(label, _grid, 16.f),
                    MTMMatchRight(label, _content, 0),
                    MTMMatchTop(label, _grid, 0),
                    MTMMatchBottom(label, _grid, 0));
}

- (void)_initDiscRows
{
  for (int i = 0; i < 9; i++) {
    MTMDiscRow *row = [[MTMDiscRow alloc] initWithFrame:CGRectZero];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [_content addSubview:row];
    // set model
    [row setModel:[MTMDiscRowModel newWithTypes:@[@"A", @"Bv", @"Bv", @"Bh", @"C"] title:i+1 enabled:NO]];
    [_discs addObject:row];
  }

  MTMActivateLayout(MTMConstraintBelow(_discs[0], _grid, 12),
                    MTMMatchRight(_discs[0], _content, 0),
                    MTMMatchLeft(_discs[0], _content, 0),
                    MTMSetHeight(_discs[0], 80));
  for (int i = 1; i < 9; i++) {
    MTMActivateLayout(MTMConstraintBelow(_discs[i], _discs[i-1], 4),
                      MTMMatchRight(_discs[i], _content, 0),
                      MTMMatchLeft(_discs[i], _content, 0),
                      MTMSetHeight(_discs[i], 80)
                      );
  }
  MTMActivateLayout(MTMMatchBottom(_discs[8], _content, 24));
}

- (void)didTapConfirm:(id)sender
{
  _scrollView.contentOffset = CGPointZero;
  [self.delegate advancedDiscViewDidConfirmData:self];
}

- (void)didTapInject:(id)sender
{
  [[MTMHookManager get] hookParser];
}

static NSString *DiscStringFromModelString(NSString *str)
{
  if ([str isEqualToString:@"A"]) {
    return @"MPUP";
  } else if ([str isEqualToString:@"Bv"]) {
    return @"RANGE_V";
  } else if ([str isEqualToString:@"Bh"]) {
    return @"RANGE_H";
  } else if ([str isEqualToString:@"Bs"]) {
    return @"RANGE_S";
  } else if ([str isEqualToString:@"Bb"]) {
    return @"RANGE_B";
  } else {
    return @"CHARGE";
  }
}

- (NSDictionary *)applicableModels
{
  NSMutableDictionary *dict = [NSMutableDictionary new];
  for (MTMDiscRow *row in _discs) {
    if (row.model.enabled) {
      NSMutableArray *arr = [NSMutableArray new];
      for (NSString *s in row.model.discTypes) {
        [arr addObject:DiscStringFromModelString(s)];
      }
      dict[@(row.model.title)] = [arr copy];
    }
  }
  return dict;
}

@end
