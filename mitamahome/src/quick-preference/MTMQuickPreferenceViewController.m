//
//  MTMQuickPreferenceViewController.m
//  libmitamaui
//
//  Created by Chengming Liao on 8/4/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMQuickPreferenceViewController.h"

#import "MTMUIStore.h"
#import "MTMLayout.h"
#import "MTMPreference.h"
#import "MTMRecord.h"

#import "MTMPreferenceValues.h"
#import "MTMEventParamFetcher.h"

#import "MTMPopoverListViewController.h"

@interface MTMQuickPreferenceViewController () <MTMPopoverListProtocol>

@end

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

static UILabel *SecondaryLabel(NSString *text)
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

@implementation MTMQuickPreferenceViewController
{
  NSMutableDictionary<NSNumber *, id> *_viewModel;
  NSMutableDictionary<NSString *, id> *_prefCopy;
  UIScrollView *_scrollView;
  UIView *_contentView;

  NSMutableDictionary<NSNumber *, UIButton *> *_btns;
}

- (instancetype)init
{
  if (self = [super init]) {
    _btns = [NSMutableDictionary new];
    [self loadViewModel];
  }
  return self;
}

- (void)loadViewModel
{
  _prefCopy = [[[MTMPreference get] getPreferences] mutableCopy];
  _viewModel = [NSMutableDictionary new];
  for (NSString *key in _prefCopy) {
    id prefVal = _prefCopy[key];
    NSArray *validVals = MTMPreferenceValuesFromKey(key);
    NSArray *validTitles = MTMPreferenceTitleValuesFromKey(key);
    NSInteger idx = [validVals indexOfObject:prefVal];
    if (idx >= 0 && idx < validTitles.count) {
      _viewModel[@(MTMPreferenceKeyFromString(key))] = validTitles[idx];
    }
  }
}

- (void)loadView
{
  self.view = [[UIView alloc] initWithFrame:CGRectZero];
  self.view.backgroundColor = RGBA(235, 235, 235, 1);
  self.view.layer.cornerRadius = 12.f;

  UILabel *titleLabel = [UILabel new];
  titleLabel.textColor = UIColor.blackColor;
  titleLabel.font = [UIFont systemFontOfSize:36.f weight:UIFontWeightBold];
  titleLabel.numberOfLines = 1;
  titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  titleLabel.text = @"Quick Settings";
  titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:titleLabel];

  UIButton *closeBtn = MTMGenericButtonCreate(@"Close");
  [closeBtn addTarget:self action:@selector(didTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:closeBtn];
  UIButton *saveBtn = MTMGenericButtonCreate(@"Save");
  [saveBtn addTarget:self action:@selector(didTapSaveButton:) forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:saveBtn];
  UIButton *loadBranchBtn = MTMGenericButtonCreate(@"Load Branch Ids");
  [loadBranchBtn addTarget:self action:@selector(didTapLoadBranchButton:) forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:loadBranchBtn];

  MTMActivateLayout(MTMMatchRight(closeBtn, self.view, 24.f),
                    MTMMatchTop(closeBtn, self.view, 20.f),
                    MTMMatchTop(saveBtn, closeBtn, 0),
                    MTMMatchTop(loadBranchBtn, closeBtn, 0),
                    MTMConstraintLeft(saveBtn, closeBtn, 24.f),
                    MTMConstraintLeft(loadBranchBtn, saveBtn, 24.f));

  MTMActivateLayout(MTMMatchLeft(titleLabel, self.view, 24.f),
                    MTMMatchTop(titleLabel, self.view, 20.f),
                    );

  // Setup content scroll
  _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  _scrollView.alwaysBounceHorizontal = NO;
  _scrollView.showsHorizontalScrollIndicator = NO;
  _scrollView.alwaysBounceVertical = YES;
  _scrollView.showsVerticalScrollIndicator = YES;
  _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  _scrollView.translatesAutoresizingMaskIntoConstraints = NO;

  [self.view addSubview:_scrollView];
  MTMActivateLayout(MTMMatchLeft(_scrollView, self.view, 0),
                    MTMMatchRight(_scrollView, self.view, 0),
                    MTMMatchBottom(_scrollView, self.view, 0),
                    MTMConstraintBelow(_scrollView, titleLabel, 12.f));

  _contentView = [[UIView alloc] initWithFrame:CGRectZero];
  _contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [_scrollView addSubview:_contentView];
  MTMActivateLayoutArray(MTMInsetView(_contentView, _scrollView, UIEdgeInsetsZero));

  NSLayoutConstraint *height = MTMMatchHeight(_contentView, _scrollView, 1);
  height.priority = UILayoutPriorityDefaultLow;
  MTMActivateLayout(MTMMatchWidth(_contentView, _scrollView, 1),
                    height);

  // Set up settings content
  [self _setupMainSection];
  [self _setupButtonAction];

  // Draggable
  self.draggableView = self.view;
}

