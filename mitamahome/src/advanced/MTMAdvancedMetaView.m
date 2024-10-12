//
//  MTMAdvancedMetaView.m
//
//
//  Created by Chengming Liao on 7/26/20.
//

#import "MTMAdvancedMetaView.h"

#import "MTMLayout.h"

#import "MTMGirlGrid.h"
#import "MTMMetaUnitView.h"
#import "MTMHookManager.h"

static NSMutableDictionary *DefaultMiscModel()
{
  return @{
    @"auto" : @"0",
    @"isHalfSkill" : @"0",
    @"skillCost" : @"-1",
    @"tripleSpeed" : @"0",
    @"connectNum" : @"0"
  }.mutableCopy;
}

static NSMutableDictionary *DefaultEnemyModel()
{
  return @{
    @"attack" : @"1.0x",
    @"defence" : @"1.0x"
  }.mutableCopy;
}

@implementation MTMAdvancedMetaView
{
  UIScrollView *_scrollView;
  UIView *_content;

  UIView *_girlSection;
  UIView *_miscSection;
  UIView *_enemySection;

  MTMMetaUnitView *_girlUnitView;

  // Button Actions
  UIButton *_autoEnableBtn;
  UIButton *_halfSkillBtn;
  UIButton *_skillCostBtn;
  UIButton *_tripleSpeedBtn;
  UIButton *_connectCountBtn;

  UIButton *_enemyAtkBtn;
  UIButton *_enemyDefBtn;

  // Model
  NSMutableDictionary<NSString *, NSString *> *_miscModel;
  NSMutableDictionary<NSString *, NSString *> *_enemyModel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _miscModel = DefaultMiscModel();
    _enemyModel = DefaultEnemyModel();

    UILabel *title = [UILabel new];
    title.text = @"Advanced Metadata";
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

    self.backgroundColor = [UIColor colorWithRed:232.f/255 green:232.f/255 blue:232.f/255 alpha:1];
    self.layer.cornerRadius = 12.f;

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

    _content = [[UIView alloc] initWithFrame:CGRectZero];
    _content.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_content];
    MTMActivateLayoutArray(MTMInsetView(_content, _scrollView, UIEdgeInsetsZero));
    NSLayoutConstraint *height = MTMMatchHeight(_content, _scrollView, 1);
    height.priority = UILayoutPriorityDefaultLow;
    MTMActivateLayout(MTMMatchWidth(_content, _scrollView, 1),
                      height);

    [self _initSections];
    [self reload];
  }
  return self;
}

- (void)didTapConfirm:(id)sender
{
  [self.delegate advancedMetaViewDidConfirmData:self];
}

- (void)didTapInject:(id)sender
{
  [[MTMHookManager get] hookParser];
  [[MTMHookManager get] hookStringify];
}

- (NSDictionary *)model
{
  return @{
    @"girl" : _girlUnitView.viewModel,
    @"misc" : _miscModel,
    @"enemy" : _enemyModel
  };
}

- (void)reload
{
  NSString *title = _miscModel[@"auto"];
  if ([title isEqualToString:@"0"]) {
    title = @"Default";
  }
  [_autoEnableBtn setTitle:title forState:UIControlStateNormal];
  title = _miscModel[@"isHalfSkill"];
  if ([title isEqualToString:@"0"]) {
    title = @"Default";
  }
  [_halfSkillBtn setTitle:title forState:UIControlStateNormal];
  title = _miscModel[@"skillCost"];
  if (title.integerValue < 0) {
    title = @"Default";
  }
  [_skillCostBtn setTitle:title forState:UIControlStateNormal];
  title = _miscModel[@"tripleSpeed"];
  if ([title isEqualToString:@"0"]) {
    title = @"Default";
  }
  [_tripleSpeedBtn setTitle:title forState:UIControlStateNormal];
  title = _miscModel[@"connectNum"];
  if ([title isEqualToString:@"0"]) {
    title = @"Default";
  }
  [_connectCountBtn setTitle:title forState:UIControlStateNormal];
  [_enemyAtkBtn setTitle:_enemyModel[@"attack"] forState:UIControlStateNormal];
  [_enemyDefBtn setTitle:_enemyModel[@"defence"] forState:UIControlStateNormal];

  [self setNeedsLayout];
}

// Sections

