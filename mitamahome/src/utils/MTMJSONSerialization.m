//
//  MTMJSONSerialization.m
//  libmitamaui
//
//  Created by Chengming Liao on 8/9/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMJSONSerialization.h"

typedef NSArray<NSString *> * Keys;

static Keys MTMResultJSONKeyOrder(void)
{
  return @[
    @"userQuestBattleResultId",
    @"totalWave",
    @"totalTurn",
    @"continueNum",
    @"clearTime",
    @"result",
    @"finishType",
    @"lastAttackCardId",
    @"isFinishLeader",
    @"killNum",
    @"rateHp",
    @"stackedChargeNum",
    @"deadNum",
    @"diskAcceleNum",
    @"diskBlastNum",
    @"diskChargeNum",
    @"comboAcceleNum",
    @"comboBlastNum",
    @"comboChargeNum",
    @"chainNum",
    @"chargeNum",
    @"chargeMax",
    @"skillNum",
    @"connectNum",
    @"magiaNum",
    @"doppelNum",
    @"abnormalNum",
    @"avoidNum",
    @"counterNum",
    @"totalDamageByFire",
    @"totalDamageByWater",
    @"totalDamageByTimber",
    @"totalDamageByLight",
    @"totalDamageByDark",
    @"totalDamageBySkill",
    @"totalDamageByVoid",
    @"totalDamage",
    @"totalDamageFromPoison",
    @"badCharmNum",
    @"badStunNum",
    @"badRestraintNum",
    @"badPoisonNum",
    @"badBurnNum",
    @"badCurseNum",
    @"badFogNum",
    @"badDarknessNum",
    @"badBlindnessNum",
    @"badBanSkillNum",
    @"badBanMagiaNum",
    @"badInvalidHealHpNum",
    @"badInvalidHealMpNum",
    @"waveList",
    @"playerList"
  ];
}

static Keys MTMResultWaveListKeyOrder()
{
  return @[
    @"totalDamage",
    @"mostDamage"
  ];
}

static Keys MTMResultPlayerListKeyOrder()
{
  return @[
    @"cardId",
    @"pos",
    @"hp",
    @"hpRemain",
    @"mpRemain",
    @"attack",
    @"defence",
    @"mpup",
    @"blast",
    @"charge",
    @"rateGainMpAtk",
    @"rateGainMpDef"
  ];
}

static NSException *ValidationException(NSString *reason, NSDictionary *target)
{
  return [NSException exceptionWithName:@"MTMJSONValidationException" reason:reason userInfo:@{
    @"targetDict": target
  }];
}

static NSString *HandlePrimitive(NSString *key, id value)
{
  NSMutableString *result = [NSMutableString new];
  [result appendFormat:@"\"%@\":", key];
  if ([value isKindOfClass:NSString.class]) {
    // handle strings
    [result appendFormat:@"\"%@\"", (NSString *)value];
  } else if (value == [NSNull null]) {
    [result appendString:@"null"];
  } else {
    NSNumber *num = (NSNumber *)value;
    if (!strcmp(num.objCType, @encode(BOOL))
        || num == (void*)kCFBooleanFalse
        || num == (void*)kCFBooleanTrue) {
      // Handle bool
      [result appendFormat:@"%@", num.boolValue ? @"true" : @"false"];
    } else {
      // handle number
      [result appendString:num.stringValue];
    }
  }
  return result;
}

static NSString *DictArraySerialize(NSArray *src, Keys order)
{
  NSMutableString *result = [NSMutableString new];
  for (int i = 0; i < src.count; i++) {
    id d = src[i];
    if (![d isKindOfClass:NSDictionary.class]) {
      @throw ValidationException(@"not a dict array!", @{
        @"order" : order,
        @"arr" : src
                                                       });
    }
    NSDictionary *dict = (NSDictionary *)d;
    if (dict.count != order.count) {
      @throw ValidationException(@"count mismatch!", @{
        @"order" : order,
        @"dict" : dict
                                                       });
    }
    [result appendString:@"{"];
    for (int j = 0; j < order.count; j++) {
      id val = dict[order[j]];
      if (val == nil) {
        @throw ValidationException([NSString stringWithFormat:@"cannot find key %@", order[j]], @{@"dict" : dict});
      }
      [result appendString:HandlePrimitive(order[j], val)];
      if (j != order.count - 1) {
        [result appendString:@","];
      }
    }
    [result appendString:@"}"];
    if (i != src.count - 1) {
      [result appendString:@","];
    }
  }
  return result;
}

static NSString *HandleWaveList(NSArray *arr)
{
  return DictArraySerialize(arr, MTMResultWaveListKeyOrder());
}

static NSString *HandlePlayerList(NSArray *arr)
{
  return DictArraySerialize(arr, MTMResultPlayerListKeyOrder());
}

@implementation MTMJSONSerialization

+ (NSString *)serializeDict:(NSDictionary *)dict
{
  Keys rootKeys = MTMResultJSONKeyOrder();
  // Sanity check
  if (dict.count != rootKeys.count) {
    @throw ValidationException(@"Key count mismatch", dict);
  }
  NSArray *waveArr = dict[@"waveList"];
  if (!waveArr) {
    @throw ValidationException(@"cannot find waveList", dict);
  }

  NSArray *playerArr = dict[@"playerList"];
  if (!playerArr) {
    @throw ValidationException(@"cannot find playerList", dict);
  }
  NSMutableString *result = [NSMutableString new];
  [result appendString:@"{"];
  // Root

  int i = 0;
  for (NSString *k in rootKeys) {
    id value = dict[k];
    if (value == nil) {
      @throw ValidationException([NSString stringWithFormat:@"cannot find key %@", k],
                                 dict);
    }

    if ([value isKindOfClass:NSDictionary.class]) {
      @throw ValidationException(@"unexpected dictionary", dict);
    }

    if (![value isKindOfClass:NSArray.class]) {
      // primitives
      [result appendString:HandlePrimitive(k, value)];
    } else {
      // Handle array
      [result appendFormat:@"\"%@\":[", k];
      // waveList or PlayerList
      if ([k isEqualToString:@"waveList"]) {
        [result appendString:HandleWaveList(waveArr)];
      } else if ([k isEqualToString:@"playerList"]) {
        [result appendString:HandlePlayerList(playerArr)];
      } else {
        @throw ValidationException(@"unknown array", dict);
      }
      [result appendString:@"]"];
    }
    if (i < rootKeys.count - 1) {
      [result appendString:@","];
    }
    i++;
  }

  // End of root
  [result appendString:@"}"];
  return result;
}

@end
