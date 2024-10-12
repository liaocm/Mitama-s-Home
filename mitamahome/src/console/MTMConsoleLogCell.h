//
//  MTMConsoleLogCell.h
//  libmitamaui
//
//  Created by Chengming Liao on 6/28/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTMConsoleLogCell : UICollectionViewCell

- (void)setModel:(NSString *)model;
+ (CGSize)sizeWithModel:(NSString *)model thatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