static UILabel *SectionHeader(NSString *text)
{
  UILabel *label = [UILabel new];
  label.text = text;
  label.textColor = UIColor.blackColor;
  label.font = [UIFont systemFontOfSize:24.f weight:UIFontWeightSemibold];
  label.numberOfLines = 1;
  label.lineBreakMode = NSLineBreakByTruncatingTail;
  label.translatesAutoresizingMaskIntoConstraints = NO;
  return label;
}

static UILabel *InfoLabel(NSString *text, BOOL light)
{
  UILabel *label = [UILabel new];
  label.text = text;
  label.textColor = UIColor.blackColor;
  label.font = [UIFont systemFontOfSize:18.f weight:light ? UIFontWeightLight : UIFontWeightRegular];
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
  MTMActivateLayout(MTMSetMinHeight(btn, 36));
  return btn;
}

- (void)_initSections
{
  UIView *lastSecionView = nil;
  [self _setupGirlSection];
  [self _setupMiscSection];
  lastSecionView = [self _setupEnemySection];

  MTMActivateLayout(MTMMatchBottom(lastSecionView, _content, 12));
}

- (UIView *)_setupGirlSection
{
  _girlSection = [[UIView alloc] initWithFrame:CGRectZero];
  _girlSection.translatesAutoresizingMaskIntoConstraints = NO;
  UILabel *header = SectionHeader(@"Girl Stats");
  [_girlSection addSubview:header];
  MTMActivateLayout(MTMMatchTop(header, _girlSection, 8),
                    MTMMatchLeft(header, _girlSection, 0));

  MTMGirlGrid *grid = [[MTMGirlGrid alloc] initWithFrame:CGRectZero
                                                gridSize:24
                                                  isAlly:YES];
  [_girlSection addSubview:grid];
  MTMActivateLayout(MTMConstraintBelow(grid, header, 12),
                    MTMMatchLeft(grid, header, 0));

  UILabel *gridInfo = InfoLabel(@"Refer to the number for allied magical girl position.", YES);
  [_girlSection addSubview:gridInfo];
  MTMActivateLayout(MTMConstraintRight(gridInfo, grid, 12.f),
                    MTMMatchCenterY(gridInfo, grid, 0),
                    MTMMatchRight(gridInfo, _girlSection, 0));
  
  MTMMetaUnitView *unitView = [[MTMMetaUnitView alloc] initWithFrame:CGRectZero];
  _girlUnitView = unitView;
  [_girlSection addSubview:unitView];
  MTMActivateLayout(MTMConstraintBelow(unitView, grid, 16),
                    MTMMatchLeft(unitView, _girlSection, 0),
                    MTMMatchRight(unitView, _girlSection, 0),
                    MTMMatchBottom(unitView, _girlSection, 0));

  [_content addSubview:_girlSection];
  MTMActivateLayout(MTMMatchTop(_girlSection, _content, 0),
                    MTMMatchLeft(_girlSection, _content, 24),
                    MTMMatchRight(_girlSection, _content, 24));
  return _girlSection;
}

