@class CPDistributedMessagingCenter;

@interface MMCService : NSObject

+ (instancetype)sharedInstance;

// Handles a test echo
- (NSDictionary *)echo:(NSString *)name withUserInfo:(NSDictionary *)userInfo;

// Handles saving preference
// User into is dict[
//   path ==> prefPath
//   pref ==> prefDict
// ]
- (NSDictionary *)handlePreferences:(NSString *)name withUserInfo:(NSDictionary *)userInfo;

// Handles appending strings
// User into is dict[
//   path ==> path [NSString]
//   content ==> data [NSString]
// ]
- (NSDictionary *)handleAppendToFile:(NSString *)name withUserInfo:(NSDictionary *)userInfo;

@end