#import "MTMAdvancedDiscViewController.h"

#import "MTMAdvancedDiscView.h"
#import "MTMRecord.h"
#import "MTMHookManager.h"

@interface MTMAdvancedDiscViewController () <MTMAdvancedDiscViewDataHandling>

@end

@implementation MTMAdvancedDiscViewController
{
  MTMAdvancedDiscView *_contentView;
}

- (void)loadView
{
  _contentView = [[MTMAdvancedDiscView alloc] initWithFrame:CGRectZero];
  self.view = _contentView;
  _contentView.delegate = self;
}

- (void)advancedDiscViewDidConfirmData:(MTMAdvancedDiscView *)view
{
  self.view.hidden = YES;
  // handle here.
  NSDictionary *models = view.applicableModels;
  [[MTMRecord get] record:@"[info][adv-disc] setting override:\n%@", models];
  [[MTMHookManager get] setDiscOverrides:models];
}

@end
