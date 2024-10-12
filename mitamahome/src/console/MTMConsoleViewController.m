//
//  MTMConsoleViewController.m
//  libmitamaui
//
//  Created by Chengming Liao on 6/28/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMConsoleViewController.h"

#import "MTMConsoleView.h"
#import "MTMRecord.h"
#import "MTMConsoleLogCell.h"
#import "MTMLayout.h"
#import "MTMUIStore.h"

#import "MTMTelepathy.h"

@interface MTMConsoleViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MTMRecordListener>

@end

@implementation MTMConsoleViewController
{
  NSArray<NSString *> *_model;
  MTMConsoleView *_consoleView;
}

- (void)loadView
{
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  flowLayout.minimumLineSpacing = 0.f;
  flowLayout.minimumInteritemSpacing = 0.f;
  _consoleView = [[MTMConsoleView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
  _consoleView.delegate = self;
  _consoleView.dataSource = self;
  _consoleView.alwaysBounceVertical = YES;
  _consoleView.scrollEnabled = YES;
  [_consoleView registerClass:MTMConsoleLogCell.class forCellWithReuseIdentifier:@"logCellReuseIdentifier"];
  _consoleView.translatesAutoresizingMaskIntoConstraints = NO;

  self.view = [[UIView alloc] initWithFrame:CGRectZero];
  self.view.backgroundColor = [[UIColor alloc] initWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
  self.view.layer.cornerRadius = 16.f;
  [self.view addSubview:_consoleView];
  MTMActivateLayoutArray(MTMInsetView(_consoleView, self.view, UIEdgeInsetsMake(40.f, 12.f, 12.f, 12.f)));

  UIButton *closeButton = MTMGenericButtonCreate(@"Close");
  [closeButton addTarget:self action:@selector(didTapClose) forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:closeButton];
  MTMActivateLayout(MTMMatchTop(closeButton, self.view, 6.f),
                    MTMMatchRight(closeButton, self.view, 12.f));

  UIButton *dumpButton = MTMGenericButtonCreate(@"Dump");
  [dumpButton addTarget:self action:@selector(didTapDump) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:dumpButton];
  MTMActivateLayout(MTMMatchTop(dumpButton, self.view, 6.f),
                    MTMConstraintLeft(dumpButton, closeButton, 12.f));

  UILabel *titleLabel = [UILabel new];
  titleLabel.textColor = UIColor.blackColor;
  titleLabel.font = [UIFont systemFontOfSize:24.f weight:UIFontWeightBold];
  titleLabel.numberOfLines = 1;
  titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  titleLabel.text = @"Console";
  titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:titleLabel];
  MTMActivateLayout(MTMMatchTop(titleLabel, self.view, 4.f),
                    MTMMatchLeft(titleLabel, self.view, 12.f));
  [self.view addSubview:titleLabel];

  _resizeView = [[UIView alloc] initWithFrame:CGRectZero];
  _resizeView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_resizeView];
  MTMActivateLayout(MTMSetWidth(_resizeView, 48),
                    MTMSetHeight(_resizeView, 48),
                    MTMMatchBottom(_resizeView, self.view, 0),
                    MTMMatchRight(_resizeView, self.view, 0));

  self.resizeTargetView = _resizeView;
  self.draggableView = self.view;
  self.minWidth = 320;
  self.minHeight = 240;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self reload];
  [[MTMRecord get] addListener:self];
}

- (void)invalidateLayout
{
  [_consoleView.collectionViewLayout invalidateLayout];
}

- (void)resizeHandler
{
  [self invalidateLayout];
}

- (void)reload
{
  _model = [[MTMRecord get] displayList];
  [_consoleView reloadData];
  if (_model.count >= 1) {
    [_consoleView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_model.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
  }

}

- (void)didTapClose
{
  self.view.hidden = !self.view.hidden;
}

- (void)didTapDump
{
  NSDate *now = [NSDate now];
  NSDateFormatter *formatter = [NSDateFormatter new];
  formatter.dateFormat = @"MMM-dd-HH-mm-ss";
  NSString *dateString = [formatter stringFromDate:now];
  NSString *path = [NSString stringWithFormat:@"/var/mobile/Documents/mitama.home.console-dump.%@.txt", dateString];
  NSMutableString *content = [[NSMutableString alloc] init];
  for (NSString *line in _model) {
    [content appendFormat:@"%@\n", line];
  }
#ifdef MITAMA_THEOS_BUILD
  [[MTMTelepathy get] appendContentAt:path content:content];
#else
  UIPasteboard.generalPasteboard.string = content;
#endif
  [MTMRecord clear];
  [[MTMRecord get] record:@"[info][console] Dumped at %@", path];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return _model.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  MTMConsoleLogCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"logCellReuseIdentifier" forIndexPath:indexPath];
  [cell setModel:_model[indexPath.row]];
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  CGSize maxSize = [MTMConsoleLogCell sizeWithModel:_model[indexPath.row] thatFits:CGSizeMake(collectionView.bounds.size.width, CGFLOAT_MAX)];
  return CGSizeMake(collectionView.bounds.size.width, maxSize.height);
}

// MTMRecordListener
- (void)recordDidUpdate:(MTMRecord *)record
{
  [self reload];
}

@end
