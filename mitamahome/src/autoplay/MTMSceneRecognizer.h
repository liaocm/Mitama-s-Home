#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MTMSceneName) {
  MTMSceneNameUnknown = 0,
  MTMSceneNameStageSelect = 1,
  MTMSceneNameSupportSelect = 2,
  MTMSceneNameTeamSelect = 3,
  MTMSceneNameClearResult = 4,
  MTMSceneNameRestoreAP = 5,
  MTMSceneNameRestoreConfirm = 6,
  MTMSceneNameRankup = 7,
  MTMSceneNameAddFriendYesNo = 8,
  MTMSceneNameMegucaLevelUp = 9,
  MTMSceneNameInBattle = 10
};

@interface MTMSceneRecognizer : NSObject

+ (void)matchScene:(void (^)(MTMSceneName))callback;

@end
