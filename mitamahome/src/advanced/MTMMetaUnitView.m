//
//  MTMMetaUnitView.m
//  
//
//  Created by Chengming Liao on 7/26/20.
//

#import "MTMMetaUnitView.h"

#import "MTMLayout.h"

static UILabel *TagLabel(NSString *text)
{
  UILabel *label = [UILabel new];
  label.text = text;
  label.textColor = UIColor.blackColor;
  label.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightRegular];
  label.numberOfLines = 0;
  label.lineBreakMode = NSLineBreakByTruncatingTail;
  label.translatesAutoresizingMaskIntoConstraints = NO;
  return label;
}

static UIButton *ControlBtn(NSString *title)
{
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [btn setTitle:title forState:UIControlStateNormal];
  [btn setBackgroundColor:RGBA(0, 0, 0, 0.2)];
  btn.layer.cornerRadius = 6.f;
  btn.titleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightBold];
  [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  btn.translatesAutoresizingMaskIntoConstraints = NO;
  btn.contentEdgeInsets = UIEdgeInsetsMake(4, 16, 4, 16);
  MTMActivateLayout(MTMSetMinWidth(btn, 80),
                    MTMSetMinHeight(btn, 36));
  return btn;
}

NSMutableDictionary<NSString *, NSString *> *MTMMetaGirlDefaultSingleModel()
{
  NSMutableDictionary *dict = [NSMutableDictionary new];
  dict[@"attack"] = @"1.0x";
  dict[@"defence"] = @"1.0x";
  dict[@"mpStart"] = @"0";
  dict[@"maxMp"] = @"0";
  dict[@"rateGainMpAtk"] = @"1.0x";
  dict[@"rateGainMpDef"] = @"1.0x";
  return dict;
}

static NSMutableArray<NSMutableDictionary<NSString *, NSString *> *> *DefaultViewModel()
{
  NSMutableArray *arr = [NSMutableArray new];
  for (int i = 0; i < 9; i++) {
    NSMutableDictionary *dict = MTMMetaGirlDefaultSingleModel();
    [arr addObject:dict];
  }
  return arr;
}

