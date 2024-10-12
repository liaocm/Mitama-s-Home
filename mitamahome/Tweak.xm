#import "MTMHooks.h"

// Base
#import "MTMPreference.h"
#import "MTMTelepathy.h"
#import "MTMUIStore.h"
#import "MTMRecord.h"

#import <WebKit/WebKit.h>

// UI
#import "MTMLayout.h"
#import "MTMLiteControlViewController.h"
#import "MTMConsoleViewController.h"
#import "MTMAdvancedDiscViewController.h"
#import "MTMAdvancedMetaViewController.h"
#import "MTMQuickPreferenceViewController.h"

// AutoPlay
#import "MTMEventDriver.h"
#import "MTMEventParamFetcher.h"

%group main

#pragma mark - Experimental stuffs

/// START OF FORMAL HOOKS ///

#pragma mark - Apple stuffs

%hook _UIFlowLayoutSection

-(void)logInvalidSizesForHorizontalDirection:(BOOL)arg1 warnAboutDelegateValues:(BOOL)arg2
{
  return;
}

%end

#pragma mark - crash logs

%hook SmartBeat

+ (id)shared {
  return nil;
}

+ (id)startWithApiKey:(NSString *)apiKey
{
  return nil;
}

+ (id)startWithApiKey:(NSString *)apiKey withEnabled:(BOOL)arg2
{
  return nil;
}

- (id)initWithApiKey:(id)arg1
{
  return nil;
}

%end

%hook SmartBeatUtil

+ (BOOL)isJailbroken
{
  return NO;
}

%end

// This is NA server specific. RIP NA.
// %hook CYZDefines

// + (id)sharedDefines
// {
//   CYZDefines *orig = %orig;
//   MSHookIvar<BOOL>(orig, "_isJailBreaked") = NO;
//   return orig;
// }

// - (BOOL)checkJailBreak
// {
//   return NO;
// }

// - (BOOL)isJailBreaked
// {
//   return NO;
// }

// %end

#pragma mark - WebViews

%hook WebViewWrapper

// TODO: pass this!
- (void)userContentController:(WKUserContentController *)arg1 didReceiveScriptMessage:(WKScriptMessage *)arg2
{
  // [[MTMRecord get] record:@"[root][debug] script message received: %@\nbody:%@\nname:%@", arg2, arg2.body, arg2.name];
  %orig;
}

- (void)setWkWebView:(WKWebView *)wkWebView
{
  %orig;
  [[MTMUIStore get] setWebView:wkWebView];
}

// - (void)setWkConfig:(WKWebViewConfiguration *)wkConfig
// {
//   NSLog(@"[mitama] wkconfig %@, %@", wkConfig, wkConfig.userContentController.userScripts);

//   WKUserContentController *contentController = wkConfig.userContentController;
//   WKUserScript *script =
//   [[WKUserScript alloc] initWithSource:@"asd"
//    injectionTime:WKUserScriptInjectionTimeAtDocumentStart
//    forMainFrameOnly:NO];
//   %orig;
// }

%end

// %hook WKUserContentController

// - (void)addUserScript:(WKUserScript *)userScript
// {
//   NSLog(@"[mitama] add script %@, %@", userScript.source, @(userScript.injectionTime));
//   %orig;
// }

// - (void)addScriptMessageHandler:(id<WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name
// {
//   NSLog(@"[mitama] message handler %@, %@", scriptMessageHandler, name);
//   %orig;
// }

// %end

%hook WKWebView

// TODO: pass this!
- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^)(id, NSError *error))completionHandler
{
  // [[MTMRecord get] record:@"[root][debug] evaluating script: %@", javaScriptString];
  [[MTMEventParamFetcher get] processDataIfNecessary:javaScriptString];
  %orig;
}

%end

#pragma mark - RootViewController

static MTMLiteControlViewController *controlVC;
static MTMConsoleViewController *consoleVC;
static MTMAdvancedDiscViewController *advDiscVC;
static MTMAdvancedMetaViewController *advMetaVC;
static MTMQuickPreferenceViewController *settingsVC;

%hook RootViewController

