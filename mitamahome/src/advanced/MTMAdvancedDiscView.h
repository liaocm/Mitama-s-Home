#import <UIKit/UIKit.h>

@class MTMAdvancedDiscView;

NS_ASSUME_NONNULL_BEGIN

@protocol MTMAdvancedDiscViewDataHandling <NSObject>

- (void)advancedDiscViewDidConfirmData:(MTMAdvancedDiscView *)view;

@end

@interface MTMAdvancedDiscView : UIView

- (NSDictionary *)applicableModels;

@property (nonatomic, weak) id<MTMAdvancedDiscViewDataHandling> delegate;

@end

NS_ASSUME_NONNULL_END
