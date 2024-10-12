//
//  MTMPopoverListViewController.h
//  libmitamaui
//
//  Created by Chengming Liao on 8/4/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTMPopoverListViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol MTMPopoverListProtocol <NSObject>

- (void)popoverListViewController:(MTMPopoverListViewController *)vc
         didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MTMPopoverListViewController : UIViewController

- (instancetype)initWithItems:(NSArray *)items
                        title:(NSString *)title
                          key:(NSNumber *)key;

@property (nonatomic, readonly) NSNumber *itemKey;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, weak) id<MTMPopoverListProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
