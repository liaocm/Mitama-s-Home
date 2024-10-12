#ifdef MITAMA_THEOS_BUILD
@interface MTMTelepathy : NSObject

+ (instancetype)get;
- (void)savePreferenceAt:(NSString *)path content:(NSDictionary *)content;
- (void)appendContentAt:(NSString *)path content:(NSString *)content;
- (void)saveCrashLog:(NSString *)content;
- (BOOL)ping;
- (void)savePreference:(NSDictionary *)pref;

@end
#endif
