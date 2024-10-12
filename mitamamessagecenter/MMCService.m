#import "MMCService.h"

#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation MMCService
{
  CPDistributedMessagingCenter *_messagingCenter;
}

- (instancetype)init
{
  if (self = [super init]) {
    NSLog(@"[mitama] loaded into SpringBoard");
    _messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.liaocm.mitama.MessagingCenter"];
    rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
    [_messagingCenter runServerOnCurrentThread];

    [_messagingCenter
      registerForMessageName:@"com.liaocm.mitama.echo"
      target:self
      selector:@selector(echo:withUserInfo:)];

    [_messagingCenter
      registerForMessageName:@"com.liaocm.mitama.savePref"
      target:self
      selector:@selector(handlePreferences:withUserInfo:)];

    [_messagingCenter
      registerForMessageName:@"com.liaocm.mitama.appendString"
      target:self
      selector:@selector(handleAppendToFile:withUserInfo:)];
  }
  return self;
}

+ (instancetype)sharedInstance
{
  static dispatch_once_t once_token = 0;
  static MMCService *sharedInstance = nil;
  dispatch_once(&once_token, ^{
    sharedInstance = [self new];
  });
  return sharedInstance;
}

- (NSDictionary *)echo:(NSString *)name withUserInfo:(NSDictionary *)userInfo
{
  NSLog(@"[mitama] echo: %@, userInfo: %@", name, userInfo);
  return userInfo;
}

- (NSDictionary *)handleAppendToFile:(NSString *)name withUserInfo:(NSDictionary *)userInfo
{
  @try {
    NSString *path = [userInfo objectForKey:@"path"];
    NSString *str = [userInfo objectForKey:@"data"];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:path];
    if(output == nil) {
      [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
      output = [NSFileHandle fileHandleForWritingAtPath:path];
    } else {
      [output seekToEndOfFile];
    }
    [output writeData:data];
    [output closeFile];
    NSLog(@"[mitama] wrote to file: %@", str);
  } @catch (NSException *_) {}
  return userInfo;
}

- (NSDictionary *)handlePreferences:(NSString *)name withUserInfo:(NSDictionary *)userInfo
{
  @try {
    // write pref
    NSDictionary *pref = [userInfo objectForKey:@"pref"];
    NSString *path = [userInfo objectForKey:@"path"];
    if (path && pref) {
      [self _writePref:pref toFile:path];
    }
    NSLog(@"[mitama] wrote to pref: %@", pref);
  } @catch (NSException *_) {
  }
  return userInfo;
}

- (void)_writePref:(NSDictionary *)pref toFile:(NSString *)path
{
  [pref writeToFile:path atomically:YES];
}

@end