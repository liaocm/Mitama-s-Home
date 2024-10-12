//
//  MTMHookManager.mm
//
//
//  Created by Chengming Liao on 7/25/20.
//

#import "MTMHookManager.h"

#ifdef MITAMA_THEOS_BUILD
#import <substrate.h>
#import <dlfcn.h>
#endif

#import <mach-o/dyld.h>
#import <string>

#import "MTMRecord.h"
#import "MTMPreference.h"
#import "MTMJSONSerialization.h"

@interface MTMHookManager ()
- (NSString *)preprocessJSONString:(NSString *)json;
- (NSDictionary *)changeset;
@end

long (*orig_QbJsonUtility_parse)(long _this, char *json);
long (*orig_QbJsonUtilityModel_stringfyResult)(std::string& buf);

long hooked_QbJsonUtility_parse(long _this, char *json)
{
  NSString *jsonString = [NSString stringWithUTF8String:json];
  NSString *processedJsonString = [[MTMHookManager get] preprocessJSONString:jsonString];
  if ([MTMPreference debugMode]) {
    // in debug mode, we log both results and use original
    [[MTMRecord get] record:@"[debug][hook] applied changeset: %@", [[MTMHookManager get] changeset]];
    return orig_QbJsonUtility_parse(_this, json);
  }
  char *processedJsonChar = (char *)[processedJsonString UTF8String];
  return orig_QbJsonUtility_parse(_this, processedJsonChar);
}

