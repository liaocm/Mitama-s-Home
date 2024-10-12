#import "MTMPreference.h"

#import "MTMTelepathy.h"
#import "MTMRecord.h"

static NSString *kPrefFilePath = @"/var/mobile/Library/Preferences/com.liaocm.mitamapref.plist";

@implementation MTMPreference
{
  NSDictionary *_dict;
}

+ (instancetype)get
{
  static MTMPreference *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    shared = [[MTMPreference alloc] init];
    [shared getPreferencesNoCache];
  });
  return shared;
}

- (NSDictionary *)getPreferencesNoCache
{
  _dict = [NSDictionary dictionaryWithContentsOfFile:kPrefFilePath];
  return _dict;
}

- (NSDictionary *)getPreferences
{
  if (!_dict) {
    return [self getPreferencesNoCache];
  }
  return _dict;
}

- (void)savePreference:(NSDictionary *)preference
{
  [[MTMRecord get] record:@"[preference] Saving preference:\n%@", preference];
  _dict = preference;
#ifdef MITAMA_THEOS_BUILD
  [[MTMTelepathy get] savePreference:preference];
#endif
}

- (void)saveFetchedEventData:(NSDictionary *)dct
{
  NSNumber *battleId = [dct objectForKey:@"questBattleId"];
  NSNumber *pointId = [dct objectForKey:@"pointId"];
  NSNumber *charId = [dct objectForKey:@"charId"];
  NSNumber *titleId = [dct objectForKey:@"titleId"];
  if (battleId && pointId && charId && titleId) {
    // Store in settings
    NSMutableDictionary *settings = [[self getPreferencesNoCache] mutableCopy];
    [settings setObject:battleId forKey:@"branchbattleid"];
    [settings setObject:pointId forKey:@"branchpointid"];
    [settings setObject:charId forKey:@"branchcharid"];
    [settings setObject:titleId forKey:@"branchtitleid"];
    // Update preference and the state machine.
    [self savePreference:settings];
  }
}

- (NSNumber *)getNumberValueForKey:(NSString *)key
{
  return (NSNumber *)[self _getValueTyped:NSNumber.class forKey:key];
}

- (NSString *)getStringValueForKey:(NSString *)key
{
  return (NSString *)[self _getValueTyped:NSString.class forKey:key];
}

// Typed output

- (MTMQuestType)getQuestType
{
  return (MTMQuestType)[self getNumberValueForKey:@"quest"].intValue;
}

- (NSInteger)getQuestIndex
{
  return [self getNumberValueForKey:@"questindex"].intValue;
}

- (MTMSupportBehavior)getSupportType
{
  return (MTMSupportBehavior)[self getNumberValueForKey:@"support"].intValue;
}

- (MTMPotionType)getPotionType
{
  return (MTMPotionType)[self getNumberValueForKey:@"potion"].intValue;
}

- (MTMEventDailyTowerDifficulty)getDailyTowerDifficulty
{
  return (MTMEventDailyTowerDifficulty)[self getNumberValueForKey:@"dailytowerquesttype"].intValue;
}

- (MTMTrainingType)getTrainingType
{
  return (MTMTrainingType)[self getNumberValueForKey:@"mitamaquesttype"].intValue;
}

- (NSArray<NSNumber *> *)getBranchParameters
{
  NSNumber *battleId = [self getNumberValueForKey:@"branchbattleid"];
  NSNumber *pointId = [self getNumberValueForKey:@"branchpointid"];
  NSNumber *charId = [self getNumberValueForKey:@"branchcharid"];
  NSNumber *titleId = [self getNumberValueForKey:@"branchtitleid"];
  if (battleId.intValue == 0 || pointId.intValue == 0 || charId.intValue == 0 || titleId.intValue == 0) {
    return nil;
  }
  return @[battleId, pointId, charId, titleId];
}

- (MTMSkillCountModType)getSkillCountModType
{
  return (MTMSkillCountModType)[self getNumberValueForKey:@"skillcountmod"].intValue;
}

+ (BOOL)debugMode
{
  return [[MTMPreference get] getNumberValueForKey:@"hookdebug"].boolValue;
}

// helpers

- (id)_getValueTyped:(Class)type forKey:(NSString *)key
{
  NSDictionary *pref = [self getPreferences];
  id val = [pref objectForKey:key];
  if (!val) {
    return nil;
  }
  if (![val isKindOfClass:type]) {
    return nil;
  }
  return val;
}

@end

NSString *MTMPreferenceStringKey(MTMPreferenceKey key)
{
  switch (key) {
    case MTMPreferenceKeyQuestType:
      return @"quest";
    case MTMPreferenceKeyQuestIndex:
      return @"questindex";
    case MTMPreferenceKeySupportSelect:
      return @"support";
    case MTMPreferenceKeyPotion:
      return @"potion";
    case MTMPreferenceKeyDailyTowerQuestType:
      return @"dailytowerquesttype";
    case MTMPreferenceKeyMitamaQuestType:
      return @"mitamaquesttype";
    case MTMPreferenceKeyBranchBlockStory:
      return @"branchblockstory";
    case MTMPreferenceKeyBranchBattleId:
      return @"branchbattleid";
    case MTMPreferenceKeyBranchPointId:
      return @"branchpointid";
    case MTMPreferenceKeyBranchCharId:
      return @"branchcharid";
    case MTMPreferenceKeyBranchTitleId:
      return @"branchtitleid";
    case MTMPreferenceKeySpeedupMode:
      return @"speedup";
    case MTMPreferenceKeySkillCount:
      return @"skillcountmod";
    case MTMPreferenceKeyLoopTimer:
      return @"timer";
  }
}

MTMPreferenceKey MTMPreferenceKeyFromString(NSString *key)
{
  if ([key isEqual:@"quest"]) {
    return MTMPreferenceKeyQuestType;
  }
  else if ([key isEqual:@"questindex"]) {
    return MTMPreferenceKeyQuestIndex;
  }
  else if ([key isEqual:@"support"]) {
    return MTMPreferenceKeySupportSelect;
  }
  else if ([key isEqual:@"potion"]) {
    return MTMPreferenceKeyPotion;
  }
  else if ([key isEqual:@"dailytowerquesttype"]) {
    return MTMPreferenceKeyDailyTowerQuestType;
  }
  else if ([key isEqual:@"mitamaquesttype"]) {
    return MTMPreferenceKeyMitamaQuestType;
  }
  else if ([key isEqual:@"branchblockstory"]) {
    return MTMPreferenceKeyBranchBlockStory;
  }
  else if ([key isEqual:@"branchbattleid"]) {
    return MTMPreferenceKeyBranchBattleId;
  }
  else if ([key isEqual:@"branchpointid"]) {
    return MTMPreferenceKeyBranchPointId;
  }
  else if ([key isEqual:@"branchcharid"]) {
    return MTMPreferenceKeyBranchCharId;
  }
  else if ([key isEqual:@"branchtitleid"]) {
    return MTMPreferenceKeyBranchTitleId;
  }
  else if ([key isEqual:@"speedup"]) {
    return MTMPreferenceKeySpeedupMode;
  }
  else if ([key isEqual:@"skillcountmod"]) {
    return MTMPreferenceKeySkillCount;
  }
  else if ([key isEqual:@"timer"]) {
    return MTMPreferenceKeyLoopTimer;
  }
  return MTMPreferenceKeyQuestType;
}
