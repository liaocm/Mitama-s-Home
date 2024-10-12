// MTMPreferenceValues.m
// libmitamaui
//
// Generated on 2020-09-06 10:50:45
//
#import "MTMPreferenceValues.h"

NSArray *MTMPreferenceValuesFromKey(NSString *key)
{
  NSArray *result = nil;
  if (false) {}
  else if ([key isEqual:@"quest"]) {
    result = @[@0, @1, @2, @3, @4, @5, @6, @7];
  }
  else if ([key isEqual:@"questindex"]) {
    result = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11];
  }
  else if ([key isEqual:@"support"]) {
    result = @[@0, @1, @2, @3];
  }
  else if ([key isEqual:@"potion"]) {
    result = @[@0, @1, @2, @3];
  }
  else if ([key isEqual:@"dailytowerquesttype"]) {
    result = @[@0, @1, @2];
  }
  else if ([key isEqual:@"mitamaquesttype"]) {
    result = @[@0, @1, @2, @3];
  }
  else if ([key isEqual:@"speedup"]) {
    result = @[@0.3, @0.1, @0.03];
  }
  else if ([key isEqual:@"skillcountmod"]) {
    result = @[@0, @1, @2, @3];
  }
  else if ([key isEqual:@"timer"]) {
    return @[@1.0, @1.5, @2.0, @2.5, @3.0, @3.5, @4.0];
  }
  return result;
}

NSArray *MTMPreferenceTitleValuesFromKey(NSString *key)
{
  NSArray *result = nil;
  if (false) {}
  else if ([key isEqual:@"quest"]) {
    result = @[@"Generic Quest Select", @"Weekly Quest: Material", @"Weekly Quest: Awakening", @"Event: DailyTower", @"Event: Branch", @"Event: Mitama's Training", @"Event: Story Raid", @"Event: Single Raid"];
  }
  else if ([key isEqual:@"questindex"]) {
    result = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11"];
  }
  else if ([key isEqual:@"support"]) {
    result = @[@"Always First", @"First Bonus Only", @"First Bonus If Possible", @"NPC"];
  }
  else if ([key isEqual:@"potion"]) {
    result = @[@"Never Use Potion", @"50 AP Potion", @"Full AP Potion", @"Gem"];
  }
  else if ([key isEqual:@"dailytowerquesttype"]) {
    result = @[@"Story", @"Challenge", @"ExChallenge"];
  }
  else if ([key isEqual:@"mitamaquesttype"]) {
    result = @[@"Story", @"Enhance", @"Episode", @"Extra"];
  }
  else if ([key isEqual:@"speedup"]) {
    result = @[@"Minimal", @"Standard", @"Fast"];
  }
  else if ([key isEqual:@"skillcountmod"]) {
    result = @[@"Unchanged", @"Always 0", @"Divides by 5", @"Divides by 10"];
  }
  else if ([key isEqual:@"timer"]) {
    return @[@"1.0", @"1.5", @"2.0", @"2.5", @"3.0", @"3.5", @"4.0"];
  }
  return result;
}

// End of MTMPreferenceValues.m