long hooked_QbJsonUtilityModel_stringfyResult(std::string& buf)
{

  long orig = orig_QbJsonUtilityModel_stringfyResult(buf);
  if (!buf.c_str()) {
    [[MTMRecord get] record:@"[error][hook] null buffer for stringify."];
    return orig;
  }
  NSString *bufferJson = [[NSString alloc] initWithUTF8String:buf.c_str()];
  [[MTMRecord get] record:@"[info][hook] orig stringify result: \n%@", bufferJson];

  // Modify buffer and repack

  NSData *data = [bufferJson dataUsingEncoding:NSUTF8StringEncoding];
  NSError *err = nil;
  NSMutableDictionary *jsonDict =
  [NSJSONSerialization
   JSONObjectWithData:data
   options:NSJSONReadingMutableContainers
   error:&err];
  if (!jsonDict) {
    [[MTMRecord get] record:@"[error][hook] error getting json from stringify."];
    return orig;
  }

  // Now, revert changeset!
  [[MTMRecord get] record:@"[info][hook] reverting changeset ========>"];
  NSDictionary<NSString *, NSDictionary *>*changeset = [[MTMHookManager get] changeset];

  MTMSkillCountModType skillCountMod = [[MTMPreference get] getSkillCountModType];
  if (skillCountMod != MTMSkillCountModTypeNone && changeset[@"skill"].count > 0) {
    NSInteger newSkillNum = 0;
    NSString *skillModStr;
    if (skillCountMod == MTMSkillCountModTypeAlwaysZero) {
      newSkillNum = 0;
      skillModStr = @"AlwaysZero";
    } else if (skillCountMod == MTMSkillCountModTypeDivideByFive) {
      newSkillNum = ((NSNumber *)jsonDict[@"skillNum"]).integerValue / 5;
      skillModStr = @"DivideFive";
    } else if (skillCountMod == MTMSkillCountModTypeDivideByTen) {
      newSkillNum = ((NSNumber *)jsonDict[@"skillNum"]).integerValue / 10;
      skillModStr = @"DivideTen";
    }
    [[MTMRecord get] record:@"ModType: %@, skillNum: %@ -> %@", skillModStr, jsonDict[@"skillNum"], @(newSkillNum)];
    jsonDict[@"skillNum"] = @(newSkillNum);
  }

  if (changeset[@"connectNum"] != nil) {
    NSInteger prevConnectNum = ((NSNumber*)jsonDict[@"connectNum"]).integerValue;
    jsonDict[@"connectNum"] = @1;
    [[MTMRecord get] record:@"connectNum: %@ -> %@", @(prevConnectNum), @1];
  }

  NSArray *playerLst = jsonDict[@"playerList"];
  NSDictionary *girlChangeSet = changeset[@"girl"];
  for (NSMutableDictionary *player in playerLst) {
    NSNumber *pos = player[@"pos"];
    if (girlChangeSet[pos] != nil) {
      // revert
      [[MTMRecord get] record:@"Girl pos %@ ", pos];
      NSDictionary *posChangeSet = girlChangeSet[pos];
      if (posChangeSet[@"attack"]) {
        [[MTMRecord get] record:@"attack: %@ -> %@", player[@"attack"], posChangeSet[@"attack"][@"prev"]];
        player[@"attack"] = posChangeSet[@"attack"][@"prev"];
      }
      if (posChangeSet[@"defence"]) {
        [[MTMRecord get] record:@"defence: %@ -> %@", player[@"defence"], posChangeSet[@"defence"][@"prev"]];
        player[@"defence"] = posChangeSet[@"defence"][@"prev"];
      }
      // We don't need to restore these

      // if (posChangeSet[@"mpStart"]) {
      //   [[MTMRecord get] record:@"mpStart: %@ -> %@", player[@"mpStart"], posChangeSet[@"mpStart"][@"prev"]];
      //   player[@"mpStart"] = posChangeSet[@"mpStart"][@"prev"];
      // }
      // if (posChangeSet[@"maxMp"]) {
      //   [[MTMRecord get] record:@"maxMp: %@ -> %@", player[@"maxMp"], posChangeSet[@"maxMp"][@"prev"]];
      //   player[@"maxMp"] = posChangeSet[@"maxMp"][@"prev"];
      // }
      if (posChangeSet[@"rateGainMpAtk"]) {
        [[MTMRecord get] record:@"rateGainMpAtk: %@ -> %@", player[@"rateGainMpAtk"], posChangeSet[@"rateGainMpAtk"][@"prev"]];
        player[@"rateGainMpAtk"] = posChangeSet[@"rateGainMpAtk"][@"prev"];
      }
      if (posChangeSet[@"rateGainMpDef"]) {
        [[MTMRecord get] record:@"rateGainMpDef: %@ -> %@", player[@"rateGainMpDef"], posChangeSet[@"rateGainMpDef"][@"prev"]];
        player[@"rateGainMpDef"] = posChangeSet[@"rateGainMpDef"][@"prev"];
      }
    }
  }

  [[MTMRecord get] record:@"<============="];
  // Pack into JSON string
  err = nil;
  if ([MTMPreference debugMode]) {
    // in debug mode, print out some responses
    NSData *hackedData =
    [NSJSONSerialization
      dataWithJSONObject:jsonDict
      options:0
      error:&err];
    NSString* debugJson = [[NSString alloc] initWithData:hackedData encoding:NSUTF8StringEncoding];
    [[MTMRecord get] record:@"[debug][hook] debug result w/ native serialization:\n%@\n=============", debugJson];
    @try {
      debugJson = [MTMJSONSerialization serializeDict:jsonDict];
      [[MTMRecord get] record:@"[debug][hook] debug result w/ own serialization:\n%@", debugJson];
    }
    @catch (NSException *anException) {
      [[MTMRecord get] record:@"[debug][hook] serialization failed:%@\nuserinfo:%@", anException, anException.userInfo];
    }
    // use original result
    return orig;
  }

  // Custom serialization
  NSString *newJson = [MTMJSONSerialization serializeDict:jsonDict];
  // example:
  buf.clear();
  buf.append([newJson cStringUsingEncoding:[NSString defaultCStringEncoding]]);
  bufferJson = [[NSString alloc] initWithUTF8String:buf.c_str()];
  [[MTMRecord get] record:@"[info][hook] new stringify result:\n%@", bufferJson];

  // orig is the return value unused.
  return orig;
}