- (void)_setupMainSection
{
  // Quest section
  UIView *prev = [self _setupQuestSection];
  prev = [self _setupEventQuestSection:prev];
  prev = [self _setupAdvancedSettings:prev];

  MTMActivateLayout(MTMMatchBottom(_contentView, prev, -36));
}

- (UIView *)_setupQuestSection
{
  UIView *section = [[UIView alloc] initWithFrame:CGRectZero];
  section.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:section];
  MTMActivateLayout(MTMMatchTop(section, _contentView, 0),
                    MTMMatchLeft(section, _contentView, 24),
                    MTMMatchRight(section, _contentView, 24));

  UILabel *sectionTitle = SecondaryLabel(@"Quest Settings");
  [section addSubview:sectionTitle];
  MTMActivateLayout(MTMMatchTop(sectionTitle, section, 0),
                    MTMMatchLeft(sectionTitle, section, 0),
                    MTMMatchRight(sectionTitle, section, 0));


  UILabel *questType = TagLabel(@"Quest Type");
  [section addSubview:questType];
  UIButton *questTypeBtn = ControlBtn(@"Generic Quest Select");
  [section addSubview:questTypeBtn];
  _btns[@(MTMPreferenceKeyQuestType)] = questTypeBtn;
  MTMActivateLayout(MTMConstraintBelow(questType, sectionTitle, 16.f),
                    MTMMatchLeft(questType, section, 0),
                    MTMMatchCenterY(questTypeBtn, questType, 0),
                    MTMConstraintRight(questTypeBtn, questType, 12.f));

  UILabel *questFromTop = TagLabel(@"Quest from Top");
  [section addSubview:questFromTop];
  UIButton *questFromTopBtn = ControlBtn(@"0");
  [section addSubview:questFromTopBtn];
  _btns[@(MTMPreferenceKeyQuestIndex)] = questFromTopBtn;
  MTMActivateLayout(MTMConstraintBelow(questFromTop, questTypeBtn, 16.f),
                    MTMMatchLeft(questFromTop, section, 0),
                    MTMMatchCenterY(questFromTopBtn, questFromTop, 0),
                    MTMConstraintRight(questFromTopBtn, questFromTop, 12.f));

  UILabel *suppSelect = TagLabel(@"Support Select");
  [section addSubview:suppSelect];
  UIButton *suppSelectBtn = ControlBtn(@"Always First");
  [section addSubview:suppSelectBtn];
  _btns[@(MTMPreferenceKeySupportSelect)] = suppSelectBtn;
  MTMActivateLayout(MTMConstraintBelow(suppSelect, questFromTopBtn, 16.f),
                    MTMMatchLeft(suppSelect, section, 0),
                    MTMMatchCenterY(suppSelectBtn, suppSelect, 0),
                    MTMConstraintRight(suppSelectBtn, suppSelect, 12.f));

  UILabel *potion = TagLabel(@"Potion");
  [section addSubview:potion];
  UIButton *potionBtn = ControlBtn(@"Never");
  [section addSubview:potionBtn];
  _btns[@(MTMPreferenceKeyPotion)] = potionBtn;
  MTMActivateLayout(MTMConstraintBelow(potion, suppSelectBtn, 16.f),
                    MTMMatchLeft(potion, section, 0),
                    MTMMatchCenterY(potionBtn, potion, 0),
                    MTMConstraintRight(potionBtn, potion, 12.f));

  MTMActivateLayout(MTMMatchBottom(section, potion, 0));
  return section;
}

