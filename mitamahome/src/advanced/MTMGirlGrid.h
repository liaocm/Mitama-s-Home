//
//  MTMGirlGrid.h
//  
//
//  Created by Chengming Liao on 7/26/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTMGirlGrid : UIView

- (instancetype)initWithFrame:(CGRect)frame
                     gridSize:(CGFloat)size
                       isAlly:(BOOL)isAlly;

@end

NS_ASSUME_NONNULL_END
