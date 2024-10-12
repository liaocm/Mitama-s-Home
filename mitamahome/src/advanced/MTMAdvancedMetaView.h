//
//  MTMAdvancedMetaView.h
//  
//
//  Created by Chengming Liao on 7/26/20.
//

#import <UIKit/UIKit.h>

@class MTMAdvancedMetaView;

NS_ASSUME_NONNULL_BEGIN

@protocol MTMAdvancedMetaViewDataHandling <NSObject>

- (void)advancedMetaViewDidConfirmData:(MTMAdvancedMetaView *)view;

@end

@interface MTMAdvancedMetaView : UIView

- (NSDictionary *)model;

@property (nonatomic, weak) id<MTMAdvancedMetaViewDataHandling> delegate;

@end

NS_ASSUME_NONNULL_END
