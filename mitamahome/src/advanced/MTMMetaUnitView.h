//
//  MTMMetaUnitView.h
//
//
//  Created by Chengming Liao on 7/26/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NSMutableDictionary<NSString *, NSString *> *MTMMetaGirlDefaultSingleModel(void);

@interface MTMMetaUnitView : UIView

- (NSArray<NSDictionary<NSString *, NSString *> *> *)viewModel;

@end

NS_ASSUME_NONNULL_END