- (UIView *)_setupEventQuestSection:(UIView *)prev
{
  UIView *section = [[UIView alloc] initWithFrame:CGRectZero];
  section.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:section];
  MTMActivateLayout(MTMConstraintBelow(section, prev, 36),
                    MTMMatchLeft(section, _contentView, 24),
                    MTMMatchRight(section, _contentView, 24));

  UILabel *sectionTitle = SecondaryLabel(@"Event Quest Settings");
  [section addSubview:sectionTitle];
  MTMActivateLayout(MTMMatchTop(sectionTitle, section, 0),
                    MTMMatchLeft(sectionTitle, section, 0),
                    MTMMatchRight(sectionTitle, section, 0));


  UILabel *questTypeDT = TagLabel(@"Daily Tower Quest Type");
  [section addSubview:questTypeDT];
  UIButton *questTypeDTBtn = ControlBtn(@"Story");
  [section addSubview:questTypeDTBtn];
  _btns[@(MTMPreferenceKeyDailyTowerQuestType)] = questTypeDTBtn;
  MTMActivateLayout(MTMConstraintBelow(questTypeDT, sectionTitle, 16.f),
                    MTMMatchLeft(questTypeDT, section, 0),
                    MTMMatchCenterY(questTypeDTBtn, questTypeDT, 0),
                    MTMConstraintRight(questTypeDTBtn, questTypeDT, 12.f));

  UILabel *questTypeMitama = TagLabel(@"Mitama's Training Quest Type");
  [section addSubview:questTypeMitama];
  UIButton *questTypeMitamaBtn = ControlBtn(@"Story");
  [section addSubview:questTypeMitamaBtn];
  _btns[@(MTMPreferenceKeyMitamaQuestType)] = questTypeMitamaBtn;
  MTMActivateLayout(MTMConstraintBelow(questTypeMitama, questTypeDTBtn, 16.f),
                    MTMMatchLeft(questTypeMitama, section, 0),
                    MTMMatchCenterY(questTypeMitamaBtn, questTypeMitama, 0),
                    MTMConstraintRight(questTypeMitamaBtn, questTypeMitama, 12.f));

  MTMActivateLayout(MTMMatchBottom(section, questTypeMitamaBtn, 0));
  return section;
}

