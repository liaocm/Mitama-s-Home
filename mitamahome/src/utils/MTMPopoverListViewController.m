//
//  MTMPopoverListViewController.m
//  libmitamaui
//
//  Created by Chengming Liao on 8/4/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMPopoverListViewController.h"

#import "MTMLayout.h"

@interface MTMPopoverListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation MTMPopoverListViewController
{
  UITableView *_tableView;
  NSString *_title;
}

- (instancetype)initWithItems:(NSArray *)items
                        title:(NSString *)title
                          key:(NSNumber *)key
{
  if (self = [super init]) {
    _items = items;
    _title = title;
    _itemKey = key;
  }
  return self;
}

- (void)loadView
{
  self.view = [[UIView alloc] initWithFrame:CGRectZero];
  self.view.backgroundColor = RGBA(245, 245, 245, 1);

  UILabel *titleLabel = [UILabel new];
  titleLabel.textColor = UIColor.blackColor;
  titleLabel.font = [UIFont systemFontOfSize:24.f weight:UIFontWeightSemibold];
  titleLabel.numberOfLines = 1;
  titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  titleLabel.text = _title;
  titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:titleLabel];

  MTMActivateLayout(MTMMatchTop(titleLabel, self.view, 16.f),
                    MTMMatchCenterX(titleLabel, self.view, 0));

  _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cellReuseId"];
  _tableView.translatesAutoresizingMaskIntoConstraints = NO;
  _tableView.delegate = self;
  _tableView.dataSource = self;
  [self.view addSubview:_tableView];

  MTMActivateLayout(MTMConstraintBelow(_tableView, titleLabel, 16.f),
                    MTMMatchLeft(_tableView, self.view, 0),
                    MTMMatchRight(_tableView, self.view, 0),
                    MTMMatchBottom(_tableView, self.view, 0));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.delegate popoverListViewController:self didSelectItemAtIndexPath:indexPath];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cellReuseId"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellReuseId"];
  }
  cell.textLabel.text = _items[indexPath.row];
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

@end
