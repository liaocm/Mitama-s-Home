//
//  MTMConsoleView.m
//  libmitamaui
//
//  Created by Chengming Liao on 6/28/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMConsoleView.h"

@implementation MTMConsoleView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
  if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
    self.backgroundColor = UIColor.blackColor;
  }
  return self;
}

@end
