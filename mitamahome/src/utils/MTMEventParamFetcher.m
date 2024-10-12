#import "MTMEventParamFetcher.h"

#import "MTMRecord.h"

@implementation MTMEventParamFetcher
{
  BOOL _isFetching;
}

+ (instancetype)get
{
  static MTMEventParamFetcher *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    shared = [[MTMEventParamFetcher alloc] init];
  });
  return shared;
}

- (void)processDataIfNecessary:(NSString *)data
{
  if (!_isFetching) {
    return;
  }
  @try {
    // nativeCallback({"questBattleId":5032011,"pointId":103210101,"status":"CLEAR","charId":1101,"titleId":101,"missionList":[true,true,true]});
    NSRegularExpression *nameExpression =
    [NSRegularExpression
     regularExpressionWithPattern:@"nativeCallback\\((\\{.+\\})\\);"
     options:NSRegularExpressionCaseInsensitive
     error:nil];
    NSArray *matches =
    [nameExpression
     matchesInString:data
     options:0
     range:NSMakeRange(0, data.length)];
    for (NSTextCheckingResult *match in matches) {
      if (match.numberOfRanges < 2) {
        continue;
      }
      NSRange matchRange = [match rangeAtIndex:1];
      NSString *matchString = [data substringWithRange:matchRange];
      NSData *matchedData = [matchString dataUsingEncoding:NSASCIIStringEncoding];
      NSError *error = nil;
      id dataDict =
      [NSJSONSerialization
       JSONObjectWithData:matchedData
       options:NSJSONReadingMutableContainers
       error:&error];
      if (error) {
        [[MTMRecord get] record:@"[error][fetcher] error serializing data:%@ error: %@", matchString, error];
        _isFetching = NO;
        return;
      }
      if (dataDict && [dataDict isKindOfClass:NSDictionary.class]) {
        _isFetching = NO;
        if (_callback) {
          [[MTMRecord get] record:@"[info][fetcher] fetched:%@", dataDict];
          _callback((NSDictionary *)dataDict);
        }
        return;
      }
    }
  }
  @catch (NSException *exception) {
    [[MTMRecord get] record:@"[error][fetcher] exception fetching data:%@", exception];
    _isFetching = NO;
  }
}

- (void)startFetching
{
  [[MTMRecord get] record:@"[info][fetcher] start fetching branch data for 3s"];
  // 3s
  _isFetching = YES;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3000000000), dispatch_get_main_queue(), ^{
    [MTMEventParamFetcher get]->_isFetching = NO;
    [[MTMRecord get] record:@"[info][fetcher] stop fetching"];
  });
}



@end