@implementation MTMHookManager
{
  BOOL _parserAttempted;
  BOOL _parserHooked;
  BOOL _stringifyAttempted;
  BOOL _stringifyHooked;

  NSDictionary *_discOverride;
  NSDictionary *_miscOverride;

  NSMutableDictionary *_changeset;
}

+ (instancetype)get
{
  static MTMHookManager *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    shared = [[MTMHookManager alloc] init];
  });
  return shared;
}

- (instancetype)init
{
  if (self = [super init]) {
    _parserAttempted = NO;
    _parserHooked = NO;
    _stringifyAttempted = NO;
    _stringifyHooked = NO;
  }
  return self;
}

// Model

- (void)setDiscOverrides:(NSDictionary *)discOverrides
{
  _discOverride = discOverrides;
}

- (void)setMiscOverrides:(NSDictionary *)miscOverrides
{
  _miscOverride = miscOverrides;
}

- (NSDictionary *)changeset
{
  return _changeset;
}

// Process JSON

- (NSString *)preprocessJSONString:(NSString *)json
{
  NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
  NSError *err = nil;
  NSMutableDictionary *jsonDict =
  [NSJSONSerialization
   JSONObjectWithData:data
   options:NSJSONReadingMutableContainers
   error:&err];
  if (!jsonDict) {
    [[MTMRecord get] record:@"[error][hook] error processing json parse:\n%@", json];
    return json;
  }

  NSMutableDictionary *changeset = [NSMutableDictionary new];

  // Hook for Root Metadata
  NSString *isHalfSkill = _miscOverride[@"misc"][@"isHalfSkill"];
  if ([isHalfSkill isEqualToString:@"false"]) {
    if (((NSNumber *)jsonDict[@"isHalfSkill"]).boolValue != NO) {
      changeset[@"isHalfSkill"] = @{
        @"prev" : [jsonDict[@"isHalfSkill"] copy],
        @"new" : @(NO)
      };
      jsonDict[@"isHalfSkill"] = [NSNumber numberWithBool:NO];
    }
  }

  NSString *tripleSpeed = _miscOverride[@"misc"][@"tripleSpeed"];
  if ([tripleSpeed isEqualToString:@"true"]) {
    if (((NSNumber *)jsonDict[@"canTripleSpeed"]).boolValue != YES) {
      changeset[@"canTripleSpeed"] = @{
        @"prev" : [jsonDict[@"canTripleSpeed"] copy],
        @"new" : @(YES)
      };
      jsonDict[@"canTripleSpeed"] = [NSNumber numberWithBool:YES];
    }
  }

  NSString *connectNum = _miscOverride[@"misc"][@"connectNum"];
  if ([connectNum isEqualToString:@"1"]) {
    changeset[@"connectNum"] = @{
      @"prev" : @"[default]",
      @"new" : @(1)
    };
  }

  // Hook for Scenarios
  NSString *isAutoForced = _miscOverride[@"misc"][@"auto"];
  if ([isAutoForced isEqualToString:@"true"]) {
    NSMutableDictionary *scenario = jsonDict[@"scenario"];
    if (((NSNumber *)scenario[@"auto"]).boolValue != YES) {
      changeset[@"auto"] = @{
        @"prev" : [scenario[@"auto"] copy],
        @"new" : @(YES)
      };
      scenario[@"auto"] = [NSNumber numberWithBool:YES];
    }
  }

  // Hook for Girls and Discs
  changeset[@"girl"] = [NSMutableDictionary new];

  NSMutableArray *playerLst = jsonDict[@"playerList"];
  NSMutableArray<NSNumber *> *skillNumList = [NSMutableArray new];
  for (NSMutableDictionary *player in playerLst) {
    NSNumber *pos = [player objectForKey:@"pos"];

    // Get list of skills
    NSArray *skillList = [player objectForKey:@"memoriaList"];
    for (id item in skillList) {
      if ([item isKindOfClass:NSNumber.class]) {
        [skillNumList addObject:(NSNumber *)item];
      }
    }

    // Girl stats
    NSMutableDictionary *currPosChangeset = [NSMutableDictionary new];
    NSArray<NSDictionary<NSString *, NSString *> *> *girlOverride
    = _miscOverride[@"girl"];

    NSInteger posIdx = pos.integerValue - 1;
    if (posIdx >= 0 && posIdx < girlOverride.count) {
      NSDictionary<NSString *, NSString *> *girlDict = girlOverride[posIdx];
      // Attack
      if (![girlDict[@"attack"] isEqualToString:@"1.0x"]) {
        float mul = girlDict[@"attack"].floatValue;
        NSInteger curr = ((NSNumber *)player[@"attack"]).integerValue;
        NSInteger newVal = (NSInteger)((float)curr * mul);
        currPosChangeset[@"attack"] = @{
          @"prev" : @(curr),
          @"new" : @(newVal)
        };
        player[@"attack"] = @(newVal);
      }
      // Defence
      if (![girlDict[@"defence"] isEqualToString:@"1.0x"]) {
        float mul = girlDict[@"defence"].floatValue;
        NSInteger curr = ((NSNumber *)player[@"defence"]).integerValue;
        NSInteger newVal = (NSInteger)((float)curr * mul);
        currPosChangeset[@"defence"] = @{
          @"prev" : @(curr),
          @"new" : @(newVal)
        };
        player[@"defence"] = @(newVal);
      }
      // mpStart
      if (![girlDict[@"mpStart"] isEqualToString:@"0"]) {
        NSInteger override = girlDict[@"mpStart"].integerValue;
        NSInteger curr = ((NSNumber *)player[@"mpStart"]).integerValue;
        currPosChangeset[@"mpStart"] = @{
          @"prev" : @(curr),
          @"new" : @(override)
        };
        player[@"mpStart"] = @(override);
      }
      // maxMp
      if (![girlDict[@"maxMp"] isEqualToString:@"0"]) {
        NSInteger override = girlDict[@"maxMp"].integerValue;
        NSInteger curr = ((NSNumber *)player[@"maxMp"]).integerValue;
        currPosChangeset[@"maxMp"] = @{
          @"prev" : @(curr),
          @"new" : @(override)
        };
        player[@"maxMp"] = @(override);
      }
      // rateGainMpAtk
      if (![girlDict[@"rateGainMpAtk"] isEqualToString:@"1.0x"]) {
        float mul = girlDict[@"rateGainMpAtk"].floatValue;
        NSInteger curr = ((NSNumber *)player[@"rateGainMpAtk"]).integerValue;
        NSInteger newVal = (NSInteger)((float)curr * mul);
        currPosChangeset[@"rateGainMpAtk"] = @{
          @"prev" : @(curr),
          @"new" : @(newVal)
        };
        player[@"rateGainMpAtk"] = @(newVal);
      }
      // rateGainMpDef
      if (![girlDict[@"rateGainMpDef"] isEqualToString:@"1.0x"]) {
        float mul = girlDict[@"rateGainMpDef"].floatValue;
        NSInteger curr = ((NSNumber *)player[@"rateGainMpDef"]).integerValue;
        NSInteger newVal = (NSInteger)((float)curr * mul);
        currPosChangeset[@"rateGainMpDef"] = @{
          @"prev" : @(curr),
          @"new" : @(newVal)
        };
        player[@"rateGainMpDef"] = @(newVal);
      }
    }

    // Discs  ---  TODO add this to changeset.
    NSArray<NSString *> *overrides = [_discOverride objectForKey:pos];
    if (overrides) {
      for (int i = 1; i <= 5; ++i)
      {
        NSString *key = [NSString stringWithFormat:@"discType%@", @(i)];
        if ([player objectForKey:key]) {
          player[key] = overrides[i-1];
        }
      }
    }

    if (currPosChangeset.count > 0) {
      changeset[@"girl"][pos] = currPosChangeset;
    }
  }

  // Hook for Skills -- skillNumList
  NSString *skillOverride = _miscOverride[@"misc"][@"skillCost"];
  if (skillOverride.integerValue >= 0) {
    NSInteger newVal = skillOverride.integerValue;
    NSInteger cnt = 0;
    NSMutableArray *skills = jsonDict[@"memoriaList"];
    for (NSMutableDictionary *skill in skills) {
      if ([skillNumList indexOfObject:skill[@"memoriaId"]] != NSNotFound &&
        [skill[@"type"] isEqualToString:@"SKILL"]) {
        skill[@"cost"] = @(newVal);
        cnt++;
      }
    }
    if (cnt > 0) {
      changeset[@"skill"] = @{
        @"count": @(cnt)
      };
    }
  }

  // Hook for Enemy -- TODO add to changeset
  NSMutableArray *waveLst = jsonDict[@"waveList"];
  NSString *enemyAtkMul = _miscOverride[@"enemy"][@"attack"];
  NSString *enemyDefMul = _miscOverride[@"enemy"][@"defence"];
  if (![enemyAtkMul isEqualToString:@"1.0x"] || ![enemyDefMul isEqualToString:@"1.0x"]) {
    // override stuffs!
    for (NSMutableDictionary *wave in waveLst) {
      NSMutableArray *enemyLst = wave[@"enemyList"];
      for (NSMutableDictionary *enemy in enemyLst) {
        if (![enemyAtkMul isEqualToString:@"1.0x"]) {
          float mul = enemyAtkMul.floatValue;
          NSInteger curr = ((NSNumber *)enemy[@"attack"]).integerValue;
          NSInteger newVal = (NSInteger)((float)curr * mul);
          enemy[@"attack"] = @(newVal);
        }
        if (![enemyDefMul isEqualToString:@"1.0x"]) {
          float mul = enemyDefMul.floatValue;
          NSInteger curr = ((NSNumber *)enemy[@"defence"]).integerValue;
          NSInteger newVal = (NSInteger)((float)curr * mul);
          enemy[@"defence"] = @(newVal);
        }
      }
    }
  }

  _changeset = changeset;

  // Pack into JSON string
  err = nil;
  NSData *hackedData =
  [NSJSONSerialization
    dataWithJSONObject:jsonDict
    options:0
    error:&err];
  NSString* newJson = [[NSString alloc] initWithData:hackedData encoding:NSUTF8StringEncoding];
  if (!newJson) {
    [[MTMRecord get] record:@"[error][hook] error processing json repack"];
    return json;
  }
  [[MTMRecord get] record:@"[info][hook] committed changeset:\n%@", changeset];
  return newJson;
}