- (UIView *)_setupMiscSection
{
  _miscSection = [[UIView alloc] initWithFrame:CGRectZero];
  _miscSection.translatesAutoresizingMaskIntoConstraints = NO;
  UILabel *header = SectionHeader(@"Misc Metadata");
  [_miscSection addSubview:header];
  MTMActivateLayout(MTMMatchTop(header, _miscSection, 8),
                    MTMMatchLeft(header, _miscSection, 0));

  // Row 1
  UILabel *autoEnabled = InfoLabel(@"Auto Enabled", NO);
  [_miscSection addSubview:autoEnabled];
  MTMActivateLayout(MTMConstraintBelow(autoEnabled, header, 16),
                    MTMMatchLeft(autoEnabled, _miscSection, 0));

  UIButton *autoEnabledBtn = ControlBtn(@"Default");
  _autoEnableBtn = autoEnabledBtn;
  [_miscSection addSubview:autoEnabledBtn];
  MTMActivateLayout(MTMConstraintRight(autoEnabledBtn, autoEnabled, 16.f),
                    MTMMatchCenterY(autoEnabledBtn, autoEnabled, 0),
                    MTMMatchHeight(autoEnabledBtn, autoEnabled, 1));

  UILabel *halfSkill = InfoLabel(@"Half Skill [Mirror]", NO);
  [_miscSection addSubview:halfSkill];
  MTMActivateLayout(MTMConstraintRight(halfSkill, autoEnabledBtn, 24),
                    MTMMatchCenterY(halfSkill, autoEnabledBtn, 0),
                    MTMMatchHeight(halfSkill, autoEnabledBtn, 1));

  UIButton *halfSkillBtn = ControlBtn(@"Default");
  _halfSkillBtn = halfSkillBtn;
  [_miscSection addSubview:halfSkillBtn];
  MTMActivateLayout(MTMConstraintRight(halfSkillBtn, halfSkill, 16.f),
                    MTMMatchCenterY(halfSkillBtn, halfSkill, 0),
                    MTMMatchHeight(halfSkillBtn, halfSkill, 1));

  // Row 2
  UILabel *skillCost = InfoLabel(@"Self Skill Cost", NO);
  [_miscSection addSubview:skillCost];
  MTMActivateLayout(MTMConstraintBelow(skillCost, autoEnabled, 16),
                    MTMMatchLeft(skillCost, autoEnabled, 0));

  UIButton *skillCostBtn = ControlBtn(@"Default");
  _skillCostBtn = skillCostBtn;
  [_miscSection addSubview:skillCostBtn];
  MTMActivateLayout(MTMConstraintRight(skillCostBtn, skillCost, 16.f),
                    MTMMatchCenterY(skillCostBtn, skillCost, 0),
                    MTMMatchHeight(skillCostBtn, skillCost, 1));

  UILabel *tripleSpeed = InfoLabel(@"Triple Speed Enabled", NO);
  [_miscSection addSubview:tripleSpeed];
  MTMActivateLayout(MTMConstraintRight(tripleSpeed, skillCostBtn, 24),
                    MTMMatchCenterY(tripleSpeed, skillCostBtn, 0),
                    MTMMatchHeight(tripleSpeed, skillCostBtn, 1));

  UIButton *tripleSpeedBtn = ControlBtn(@"Default");
  _tripleSpeedBtn = tripleSpeedBtn;
  [_miscSection addSubview:tripleSpeedBtn];
  MTMActivateLayout(MTMConstraintRight(tripleSpeedBtn, tripleSpeed, 16.f),
                    MTMMatchCenterY(tripleSpeedBtn, tripleSpeed, 0),
                    MTMMatchHeight(tripleSpeedBtn, tripleSpeed, 1));

  // Row 3
  UILabel *connectCount = InfoLabel(@"Counnect Count", NO);
  [_miscSection addSubview:connectCount];
  MTMActivateLayout(MTMConstraintBelow(connectCount, skillCost, 16),
                    MTMMatchLeft(connectCount, skillCost, 0));

  UIButton *connectCountBtn = ControlBtn(@"Default");
  _connectCountBtn = connectCountBtn;
  [_miscSection addSubview:connectCountBtn];
  MTMActivateLayout(MTMConstraintRight(connectCountBtn, connectCount, 16.f),
                    MTMMatchCenterY(connectCountBtn, connectCount, 0),
                    MTMMatchHeight(connectCountBtn, connectCount, 1));

  // Last Item
  MTMActivateLayout(MTMMatchBottom(connectCountBtn, _miscSection, 0));

  // Button actions
  [autoEnabledBtn addTarget:self action:@selector(_didTapAutoEnabled:) forControlEvents:UIControlEventTouchUpInside];
  [halfSkillBtn addTarget:self action:@selector(_didTapHalfSkill:) forControlEvents:UIControlEventTouchUpInside];
  [skillCostBtn addTarget:self action:@selector(_didTapSkillCost:) forControlEvents:UIControlEventTouchUpInside];
  [tripleSpeedBtn addTarget:self action:@selector(_didTapTripleSpeed:) forControlEvents:UIControlEventTouchUpInside];
  [connectCountBtn addTarget:self action:@selector(_didTapConnectCount:) forControlEvents:UIControlEventTouchUpInside];

  // Parent constrains
  [_content addSubview:_miscSection];
  MTMActivateLayout(MTMConstraintBelow(_miscSection, _girlSection, 20),
                    MTMMatchLeft(_miscSection, _content, 24),
                    MTMMatchRight(_miscSection, _content, 24));

  return _miscSection;
}

