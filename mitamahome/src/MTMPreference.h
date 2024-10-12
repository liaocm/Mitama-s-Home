// Manages R/W to PreferenceBundle. Has an in memory copy of
// the current preference file.

#import "MTMJSCall.h"

typedef NS_ENUM(NSUInteger, MTMQuestType) {
  MTMQuestTypeGenericStory = 0,
  MTMQuestTypeWeeklyMaterial = 1,
  MTMQuestTypeWeekAwakening = 2,
  MTMQuestTypeEventDailyTower = 3,
  MTMQuestTypeEventBranch = 4,
  MTMQuestTypeEventTraining = 5,
  MTMQuestTypeEventStoryRaid = 6,
  MTMQuestTypeEventSingleRaid = 7
};

typedef NS_ENUM(NSUInteger, MTMSkillCountModType) {
  MTMSkillCountModTypeNone = 0,
  MTMSkillCountModTypeAlwaysZero = 1,
  MTMSkillCountModTypeDivideByFive = 2,
  MTMSkillCountModTypeDivideByTen = 3
};

typedef NS_ENUM(NSUInteger, MTMPreferenceKey) {
  MTMPreferenceKeyQuestType = 0,
  MTMPreferenceKeyQuestIndex,
  MTMPreferenceKeySupportSelect,
  MTMPreferenceKeyPotion,
  MTMPreferenceKeyDailyTowerQuestType,
  MTMPreferenceKeyMitamaQuestType,
  MTMPreferenceKeyBranchBlockStory,
  MTMPreferenceKeyBranchBattleId,
  MTMPreferenceKeyBranchPointId,
  MTMPreferenceKeyBranchCharId,
  MTMPreferenceKeyBranchTitleId,
  MTMPreferenceKeySpeedupMode,
  MTMPreferenceKeySkillCount,
  MTMPreferenceKeyLoopTimer
};

NSString *MTMPreferenceStringKey(MTMPreferenceKey key);
MTMPreferenceKey MTMPreferenceKeyFromString(NSString *key);

@interface MTMPreference : NSObject

+ (instancetype)get;

- (NSDictionary *)getPreferences;
- (NSDictionary *)getPreferencesNoCache;

- (void)savePreference:(NSDictionary *)preference;
- (void)saveFetchedEventData:(NSDictionary *)dct;

- (NSNumber *)getNumberValueForKey:(NSString *)key;
- (NSString *)getStringValueForKey:(NSString *)key;

- (MTMQuestType)getQuestType;
- (NSInteger)getQuestIndex;
- (MTMSupportBehavior)getSupportType;
- (MTMPotionType)getPotionType;
- (MTMEventDailyTowerDifficulty)getDailyTowerDifficulty;
- (MTMTrainingType)getTrainingType;

- (NSArray<NSNumber *> *)getBranchParameters;

- (MTMSkillCountModType)getSkillCountModType;
+ (BOOL)debugMode;

@end