// Hooking

static bool instcmp(uint8_t* ptr1, uint8_t* ptr2, unsigned int len) {
  for (int i=0; i<len; i++) {
    if (ptr1[i] != ptr2[i]) return false;
  }
  return true;
}

- (void)hookParser
{
  if (_parserAttempted) {
    return;
  }
  _parserAttempted = YES;
  [[MTMRecord get] record:@"[info][hook] starting to hook parser."];

  uint8_t qbJsonUtilityParse_inst[] = {
    0xf4, 0x4f, 0xbe, 0xa9,
    0xfd, 0x7b, 0x01, 0xa9,
    0xfd, 0x43, 0x00, 0x91,
    0xf4, 0x03, 0x01, 0xaa,
    0xf3, 0x03, 0x00, 0xaa,
    0x00, 0x04, 0x40, 0xf9,
    0x60, 0x00, 0x00, 0xb4,
    0x43, 0x72, 0x18, 0x94,
    0x7f, 0x06, 0x00, 0xf9,
    0xe0, 0x03, 0x14, 0xaa,
    0x55, 0x72, 0x18, 0x94,
    0x60, 0x06, 0x00, 0xf9,
    0x80, 0x00, 0x00, 0xb4,
    0xfd, 0x7b, 0x41, 0xa9
  };

  unsigned long QbJsonUtilityParse_addr;
  unsigned long aslr = _dyld_get_image_vmaddr_slide(0);
  int *ptr = (int*)(aslr + 0x100000000);
  int *ptr_top = (int*)((char*)ptr + 0x300000);
  BOOL found = NO;
  _parserHooked = NO;
  while (ptr < ptr_top) {
    if (!found && instcmp((uint8_t *)ptr, qbJsonUtilityParse_inst, 56)) {
      QbJsonUtilityParse_addr = (unsigned long)ptr;
      [[MTMRecord get] record:@"[info][hook] found QbJsonUtility_parse at %lx", QbJsonUtilityParse_addr];
      long offset = QbJsonUtilityParse_addr - aslr;
      [[MTMRecord get] record:@"[info][hook] QbJsonUtility_parse offset %lx", offset];
      found = YES;
    }
    if (found) {
      break;
    }
    ptr++;
  }
  if (found) {
    // Hooking the parser
#ifdef MITAMA_THEOS_BUILD
    MSHookFunction((void *)QbJsonUtilityParse_addr, (void *)hooked_QbJsonUtility_parse, (void **)&orig_QbJsonUtility_parse);
#endif
    _parserHooked = YES;
    [[MTMRecord get] record:@"[info][hook] QbJsonUtility_parse hooked"];
  }
}