@implementation MTMMetaUnitView
{
  UIButton *_posBtn;
  UIButton *_clearBtn;
  UIButton *_atkBtn;
  UIButton *_defBtn;
  UIButton *_mpStartBtn;
  UIButton *_mpMaxBtn;
  UIButton *_mpGainAtkBtn;
  UIButton *_mpGainDefBtn;

  NSMutableArray<NSMutableDictionary<NSString *, NSString *> *> *_viewModel;
  NSInteger _currPosIdx;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _viewModel = DefaultViewModel();
    _currPosIdx = 0;

    // Hairline
    UIView *hairline = [UIView new];
    hairline.translatesAutoresizingMaskIntoConstraints = NO;
    hairline.backgroundColor = UIColor.blackColor;
    [self addSubview:hairline];
    MTMActivateLayout(MTMMatchTop(hairline, self, 0),
                      MTMMatchLeft(hairline, self, 0),
                      MTMMatchRight(hairline, self, 0),
                      MTMSetHeight(hairline, 1.f / UIScreen.mainScreen.scale));

    // Row 1: position
    UILabel *pos = TagLabel(@"Position");
    [self addSubview:pos];
    MTMActivateLayout(MTMMatchTop(pos, self, 16),
                      MTMMatchLeft(pos, self, 0));
    UIButton *posButton = ControlBtn(@"1"); // TODO model
    _posBtn = posButton;
    [self addSubview:posButton];
    MTMActivateLayout(MTMMatchCenterY(posButton, pos, 0),
                      MTMConstraintRight(posButton, pos, 12));

    UILabel *posInfo = TagLabel(@"Tap on button to switch between positions.");
    posInfo.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightLight];
    [self addSubview:posInfo];
    MTMActivateLayout(MTMConstraintRight(posInfo, posButton, 16.f),
                      MTMMatchCenterY(posInfo, posButton, 0));

    UIButton *clearButton = ControlBtn(@"Clear");
    [self addSubview:clearButton];
    _clearBtn = clearButton;
    MTMActivateLayout(MTMConstraintLeftFlexShrink(posInfo, clearButton, 24),
                      MTMMatchCenterY(clearButton, posInfo, 0),
                      MTMMatchRight(clearButton, self, 0));

    // Row 1 Heights
    MTMActivateLayout(MTMMatchHeight(pos, posButton, 1),
                      MTMMatchHeight(posInfo, clearButton, 1),
                      MTMMatchHeight(pos, posInfo, 1));

    // Row 2: Attack / Defence
    UILabel *atk = TagLabel(@"Attack");
    [self addSubview:atk];
    MTMActivateLayout(MTMConstraintBelow(atk, pos, 20),
                      MTMMatchLeft(atk, pos, 0));
    UIButton *atkBtn = ControlBtn(@"1.0x");
    _atkBtn = atkBtn;
    [self addSubview:atkBtn];
    MTMActivateLayout(MTMConstraintRight(atkBtn, atk, 16.f),
                      MTMMatchCenterY(atkBtn, atk, 0));

    UILabel *def = TagLabel(@"Defense");
    [self addSubview:def];
    MTMActivateLayout(MTMConstraintRight(def, atkBtn, 36.f),
                      MTMMatchCenterY(def, atkBtn, 0));

    UIButton *defBtn = ControlBtn(@"1.0x");
    _defBtn = defBtn;
    [self addSubview:defBtn];
    MTMActivateLayout(MTMConstraintRight(defBtn, def, 16.f),
                      MTMMatchCenterY(defBtn, def, 0));

    // Row 2 Heights
    MTMActivateLayout(MTMMatchHeight(atkBtn, atk, 1),
                      MTMMatchHeight(defBtn, def, 1),
                      MTMMatchHeight(atkBtn, def, 1));

    // Row 3: MP Start, MP Max
    UILabel *mpStart = TagLabel(@"MP Start");
    [self addSubview:mpStart];
    MTMActivateLayout(MTMConstraintBelow(mpStart, atk, 20),
                      MTMMatchLeft(mpStart, atk, 0));

    UIButton *mpStartBtn = ControlBtn(@"Default");
    _mpStartBtn = mpStartBtn;
    [self addSubview:mpStartBtn];
    MTMActivateLayout(MTMConstraintRight(mpStartBtn, mpStart, 16.f),
                      MTMMatchCenterY(mpStartBtn, mpStart, 0));

    UILabel *mpMax = TagLabel(@"Max MP");
    [self addSubview:mpMax];
    MTMActivateLayout(MTMConstraintRight(mpMax, mpStartBtn, 36.f),
                      MTMMatchCenterY(mpMax, mpStartBtn, 0));

    UIButton *mpMaxBtn = ControlBtn(@"Default");
    _mpMaxBtn = mpMaxBtn;
    [self addSubview:mpMaxBtn];
    MTMActivateLayout(MTMConstraintRight(mpMaxBtn, mpMax, 16.f),
                      MTMMatchCenterY(mpMaxBtn, mpMax, 0));

    // Row 3 Heights
    MTMActivateLayout(MTMMatchHeight(mpStart, mpStartBtn, 1),
                      MTMMatchHeight(mpStart, mpMax, 1),
                      MTMMatchHeight(mpMax, mpMaxBtn, 1));

    // Row 4: MP Gain Atk, MP Gain Def
    UILabel *mpGainAtk = TagLabel(@"MP Gain Attack");
    [self addSubview:mpGainAtk];
    MTMActivateLayout(MTMConstraintBelow(mpGainAtk, mpStart, 20),
                      MTMMatchLeft(mpGainAtk, mpStart, 0));

    UIButton *mpGainAtkBtn = ControlBtn(@"1.0x");
    _mpGainAtkBtn = mpGainAtkBtn;
    [self addSubview:mpGainAtkBtn];
    MTMActivateLayout(MTMConstraintRight(mpGainAtkBtn, mpGainAtk, 16.f),
                      MTMMatchCenterY(mpGainAtkBtn, mpGainAtk, 0));

    UILabel *mpGainDef = TagLabel(@"MP Gain Defense");
    [self addSubview:mpGainDef];
    MTMActivateLayout(MTMConstraintRight(mpGainDef, mpGainAtkBtn, 36.f),
                      MTMMatchCenterY(mpGainDef, mpGainAtkBtn, 0));

    UIButton *mpGainDefBtn = ControlBtn(@"1.0x");
    _mpGainDefBtn = mpGainDefBtn;
    [self addSubview:mpGainDefBtn];
    MTMActivateLayout(MTMConstraintRight(mpGainDefBtn, mpGainDef, 16.f),
                      MTMMatchCenterY(mpGainDefBtn, mpGainDef, 0));

    // Row 4 Heights
    MTMActivateLayout(MTMMatchHeight(mpGainAtk, mpGainAtkBtn, 1),
                      MTMMatchHeight(mpGainAtk, mpGainDef, 1),
                      MTMMatchHeight(mpGainAtk, mpGainDefBtn, 1));

    // Last Row Matches Bottom
    MTMActivateLayout(MTMMatchBottom(mpGainAtk, self, 0));

    [self _setupButtonAction];

    [self reload];
  }
  return self;
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)viewModel
{
  return _viewModel;
}

