//
//  MTMLiteControlPanelView.h
//  libmitamaui
//
//  Created by Chengming Liao on 7/2/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MTMLiteControlTapAction)(NSInteger, id _Nullable);

@interface MTMLiteControlPanelView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                    tapAction:(MTMLiteControlTapAction)tapAction;

@end

NS_ASSUME_NONNULL_END
