#ifdef MTM_JS_IGNORE_ME
/**
  Mitama Javascript-Objc Interop Library
  Usage:
  // predefined somewhere: #define NSStringify(...) @#__VA_ARGS__
  #define TAG_TO_INCLUDE_ONCE
  NSString *jsFuncs =
#include 'MTMJSCore.js'
  ;
*/
#endif

#ifdef MTM_JS_CORE_FUNC
#undef MTM_JS_CORE_FUNC
NSStringify(
  function MTMConvertToRect(domRect) {
    if (domRect == null) {
      return {'x':0, 'y':0, 'w':0, 'h': 0};
    }
    return {'x':domRect.x, 'y':domRect.y, 'w':domRect.width, 'h':domRect.height};
  }

  function MTMScrollTransformStyle(offset) {
    offset = parseInt(offset);
    return 'transform: translateY(' + offset.toString() + 'px) translateZ(0px);';
  }
)
#endif

#ifdef MTM_JS_SUPPORT_SELECT
#undef MTM_JS_SUPPORT_SELECT
NSStringify(
  function MTMSelectSupport(behavior) {
    const useBonus = behavior == 1 || behavior == 2;
    const isNPC = behavior == 3;
    let targetSupport = null;
    const scroll = document.getElementsByClassName('friendWrapInner sortRank')[0];
    if (useBonus) {
      const allSupWithBonus = document.getElementsByClassName('bonusIcon');
      if (allSupWithBonus.length == 0) {
        if (behavior == 1) {return null;}
        targetSupport = scroll.getElementsByClassName('wrap')[0];
      } else {
        targetSupport = allSupWithBonus[0];
      }
    } else if (isNPC) {
      targetSupport = scroll.getElementsByClassName('wrap npcChara')[0];
    } else {
      targetSupport = scroll.getElementsByClassName('wrap')[0];
    }
    let type = 'ALL';
    let allTypes = ['ALL', 'FIRE', 'WATER', 'TIMBER', 'LIGHT', 'DARK'];
    const lst = targetSupport.classList;
    for (i = 0; i < allTypes.length; i++) {
      if (lst.contains(allTypes[i])) {
        type = allTypes[i];
      }
    }
    document.getElementById('friendWrap').className = type.toLowerCase();
    if (!isNPC) {
      const ref = scroll.getElementsByClassName('wrap ' + type)[0];
      const yDiff = ref.getBoundingClientRect().y - targetSupport.getBoundingClientRect().y;
      scroll.style = MTMScrollTransformStyle(yDiff);
    }
    return targetSupport.getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_TEAM_SELECT
#undef MTM_JS_TEAM_SELECT
NSStringify(
  function MTMTeamSelectPlay() {
    return document.getElementById('nextPageBtn').getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_QUEST_RESULTS
#undef MTM_JS_QUEST_RESULTS
NSStringify(
  function MTMFriendFollowDecline() {
    const noFollowBtn = document.getElementById('followNoBtn');
    if (noFollowBtn == null) {return null;}
    return noFollowBtn.getBoundingClientRect();
  }
  function MTMRankupConfirm() {
    const rankupBtn = document.getElementsByClassName('rankPopClose');
    if (rankupBtn.length == 0) {return null;}
    return rankupBtn[0].getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_AP_RESTORE
#undef MTM_JS_AP_RESTORE
NSStringify(
  function MTMRestoreAP(idx) {
    const restoreButtons = document.getElementsByClassName('cureBtn');
    return restoreButtons[idx].getBoundingClientRect();
  }
  function MTMRestoreConfirm() {
    return document.getElementsByClassName('useDecide')[0].getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_EVENT_DAILY_TOWER
#undef MTM_JS_EVENT_DAILY_TOWER
NSStringify(
  function MTMEventDailyTowerQuestSelect(diff, idx) {
    const diffLst = ['normalQuest', 'challengeQuest', 'exchallengeQuest', 'endlesschallengeQuest'];
    const diffStr = diffLst[diff];
    let wrap = document.getElementById('questWrap');
    wrap.classList.remove('normal');
    wrap.classList.remove('challenge');
    wrap.classList.remove('exchallenge');
    const tag = diffStr.slice(0, -5);
    wrap.classList.add(tag);
    let scroll = document.getElementsByClassName('scrollInner first');
    if (scroll == null || scroll.length == 0) {
      return null;
    }
    scroll = scroll[0];
    scroll.style = 'transform: translateY(0px) translateZ(0px);';
    const quests = document.getElementById(diffStr).children;
    const firstChild = quests[0];
    const firstRect = firstChild.getBoundingClientRect();
    const targetChild = quests[idx];
    const targetRect = targetChild.getBoundingClientRect();
    const yDiff = firstRect.y - targetRect.y;
    scroll.style = MTMScrollTransformStyle(yDiff);
    return targetChild.getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_WEEKLY_QUEST
#undef MTM_JS_WEEKLY_QUEST
NSStringify(
  function MTMWeeklyQuestSelect(isAwakening, idx) {
    const openTab = isAwakening ? 'materialWrap' : 'composeWrap';
    const closeTab = !isAwakening ? 'materialWrap' : 'composeWrap';
    const openEl = document.getElementById(openTab);
    const closeEl = document.getElementById(closeTab);
    if (!openEl.classList.contains('open')) {
      openEl.classList.add('open');
    }
    closeEl.classList.remove('open');
    const wrapperId = isAwakening ? 'materialQuestWrap' : 'composeQuestWrap';
    const wrap = document.getElementById(wrapperId);
    const scroll = document.getElementsByClassName('scrollInner')[0];
    const ref = wrap.children[0].getBoundingClientRect();
    const target = wrap.children[idx].getBoundingClientRect();
    const yDiff = ref.y - target.y;
    scroll.style = MTMScrollTransformStyle(yDiff);
    return wrap.children[idx].getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_GENERIC_STORY
#undef MTM_JS_GENERIC_STORY
NSStringify(
  function MTMGenericStoryQuestSelect(idx) {
    const scroll = document.getElementById('questLinkList');
    const ref = scroll.children[0];
    const target = scroll.children[idx];
    const yDiff = ref.getBoundingClientRect().y - target.getBoundingClientRect().y;
    scroll.style = 'position: relative; ' + MTMScrollTransformStyle(yDiff);
    return target.getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_EVENT_BRANCH
#undef MTM_JS_EVENT_BRANCH
NSStringify(
  function MTMEventBranchQuestSelect(battleId, pointId, charId, titleId) {
    let questDetail = document.getElementById('questDetail');
    if (questDetail == null) {return;}
    if (questDetail.children.length > 0) {
      questDetail.classList.remove('open');
      questDetail.children[0].remove();
    }
    nativeCallback({
      'questBattleId':battleId,
      'pointId':pointId,
      'status':'NEW',
      'charId':charId,
      'titleId':titleId,
      'missionList':[false,false,false]
    });
    const btn = document.getElementById('mainBtn');
    return btn != null ? btn.getBoundingClientRect() : null;
  }
  function MTMEventBranchSkipStory() {
    nativeCallback({'alternativeIdList':[]});
  }
)
#endif

#ifdef MTM_JS_EVENT_TRAINING
#undef MTM_JS_EVENT_TRAINING
NSStringify(
  function MTMEventTrainingQuestSelect(type, idx) {
    let questLstId = null;
    const questIDList = ['storyQuest', 'composeQuest', 'episodeQuest', 'extraQuest'];
    if (type > 3 || type < 0) {return null;}
    for (i = 0; i < 4; i++) {
      document.getElementById(questIDList[i]).classList.remove('show');
    }
    const scroll = document.getElementsByClassName('scrollInner first')[0];
    scroll.style = 'transform: translateY(0px) translateZ(0px);';
    const questList = document.getElementById(questIDList[type]);
    questList.classList.add('show');
    const children = questList.children;
    if (idx >= questList.children.length) {return null;}
    const firstChild = questList.children[0];
    const firstRect = firstChild.getBoundingClientRect();
    const targetChild = questList.children[idx];
    const targetRect = targetChild.getBoundingClientRect();
    const yDiff = firstRect.y - targetRect.y;
    scroll.style = MTMScrollTransformStyle(yDiff);
    return targetChild.getBoundingClientRect();
  }
)
#endif

#ifdef MTM_JS_EVENT_SINGLE_RAID
#undef MTM_JS_EVENT_SINGLE_RAID
NSStringify(
  function MTMEventSingleRaidQuestSelect(idx) {
    const scroll = document.getElementById('questLinkList');
    if (scroll == null) {
      return null;
    }
    const ref = scroll.children[0];
    const target = scroll.children[idx];
    const yDiff = ref.getBoundingClientRect().y - target.getBoundingClientRect().y;
    scroll.style = 'position: relative; ' + MTMScrollTransformStyle(yDiff);
    return target.getBoundingClientRect();
  }
)
#endif
