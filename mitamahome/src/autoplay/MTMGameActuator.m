#import "MTMGameActuator.h"

#import <WebKit/WebKit.h>

#ifdef MITAMA_THEOS_BUILD
#import <PTFakeTouch/PTFakeMetaTouch.h>
#endif

#import "MTMPreference.h"
#import "MTMRecord.h"
#import "MTMUIStore.h"

#import "MTMJSCall.h"

static void ExecuteTapAt(CGFloat x, CGFloat y)
{
#ifdef MITAMA_THEOS_BUILD
  @try {
    NSInteger pointId =
    [PTFakeMetaTouch
      fakeTouchId:[PTFakeMetaTouch getAvailablePointId]
      AtPoint:CGPointMake(x, y)
      withTouchPhase:UITouchPhaseBegan];

    [PTFakeMetaTouch
      fakeTouchId:pointId
      AtPoint:CGPointMake(x, y)
      withTouchPhase:UITouchPhaseEnded];
  }
  @catch (NSException *e) {
    [[MTMRecord get] record:@"[actuator][error][critical] Exception when executing a tap: %@\n\n stack trace:\n %@", e, [e callStackSymbols]];
  }
#endif
}

static void TapScreen(NSDictionary<NSString *, NSNumber *> *_Nullable rect)
{
  if (!rect) {
    return;
  }
  CGSize screenSize = UIScreen.mainScreen.bounds.size;
  CGFloat scale = screenSize.width / 1024.f;
  CGFloat x, y, w, h;
  x = rect[@"x"].floatValue;
  y = rect[@"y"].floatValue;
  w = rect[@"w"].floatValue;
  h = rect[@"h"].floatValue;
  if (w <= 0.01 && w >= -0.01) {
    return;
  }
  int minX = (int)(x * 100);
  int minY = (int)(y * 100);
  // 10% padding start & end totalling 40%
  int wSpace = (int)(w * 60);
  int hSpace = (int)(h * 60);
  minX = minX + (int)(w * 20);
  minY = minY + (int)(h * 20);
  int maxX = minX + wSpace;
  int maxY = minY + hSpace;

  int finalX = arc4random_uniform(maxX - minX) + minX;
  int finalY = arc4random_uniform(maxY - minY) + minY;

  int finalXScaled = (int)(finalX * scale);
  int finalYScaled = (int)(finalY * scale);

  ExecuteTapAt(finalXScaled / 100.f, finalYScaled / 100.f);
}

static void MTMActuateWithTap(WKWebView *_Nonnull webview, NSString *script)
{
  [webview
    evaluateJavaScript:script
    completionHandler:^(NSDictionary<NSString *, NSNumber *> *res, NSError *_error) {
      TapScreen(res);
  }];
}

static void MTMActuateSupportSelect(WKWebView *_Nonnull webview)
{
  MTMSupportBehavior supportType = [[MTMPreference get] getSupportType];
  MTMActuateWithTap(webview, MTMSelectSupport(supportType));
}

static void MTMActuateRestoreAP(WKWebView *_Nonnull webview)
{
  MTMPotionType potionType = [[MTMPreference get] getPotionType];
  if (potionType == MTMPotionTypeNone) {
    return;
  }
  MTMActuateWithTap(webview, MTMRestoreAP(potionType));
}

static void MTMActuateQuestSelect(WKWebView *_Nonnull webview)
{
  MTMQuestType questType = [[MTMPreference get] getQuestType];
  NSInteger questIdx = [[MTMPreference get] getQuestIndex];
  switch (questType) {
    case MTMQuestTypeGenericStory:
      MTMActuateWithTap(webview, MTMGenericStoryQuestSelect(questIdx));
      break;
    case MTMQuestTypeWeeklyMaterial:
    case MTMQuestTypeWeekAwakening: {
      MTMWeeklyQuestType type = questType == MTMQuestTypeWeeklyMaterial
      ? MTMWeeklyQuestTypeMaterial
      : MTMWeeklyQuestTypeAwakening;
      MTMActuateWithTap(webview, MTMWeeklyQuestSelect(type, questIdx));
      break;
    }
    case MTMQuestTypeEventDailyTower:
      MTMActuateWithTap(
        webview,
        MTMEventDailyTowerQuestSelect(
          [[MTMPreference get] getDailyTowerDifficulty],
          questIdx
      ));
      break;
    case MTMQuestTypeEventBranch: {
      NSArray<NSNumber *> *params = [[MTMPreference get] getBranchParameters];
      if (params.count == 0) {
        return;
      }
      if (!webview.isHidden) {
        MTMActuateWithTap(
          webview,
          MTMEventBranchQuestSelect(
            params[0].intValue,
            params[1].intValue,
            params[2].intValue,
            params[3].intValue
        ));
      } else {
        [webview
          evaluateJavaScript:MTMEventBranchSkipStory()
          completionHandler:nil];
      }
      break;
    }
    case MTMQuestTypeEventTraining:
      MTMActuateWithTap(webview, MTMEventTrainingQuestSelect([[MTMPreference get] getTrainingType], questIdx));
      break;
    case MTMQuestTypeEventSingleRaid:
      // Generic Select works here
      MTMActuateWithTap(webview, MTMGenericStoryQuestSelect(questIdx));
      break;
    case MTMQuestTypeEventStoryRaid:
    // Not implemented -- Last Magia only
    default:
      [[MTMRecord get] record:@"[actuator][warning] unsupported quest type %@", @(questType)];
  }
}

void MTMActuateGameScene(MTMSceneName scene)
{
  WKWebView *webview = [MTMUIStore get].webview;
  if (!webview) {
    [[MTMRecord get] record:@"[actuator][error] webview is nil"];
    return;
  }
  if (scene == MTMSceneNameStageSelect) {
    MTMActuateQuestSelect(webview);
  } else if (scene == MTMSceneNameSupportSelect) {
    MTMActuateSupportSelect(webview);
  } else if (scene == MTMSceneNameTeamSelect) {
    MTMActuateWithTap(webview, MTMTeamSelectPlay());
  } else if (scene == MTMSceneNameClearResult) {
    TapScreen(@{
      @"x": @(780.0),
      @"y": @(280.0),
      @"w": @(200.0),
      @"h": @(200.0)
    });
  } else if (scene == MTMSceneNameRestoreAP) {
    MTMActuateRestoreAP(webview);
  } else if (scene == MTMSceneNameRestoreConfirm) {
    MTMActuateWithTap(webview, MTMRestoreConfirm());
  } else if (scene == MTMSceneNameRankup) {
    MTMActuateWithTap(webview, MTMRankupConfirm());
  } else if (scene == MTMSceneNameAddFriendYesNo) {
    MTMActuateWithTap(webview, MTMFriendFollowDecline());
  } else {
    // no-op
  }
}