- (UIView *)_setupEnemySection
{
  _enemySection = [[UIView alloc] initWithFrame:CGRectZero];
  _enemySection.translatesAutoresizingMaskIntoConstraints = NO;
  UILabel *header = SectionHeader(@"Enemy");
  [_enemySection addSubview:header];
  MTMActivateLayout(MTMMatchTop(header, _enemySection, 8),
                    MTMMatchLeft(header, _enemySection, 0));

  UILabel *atk = InfoLabel(@"Enemy Attack", NO);
  [_enemySection addSubview:atk];
  MTMActivateLayout(MTMConstraintBelow(atk, header, 16),
                    MTMMatchLeft(atk, _enemySection, 0));

  UIButton *atkBtn = ControlBtn(@"1.0x"); // TODO Model, 0.95x 0.8x 0.5x 0.1x
  _enemyAtkBtn = atkBtn;
  [_enemySection addSubview:atkBtn];
  MTMActivateLayout(MTMConstraintRight(atkBtn, atk, 16.f),
                    MTMMatchCenterY(atkBtn, atk, 0),
                    MTMMatchHeight(atkBtn, atk, 1));

  UILabel *def = InfoLabel(@"Enemy Defense", NO);
  [_enemySection addSubview:def];
  MTMActivateLayout(MTMConstraintBelow(def, atk, 16),
                    MTMMatchLeft(def, _enemySection, 0));

  UIButton *defBtn = ControlBtn(@"1.0x"); // TODO Model, 0.95x 0.8x 0.5x 0.1x
  _enemyDefBtn = defBtn;
  [_enemySection addSubview:defBtn];
  MTMActivateLayout(MTMConstraintRight(defBtn, def, 16.f),
                    MTMMatchCenterY(defBtn, def, 0),
                    MTMMatchHeight(defBtn, def, 1));

  // Last Item
  MTMActivateLayout(MTMMatchBottom(defBtn, _enemySection, 0));

  [atkBtn addTarget:self action:@selector(_didTapEnemyAttack:) forControlEvents:UIControlEventTouchUpInside];
  [defBtn addTarget:self action:@selector(_didTapEnemyDefense:) forControlEvents:UIControlEventTouchUpInside];

  // Parent constrains
  [_content addSubview:_enemySection];
  MTMActivateLayout(MTMConstraintBelow(_enemySection, _miscSection, 20),
                    MTMMatchLeft(_enemySection, _content, 24),
                    MTMMatchRight(_enemySection, _content, 24));
  return _enemySection;
}

- (void)_didTapAutoEnabled:(id)sender
{
  NSString *currModel = _miscModel[@"auto"];
  NSString *nextModel = [currModel isEqualToString:@"0"] ? @"true" : @"0";
  _miscModel[@"auto"] = nextModel;
  [self reload];
}

- (void)_didTapHalfSkill:(id)sender
{
  NSString *currModel = _miscModel[@"isHalfSkill"];
  NSString *nextModel = [currModel isEqualToString:@"0"] ? @"false" : @"0";
  _miscModel[@"isHalfSkill"] = nextModel;
  [self reload];
}

- (void)_didTapSkillCost:(id)sender
{
  NSString *currModel = _miscModel[@"skillCost"];
  NSInteger cost = currModel.integerValue + 1;
  if (cost > 1) {
    // -1, 0, 1
    cost -= 3;
  }
  NSString *nextModel = [NSString stringWithFormat:@"%ld", cost];
  _miscModel[@"skillCost"] = nextModel;
  [self reload];
}

- (void)_didTapTripleSpeed:(id)sender
{
  NSString *currModel = _miscModel[@"tripleSpeed"];
  NSString *nextModel = [currModel isEqualToString:@"0"] ? @"true" : @"0";
  _miscModel[@"tripleSpeed"] = nextModel;
  [self reload];
}

- (void)_didTapConnectCount:(id)sender
{
  NSString *currModel = _miscModel[@"connectNum"];
  NSString *nextModel = [currModel isEqualToString:@"0"] ? @"1" : @"0";
  _miscModel[@"connectNum"] = nextModel;
  [self reload];
}

- (void)_didTapEnemyAttack:(id)sender
{
  NSArray *values = @[@"1.0x", @"0.95x", @"0.8x", @"0.5x", @"0.1x"];
  NSString *currValue = _enemyModel[@"attack"];
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _enemyModel[@"attack"] = newValue;
  [self reload];
}

- (void)_didTapEnemyDefense:(id)sender
{
  NSArray *values = @[@"1.0x", @"0.95x", @"0.8x", @"0.5x", @"0.1x"];
  NSString *currValue = _enemyModel[@"defence"];
  NSInteger idx = [values indexOfObject:currValue] + 1;
  if (idx >= values.count) {
    idx -= values.count;
  }
  NSString *newValue = values[idx];
  _enemyModel[@"defence"] = newValue;
  [self reload];
}

@end