- (void)hookStringify
{
  if (_stringifyAttempted) {
    return;
  }
  _stringifyAttempted = YES;
  [[MTMRecord get] record:@"[info][hook] starting to hook stringify."];

  uint8_t QbJsonUtilityModelStringfyResult_inst[] = {
    0xff, 0xc3, 0x04, 0xd1,
    0xfc, 0x6f, 0x0d, 0xa9,
    0xfa, 0x67, 0x0e, 0xa9,
    0xf8, 0x5f, 0x0f, 0xa9,
    0xf6, 0x57, 0x10, 0xa9,
    0xf4, 0x4f, 0x11, 0xa9,
    0xfd, 0x7b, 0x12, 0xa9,
    0xfd, 0x83, 0x04, 0x91,
    0xe0, 0x07, 0x00, 0xf9,
    0xb8, 0x7c, 0xfd, 0x97,
    0x08, 0x00, 0x40, 0xf9,
    0x08, 0x05, 0x40, 0xf9,
    0x00, 0x01, 0x3f, 0xd6,
    0xf3, 0x03, 0x00, 0xaa
  };
  unsigned long QbJsonUtilityModelStringfyResult_addr;
  unsigned long aslr = _dyld_get_image_vmaddr_slide(0);
  int *ptr = (int*)(aslr + 0x100000000);
  int *ptr_top = (int*)((char*)ptr + 0x300000);
  BOOL found = NO;
  _stringifyHooked = NO;
  while (ptr < ptr_top) {
    if (!found && instcmp((uint8_t *)ptr, QbJsonUtilityModelStringfyResult_inst, 56)) {
      QbJsonUtilityModelStringfyResult_addr = (unsigned long)ptr;
      [[MTMRecord get] record:@"[info][hook] found QbJsonUtilityModelStringfyResult at %lx", QbJsonUtilityModelStringfyResult_addr];
      long offset = QbJsonUtilityModelStringfyResult_addr - aslr;
      [[MTMRecord get] record:@"[info][hook] QbJsonUtilityModelStringfyResult offset %lx", offset];
      found = YES;
    }
    if (found) {
      break;
    }
    ptr++;
  }
  if (found) {
    // Hooking the stringifier
#ifdef MITAMA_THEOS_BUILD
    MSHookFunction((void *)QbJsonUtilityModelStringfyResult_addr, (void *)hooked_QbJsonUtilityModel_stringfyResult, (void **)&orig_QbJsonUtilityModel_stringfyResult);
#endif
    _stringifyHooked = YES;
    [[MTMRecord get] record:@"[info][hook] QbJsonUtilityModelStringfyResult hooked"];
  }
}

@end
