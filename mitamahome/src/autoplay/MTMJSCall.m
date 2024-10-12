#import "MTMJSCall.h"

#define NSStringify(...) @#__VA_ARGS__

static NSString *_CoreLib()
{
  #define MTM_JS_CORE_FUNC
  NSString *lib =
#include "MTMJSCore.js"
  ;
  return lib;
}

static NSString *_BuildInvocation(NSString *func, NSString *call)
{
  NSString *coreLib = _CoreLib();
  NSString *invocation = [NSString stringWithFormat:NSStringify(
    %@
    %@
    try {
      MTMConvertToRect(%@)
    } catch {{}}
  ), coreLib, func, call];
  return invocation;
}

// Operational Calls

NSString *MTMSelectSupport(MTMSupportBehavior behavior)
{
  #define MTM_JS_SUPPORT_SELECT
  NSString *func =
#include "MTMJSCore.js"
  ;
  NSString *call = [NSString stringWithFormat:@"MTMSelectSupport(%@)", @(behavior)];
  return _BuildInvocation(func, call);
}

NSString *MTMTeamSelectPlay()
{
  #define MTM_JS_TEAM_SELECT
  NSString *func =
#include "MTMJSCore.js"
  ;
  NSString *call = @"MTMTeamSelectPlay()";
  return _BuildInvocation(func, call);
}

static NSString *MTMQuestResultCall(NSString *call)
{
  #define MTM_JS_QUEST_RESULTS
  NSString *func =
#include "MTMJSCore.js"
  ;
  return _BuildInvocation(func, call);
}

NSString *MTMFriendFollowDecline()
{
  return MTMQuestResultCall(@"MTMFriendFollowDecline()");
}

NSString *MTMRankupConfirm()
{
  return MTMQuestResultCall(@"MTMRankupConfirm()");
}

static NSString *MTMResotreCall(NSString *call)
{
  #define MTM_JS_AP_RESTORE
  NSString *func =
#include "MTMJSCore.js"
  ;
  return _BuildInvocation(func, call);
}

NSString *MTMRestoreAP(MTMPotionType potion)
{
  NSString *call = [NSString stringWithFormat:@"MTMRestoreAP(%@)", @(potion-1)];
  return MTMResotreCall(call);
}

NSString *MTMRestoreConfirm()
{
  return MTMResotreCall(@"MTMRestoreConfirm()");
}

// Quests
NSString *MTMGenericStoryQuestSelect(NSInteger idx)
{
  #define MTM_JS_GENERIC_STORY
  NSString *func =
#include "MTMJSCore.js"
  ;
  NSString *call = [NSString stringWithFormat:@"MTMGenericStoryQuestSelect(%@)", @(idx)];
  return _BuildInvocation(func, call);
}

NSString *MTMWeeklyQuestSelect(MTMWeeklyQuestType type, NSInteger idx)
{
  #define MTM_JS_WEEKLY_QUEST
  NSString *func =
#include "MTMJSCore.js"
  ;
  NSString *call =
  [NSString stringWithFormat:@"MTMWeeklyQuestSelect(%@, %@)",
    @(type == MTMWeeklyQuestTypeAwakening),
    @(idx)];
  return _BuildInvocation(func, call);
}

NSString *MTMEventDailyTowerQuestSelect(MTMEventDailyTowerDifficulty diff, NSInteger idx)
{
  #define MTM_JS_EVENT_DAILY_TOWER
  NSString *func =
#include "MTMJSCore.js"
  ;
  NSString *call = [NSString stringWithFormat:@"MTMEventDailyTowerQuestSelect(%@, %@)",
    @(diff),
    @(idx)];
  return _BuildInvocation(func, call);
}

static NSString *MTMEventBranchCall(NSString *call)
{
  #define MTM_JS_EVENT_BRANCH
  NSString *func =
#include "MTMJSCore.js"
  ;
  return _BuildInvocation(func, call);
}

NSString *MTMEventBranchQuestSelect(NSInteger battleId, NSInteger pointId, NSInteger charId, NSInteger titleId)
{
  NSString *call = [NSString stringWithFormat:@"MTMEventBranchQuestSelect(%@, %@, %@, %@)",
    @(battleId),
    @(pointId),
    @(charId),
    @(titleId)];
  return MTMEventBranchCall(call);
}
NSString *MTMEventBranchSkipStory()
{
  return MTMEventBranchCall(@"MTMEventBranchSkipStory()");
}

NSString *MTMEventTrainingQuestSelect(MTMTrainingType type, NSInteger idx)
{
  #define MTM_JS_EVENT_TRAINING
  NSString *func =
#include "MTMJSCore.js"
  ;
  NSString *call = [NSString stringWithFormat:@"MTMEventTrainingQuestSelect(%@, %@)",
    @(type),
    @(idx)];
  return _BuildInvocation(func, call);
}

NSString *MTMEventSingleRaidQuestSelect(NSInteger idx)
{
  #define MTM_JS_EVENT_SINGLE_RAID
  NSString *func =
#include "MTMJSCore.js"
  ;
  NSString *call = [NSString stringWithFormat:@"MTMEventSingleRaidQuestSelect(%@)", @(idx)];
  return _BuildInvocation(func, call);
}