- (void)reload
{
  NSDictionary<NSString *, NSString *> *model = _viewModel[_currPosIdx];
  [_atkBtn setTitle:model[@"attack"] forState:UIControlStateNormal];
  [_defBtn setTitle:model[@"defence"] forState:UIControlStateNormal];

  NSString *mpStartString = [model[@"mpStart"] isEqualToString:@"0"] ? @"Default" : model[@"mpStart"];
  NSString *mpMaxString = [model[@"maxMp"] isEqualToString:@"0"] ? @"Default" : model[@"maxMp"];
  [_mpStartBtn setTitle:mpStartString forState:UIControlStateNormal];
  [_mpMaxBtn setTitle:mpMaxString forState:UIControlStateNormal];

  [_mpGainAtkBtn setTitle:model[@"rateGainMpAtk"] forState:UIControlStateNormal];
  [_mpGainDefBtn setTitle:model[@"rateGainMpDef"] forState:UIControlStateNormal];

  [self setNeedsLayout];
}

- (void)_setupButtonAction
{
  [_posBtn addTarget:self action:@selector(_didTapPos:) forControlEvents:UIControlEventTouchUpInside];
  [_clearBtn addTarget:self action:@selector(_didTapClear:) forControlEvents:UIControlEventTouchUpInside];
  [_atkBtn addTarget:self action:@selector(_didTapAtk:) forControlEvents:UIControlEventTouchUpInside];
  [_defBtn addTarget:self action:@selector(_didTapDef:) forControlEvents:UIControlEventTouchUpInside];
  [_mpStartBtn addTarget:self action:@selector(_didTapMPStart:) forControlEvents:UIControlEventTouchUpInside];
  [_mpMaxBtn addTarget:self action:@selector(_didTapMPMax:) forControlEvents:UIControlEventTouchUpInside];
  [_mpGainAtkBtn addTarget:self action:@selector(_didTapMPGainAtk:) forControlEvents:UIControlEventTouchUpInside];
  [_mpGainDefBtn addTarget:self action:@selector(_didTapMPGainDef:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_didTapPos:(UIButton *)sender
{
  _currPosIdx++;
  if (_currPosIdx >= 9) {
    _currPosIdx -= 9;
  }
  NSString *title = [NSString stringWithFormat:@"%ld", _currPosIdx + 1];
  [_posBtn setTitle:title forState:UIControlStateNormal];
  [self reload];
}

- (void)_didTapClear:(UIButton *)sender
{
  NSMutableDictionary<NSString *, NSString *> *defaultSingleDict = MTMMetaGirlDefaultSingleModel();
  _viewModel[_currPosIdx] = defaultSingleDict;
  [self reload];
}

- (void)_didTapAtk:(UIButton *)sender
{
  NSArray *values = @[@"1.0x", @"1.2x", @"2.0x", @"5.0x", @"10.0x"];
  NSString *currValue = sender.titleLabel.text;
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _viewModel[_currPosIdx][@"attack"] = newValue;
  [self reload];
}

- (void)_didTapDef:(UIButton *)sender
{
  NSArray *values = @[@"1.0x", @"1.2x", @"2.0x", @"5.0x", @"10.0x"];
  NSString *currValue = sender.titleLabel.text;
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _viewModel[_currPosIdx][@"defence"] = newValue;
  [self reload];
}

- (void)_didTapMPStart:(UIButton *)sender
{
  NSArray *values = @[@"0", @"1000", @"2000"];
  NSString *currValue = sender.titleLabel.text;
  currValue = [currValue isEqualToString:@"Default"] ? @"0" : currValue;
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _viewModel[_currPosIdx][@"mpStart"] = newValue;
  [self reload];
}

- (void)_didTapMPMax:(UIButton *)sender
{
  NSArray *values = @[@"0", @"2000", @"10000"];
  NSString *currValue = sender.titleLabel.text;
  currValue = [currValue isEqualToString:@"Default"] ? @"0" : currValue;
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _viewModel[_currPosIdx][@"maxMp"] = newValue;
  [self reload];
}

- (void)_didTapMPGainAtk:(UIButton *)sender
{
  NSArray *values = @[@"1.0x", @"1.5x", @"2.0x", @"10.0x"];
  NSString *currValue = sender.titleLabel.text;
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _viewModel[_currPosIdx][@"rateGainMpAtk"] = newValue;
  [self reload];
}

- (void)_didTapMPGainDef:(UIButton *)sender
{
  NSArray *values = @[@"1.0x", @"1.5x", @"2.0x", @"10.0x"];
  NSString *currValue = sender.titleLabel.text;
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _viewModel[_currPosIdx][@"rateGainMpDef"] = newValue;
  [self reload];
}

@end
