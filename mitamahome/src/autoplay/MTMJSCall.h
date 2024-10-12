#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MTMEventDailyTowerDifficulty) {
    MTMEventDailyTowerDifficultyNormal = 0,
    MTMEventDailyTowerDifficultyChallenge = 1,
    MTMEventDailyTowerDifficultyExChallenge = 2
};

typedef NS_ENUM(NSInteger, MTMWeeklyQuestType) {
    MTMWeeklyQuestTypeMaterial = 0,
    MTMWeeklyQuestTypeAwakening
};

typedef NS_ENUM(NSInteger, MTMSupportBehavior) {
    MTMSupportBehaviorAlwaysFirst = 0,
    MTMSupportBehaviorBonusOnly = 1,
    MTMSupportBehaviorBonusIfPossible = 2,
    MTMSupportBehaviorNPC = 3
};

typedef NS_ENUM(NSInteger, MTMPotionType) {
    MTMPotionTypeNone = 0,
    MTMPotionType50AP = 1,
    MTMPotionTypeMAXAP = 2,
    MTMPotionTypeGem = 3
};

typedef NS_ENUM(NSInteger, MTMTrainingType) {
    MTMTrainingTypeStory = 0,
    MTMTrainingTypeEnhance = 1,
    MTMTrainingTypeEpisode = 2,
    MTMTrainingTypeExtra = 3
};

// Operational Calls

NSString *MTMSelectSupport(MTMSupportBehavior behavior);
NSString *MTMTeamSelectPlay();
NSString *MTMFriendFollowDecline();
NSString *MTMRankupConfirm();
NSString *MTMRestoreAP(MTMPotionType potion);
NSString *MTMRestoreConfirm();

// Quests
NSString *MTMGenericStoryQuestSelect(NSInteger idx);
NSString *MTMWeeklyQuestSelect(MTMWeeklyQuestType type, NSInteger idx);

NSString *MTMEventDailyTowerQuestSelect(MTMEventDailyTowerDifficulty diff, NSInteger idx);

NSString *MTMEventBranchQuestSelect(NSInteger battleId, NSInteger pointId, NSInteger charId, NSInteger titleId);
NSString *MTMEventBranchSkipStory();

NSString *MTMEventTrainingQuestSelect(MTMTrainingType type, NSInteger idx);

NSString *MTMEventSingleRaidQuestSelect(NSInteger idx);
