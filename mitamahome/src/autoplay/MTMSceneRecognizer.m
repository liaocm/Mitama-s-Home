#import "MTMSceneRecognizer.h"

#import <WebKit/WebKit.h>

#import "MTMPreference.h"
#import "MTMRecord.h"
#import "MTMUIStore.h"

@implementation MTMSceneRecognizer

+ (void)matchScene:(void (^)(MTMSceneName))callback
{
  if (!callback) {
    return;
  }

  WKWebView *webview = [MTMUIStore get].webview;
  if (!webview) {
    [[MTMRecord get] record:@"[scene-recognizer][error] webview is nil"];
    return;
  }
  MTMQuestType questType = [[MTMPreference get] getQuestType];
  NSString *questPath = URIPathForQuestType(questType);

  NSString *url = webview.URL.absoluteString;

  if (FindStrKeyword(url, @"SupportSelect")) {
    callback(MTMSceneNameSupportSelect);
    return;
  } else if (FindStrKeyword(url, @"DeckFormation/quest")) {
    callback(MTMSceneNameTeamSelect);
    return;
  } else if (FindStrKeyword(url, @"QuestBackground")) {
    callback(MTMSceneNameInBattle);
  } else if (FindStrKeyword(url, questPath) || FindStrKeyword(url, @"QuestResult")) {
    BOOL isStageSelect = FindStrKeyword(url, questPath);
    BOOL isQuestResult = FindStrKeyword(url, @"QuestResult");
    [webview
      evaluateJavaScript:@"document.documentElement.outerHTML.toString()"
      completionHandler:^(NSString *html, NSError *_error) {
        if (isStageSelect && FindStrKeyword(html, @"AP回復薬50")) {
          callback(MTMSceneNameRestoreAP);
          return;
        } else if (isStageSelect && FindStrKeyword(html, @"を使ってAPを回復します。")) {
          callback(MTMSceneNameRestoreConfirm);
          return;
        } else if (isStageSelect) {
          callback(MTMSceneNameStageSelect);
          return;
        } else if (isQuestResult) {
          [webview
            evaluateJavaScript:@"(document.getElementById(\"followNoBtn\") == null).toString()"
            completionHandler:^(NSString *result, NSError *_error) {
              if ([result isEqual:@"true"]) {
                [webview
                  evaluateJavaScript:@"(document.getElementsByClassName(\"rankPopClose\").length == 0).toString()"
                  completionHandler:^(NSString *result, NSError *_error) {
                    if ([result isEqual:@"true"]) {
                      callback(MTMSceneNameClearResult);
                    } else {
                      callback(MTMSceneNameRankup);
                    }
                }];
              } else {
                [webview
                  evaluateJavaScript:@"(document.getElementsByClassName(\"rankPopClose\").length == 0).toString()"
                  completionHandler:^(NSString *result, NSError *_error) {
                    if ([result isEqual:@"true"]) {
                      callback(MTMSceneNameAddFriendYesNo);
                    } else {
                      callback(MTMSceneNameRankup);
                    }
                }];
              }
              return;
          }];
          return;
        }
        [[MTMRecord get] record:@"[scene-recognizer][info] unrecognized scene for quest path: %@. URL: %@", questPath, url];
        callback(MTMSceneNameUnknown);
      }
    ];
  } else {
    [[MTMRecord get] record:@"[scene-recognizer][info] unrecognized scene for quest path: %@. URL: %@", questPath, url];
    callback(MTMSceneNameUnknown);
  }
}

static BOOL FindStrKeyword(NSString *str, NSString *keyword)
{
  return
  [str
    rangeOfString:keyword
    options:NSRegularExpressionSearch].location != NSNotFound;
}

static NSString *URIPathForQuestType(MTMQuestType questType)
{
  if (questType == MTMQuestTypeGenericStory) {
    return @"QuestBattleSelect";
  } else if (questType == MTMQuestTypeWeeklyMaterial) {
    return @"EventQuest";
  } else if (questType == MTMQuestTypeWeekAwakening) {
    return @"EventQuest";
  } else if (questType == MTMQuestTypeEventDailyTower) {
    return @"EventDailyTowerTop";
  } else if (questType == MTMQuestTypeEventBranch) {
    return @"EventBranchTop";
  } else if (questType == MTMQuestTypeEventTraining) {
    return @"EventTrainingTop";
  } else if (questType == MTMQuestTypeEventStoryRaid) {
    return @"EventStoryRaidTop";
  } else if (questType == MTMQuestTypeEventSingleRaid) {
    return @"EventSingleRaidTop";
  } else {
    // fallback
    [[MTMRecord get] record:@"[scene-recognizer][error] bad quest type %@, falling back to generic", @(questType)];
    return @"QuestBattleSelect";
  }
}

@end
