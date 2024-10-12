//
//  MTMAdvancedMetaViewController.m
//  
//
//  Created by Chengming Liao on 7/26/20.
//

#import "MTMAdvancedMetaViewController.h"

#import "MTMAdvancedMetaView.h"
#import "MTMRecord.h"
#import "MTMMetaUnitView.h"
#import "MTMHookManager.h"

@interface MTMAdvancedMetaViewController () <MTMAdvancedMetaViewDataHandling>

@end

@implementation MTMAdvancedMetaViewController
{
  MTMAdvancedMetaView *_contentView;
}

- (void)loadView
{
  _contentView = [[MTMAdvancedMetaView alloc] initWithFrame:CGRectZero];
  self.view = _contentView;
  _contentView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)advancedMetaViewDidConfirmData:(MTMAdvancedMetaView *)view
{
  self.view.hidden = YES;
  NSDictionary *models = _contentView.model;
  [[MTMRecord get] record:@"[info][adv-meta] setting override:\n%@", StringForLogging(models)];
  [[MTMHookManager get] setMiscOverrides:models];
}

static NSString *StringForLogging(NSDictionary *models) {
  NSMutableString *res = [[NSMutableString alloc] init];
  [res appendFormat:@"[enemy] =>  %@\n", models[@"enemy"]];
  [res appendFormat:@"[misc] =>   %@\n", models[@"misc"]];
  // Girls
  NSDictionary *defaultSingleModel = MTMMetaGirlDefaultSingleModel();
  NSArray<NSDictionary *> *girlsArr = models[@"girl"];
  [res appendString:@"[girls] =>  {\n"];
  for (int i = 0; i < girlsArr.count; i++) {
    if ([girlsArr[i] isEqualToDictionary:defaultSingleModel]) {
      [res appendFormat:@"  [%d] => [default]\n", (i+1)];
    } else {
      [res appendFormat:@"  [%d] => %@\n", (i+1), girlsArr[i]];
    }
  }
  [res appendString:@"};"];
  return res;
}

@end