- (UIView *)_setupAdvancedSettings:(UIView *)prev
{
  UIView *section = [[UIView alloc] initWithFrame:CGRectZero];
  section.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:section];
  MTMActivateLayout(MTMConstraintBelow(section, prev, 36),
                    MTMMatchLeft(section, _contentView, 24),
                    MTMMatchRight(section, _contentView, 24));

  UILabel *sectionTitle = SecondaryLabel(@"Experimental Settings");
  [section addSubview:sectionTitle];
  MTMActivateLayout(MTMMatchTop(sectionTitle, section, 0),
                    MTMMatchLeft(sectionTitle, section, 0),
                    MTMMatchRight(sectionTitle, section, 0));


  UILabel *speedupMode = TagLabel(@"Speedup Mode");
  [section addSubview:speedupMode];
  UIButton *speedupModeBtn = ControlBtn(@"Minimal");
  [section addSubview:speedupModeBtn];
  _btns[@(MTMPreferenceKeySpeedupMode)] = speedupModeBtn;
  MTMActivateLayout(MTMConstraintBelow(speedupMode, sectionTitle, 16.f),
                    MTMMatchLeft(speedupMode, section, 0),
                    MTMMatchCenterY(speedupModeBtn, speedupMode, 0),
                    MTMConstraintRight(speedupModeBtn, speedupMode, 12.f));

  UILabel *skillCount = TagLabel(@"Skill Count");
  [section addSubview:skillCount];
  UIButton *skillCountBtn = ControlBtn(@"Divides by 5");
  [section addSubview:skillCountBtn];
  _btns[@(MTMPreferenceKeySkillCount)] = skillCountBtn;
  MTMActivateLayout(MTMConstraintBelow(skillCount, speedupModeBtn, 16.f),
                    MTMMatchLeft(skillCount, section, 0),
                    MTMMatchCenterY(skillCountBtn, skillCount, 0),
                    MTMConstraintRight(skillCountBtn, skillCount, 12.f));

  UILabel *loopTimer = TagLabel(@"Loop Timer");
  [section addSubview:loopTimer];
  UIButton *loopTimerBtn = ControlBtn(@"2.5");
  [section addSubview:loopTimerBtn];
  _btns[@(MTMPreferenceKeyLoopTimer)] = loopTimerBtn;
  MTMActivateLayout(MTMConstraintBelow(loopTimer, skillCountBtn, 16.f),
                    MTMMatchLeft(loopTimer, section, 0),
                    MTMMatchCenterY(loopTimerBtn, loopTimer, 0),
                    MTMConstraintRight(loopTimerBtn, loopTimer, 12.f));

  MTMActivateLayout(MTMMatchBottom(section, loopTimerBtn, 0));
  return section;
}

- (void)didTapButton:(UIButton *)sender
{
  // First, identify which was clicked.
  NSArray<NSNumber *> *keys = [_btns allKeysForObject:sender];
  if (keys.count > 1 || keys.count == 0) {
    [[MTMRecord get] record:@"[error][quick-pref] ambiguous button key"];
    return;
  }
  NSNumber *key = keys.firstObject;
  NSString *strKey = MTMPreferenceStringKey(key.integerValue);
  MTMPopoverListViewController *vc = [[MTMPopoverListViewController alloc] initWithItems:MTMPreferenceTitleValuesFromKey(strKey) title:strKey key:key];
  vc.delegate = self;
  vc.modalPresentationStyle = UIModalPresentationPopover;
  vc.popoverPresentationController.sourceView = sender;
  vc.popoverPresentationController.sourceRect = sender.bounds;
  [self presentViewController:vc animated:YES completion:nil];
}

- (void)_setupButtonAction
{
  for (NSNumber *key in _btns) {
    UIButton *btn = _btns[key];
    [btn addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
  }
}

- (void)reload
{
  for (NSNumber *key in _btns) {
    UIButton *btn = _btns[key];
    [btn setTitle:_viewModel[key] forState:UIControlStateNormal];
  }
  [self.view setNeedsLayout];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self loadViewModel];
  [self reload];
}

- (void)show
{
  self.view.hidden = NO;
  [self loadViewModel];
  [self reload];
}

- (void)didTapCloseButton:(id)sender
{
  self.view.hidden = YES;
}

- (void)didTapSaveButton:(id)sender
{
  [self _savePreference];
}

- (void)didTapLoadBranchButton:(id)sender
{
  [[MTMEventParamFetcher get] startFetching];
}

#pragma mark - MTMPopoverListProtocol

- (void)popoverListViewController:(MTMPopoverListViewController *)vc
         didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSNumber *prefKey = vc.itemKey;
  NSString *selectedValue = vc.items[indexPath.row];
  _viewModel[prefKey] = selectedValue;
  NSString *strKey = MTMPreferenceStringKey(prefKey.integerValue);
  _prefCopy[strKey] = MTMPreferenceValuesFromKey(strKey)[indexPath.row];
  [self reload];
}

- (void)_savePreference
{
  [[MTMPreference get] savePreference:_prefCopy];
}

@end