- (void)viewDidLoad
{
  %orig;
  [[MTMUIStore get] setRootView:self.eaglView];
  controlVC = [[MTMLiteControlViewController alloc] initWithAction:^(NSInteger type, id _Nullable model) {
    // TODO: ENUM-ify the type
    if (type == 3) {
      // Open Console
      consoleVC.view.hidden = NO;
      [self.eaglView bringSubviewToFront:consoleVC.view];
    } else if (type == 1) {
      // Toggle autoplay
      MTMEventDriver *driver = [MTMEventDriver get];
      if (driver.isActive) {
        [driver stop];
      } else {
        [driver start];
      }
    } else if (type == 4) {
      // speed up
      MTMEventDriver *driver = [MTMEventDriver get];
      if (driver.isSpeedupActive) {
        [driver stopSpeedup];
      } else {
        [driver speedup];
      }
    } else if (type == 5) {
      // adv disc settings
      advDiscVC.view.hidden = NO;
      [self.eaglView bringSubviewToFront:advDiscVC.view];
    } else if (type == 6) {
      advMetaVC.view.hidden = NO;
      [self.eaglView bringSubviewToFront:advMetaVC.view];
    } else if (type == 2) {
      [settingsVC show];
      [self.eaglView bringSubviewToFront:settingsVC.view];
    }
  }];
  controlVC.view.translatesAutoresizingMaskIntoConstraints = NO;
  [self addChildViewController:controlVC];
  [self.eaglView addSubview:controlVC.view];
  controlVC.view.hidden = YES;

  CGSize screenSize = UIScreen.mainScreen.bounds.size;

  [controlVC
   setParentConstraintsWithCenterX:MTMMatchCenterX(controlVC.view, self.eaglView, 0)
   centerY:MTMMatchCenterY(controlVC.view, self.eaglView, 0)
   width:MTMSetWidth(controlVC.view, screenSize.width - 120)
   height:MTMSetHeight(controlVC.view, screenSize.height - 480)];

  consoleVC = [MTMConsoleViewController new];
  consoleVC.view.translatesAutoresizingMaskIntoConstraints = NO;
  [self addChildViewController:consoleVC];
  [self.eaglView addSubview:consoleVC.view];
  [consoleVC reload];
  consoleVC.view.hidden = YES;

  [consoleVC
   setParentConstraintsWithCenterX:MTMMatchCenterX(consoleVC.view, self.eaglView, 0)
   centerY:MTMMatchCenterY(consoleVC.view, self.eaglView, 0)
   width:MTMSetWidth(consoleVC.view, screenSize.width - 200.f)
   height:MTMSetHeight(consoleVC.view, screenSize.height - 240.f)];

  __weak __typeof(self) weakSelf = self;
  [[MTMUIStore get] setCallback:^(NSInteger type, id sender) {
    __strong __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {return;}
    [[MTMRecord get] record:@"[root][info] UI gesture received: %ld", type];
    if (type == 1) {
      // edge pan
      consoleVC.view.hidden = !consoleVC.view.hidden;
      [strongSelf.eaglView bringSubviewToFront:consoleVC.view];
    }
  }];

  advDiscVC = [[MTMAdvancedDiscViewController alloc] init];
  [self addChildViewController:advDiscVC];
  [self.view addSubview:advDiscVC.view];
  advDiscVC.view.hidden = YES;
  advDiscVC.view.translatesAutoresizingMaskIntoConstraints = NO;
  MTMActivateLayout(
    MTMSetWidth(advDiscVC.view, screenSize.width - 320),
    MTMSetHeight(advDiscVC.view, screenSize.height - 240),
    MTMMatchCenterX(advDiscVC.view, self.view, 0),
    MTMMatchCenterY(advDiscVC.view, self.view, 0));

  advMetaVC = [[MTMAdvancedMetaViewController alloc] init];
  [self addChildViewController:advMetaVC];
  [self.view addSubview:advMetaVC.view];
  advMetaVC.view.hidden = YES;
  advMetaVC.view.translatesAutoresizingMaskIntoConstraints = NO;
  MTMActivateLayout(
    MTMSetWidth(advMetaVC.view, screenSize.width - 200),
    MTMSetHeight(advMetaVC.view, screenSize.height - 120),
    MTMMatchCenterX(advMetaVC.view, self.view, 0),
    MTMMatchCenterY(advMetaVC.view, self.view, 0));

  settingsVC = [[MTMQuickPreferenceViewController alloc] init];
  [self addChildViewController:settingsVC];
  [self.view addSubview:settingsVC.view];
  settingsVC.view.hidden = YES;
  settingsVC.view.translatesAutoresizingMaskIntoConstraints = NO;

  [settingsVC
   setParentConstraintsWithCenterX:MTMMatchCenterX(settingsVC.view, self.eaglView, 0)
   centerY:MTMMatchCenterY(settingsVC.view, self.eaglView, 0)
   width:MTMSetWidth(settingsVC.view, screenSize.width - 320.f)
   height:MTMSetHeight(settingsVC.view, screenSize.height - 240.f)];
}

- (void)motionEnded:(UIEventSubtype)motion
          withEvent:(UIEvent *)event
{
  %orig;
  if (motion == UIEventSubtypeMotionShake) {
    controlVC.view.hidden = NO;
    [self.eaglView bringSubviewToFront:controlVC.view];
  }
}

%end

#pragma mark - AppDelegate

%hook AppController

- (void)applicationDidBecomeActive:(id)arg1 {
  %orig;
  NSDictionary *oldPref = [[MTMPreference get] getPreferences];
  NSDictionary *newPref = [[MTMPreference get] getPreferencesNoCache];
  NSMutableDictionary *diff = [NSMutableDictionary new];
  for (NSString *k in oldPref) {
    if (![oldPref[k] isEqual:newPref[k]]) {
      diff[k] = [NSString stringWithFormat:@"%@ -> %@", oldPref[k], newPref[k]];
    }
  }
  if (diff.count > 0) {
    [[MTMRecord get] record:@"[root][info] app foregrounded. Diff:\n%@", diff];
  }
}

%end

%end

void HandleException(NSException *e)
{
  NSLog(@"[mitama-home][exception] %@",e);
  NSLog(@"[mitama-home] %@",[e callStackSymbols]);

  NSString *crashLog = [NSString stringWithFormat:@"%@\n%@\n%@\n", e, e.userInfo, [e callStackSymbols]];
  [[MTMTelepathy get] saveCrashLog:crashLog];
}

%ctor {
  // Init preference loader
  MTMPreference *pref = [MTMPreference get];
  if (![pref getNumberValueForKey:@"master"].boolValue) {
    return;
  }
  [[MTMRecord get] record:@"[root][info] initializing"];
  %init(main);
  // Init message center
  if ([[MTMTelepathy get] ping]) {
    [[MTMRecord get] record:@"[root][info] mitama telepathy connected."];
  }

  // Init event fetcher
  [MTMEventParamFetcher get].callback = ^(NSDictionary *dct) {
    [[MTMPreference get] saveFetchedEventData:dct];
  };

  // Set exception
  NSSetUncaughtExceptionHandler(HandleException);
}