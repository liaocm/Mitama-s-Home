#ifdef MITAMA_THEOS_BUILD

#import "MTMTelepathy.h"

#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

static NSString *kPrefFilePath = @"/var/mobile/Library/Preferences/com.liaocm.mitamapref.plist";
static NSString *kLogFilePath = @"/var/mobile/Documents/com.liaocm.mitama-log.txt";

@implementation MTMTelepathy
{
  CPDistributedMessagingCenter *_messageCenter;
}

+ (instancetype)get
{
  static MTMTelepathy *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    shared = [[MTMTelepathy alloc] init];
  });
  return shared;
}

- (instancetype)init
{
  if (self = [super init]) {
  _messageCenter =
    [CPDistributedMessagingCenter
      centerNamed:@"com.liaocm.mitama.MessagingCenter"];
    rocketbootstrap_distributedmessagingcenter_apply(_messageCenter);
  }
  return self;
}

- (void)savePreferenceAt:(NSString *)path content:(NSDictionary *)content
{
  [_messageCenter sendMessageAndReceiveReplyName:@"com.liaocm.mitama.savePref"
    userInfo:@{
      @"path" : path,
      @"pref" : content
  }];
}

- (void)appendContentAt:(NSString *)path content:(NSString *)content
{
  [_messageCenter sendMessageAndReceiveReplyName:@"com.liaocm.mitama.appendString"
    userInfo:@{
      @"path" : path,
      @"data" : content
  }];
}

- (BOOL)ping
{
  // Send a message with a dictionary and receive a reply dictionary
  NSDictionary * replyWithMessage = [_messageCenter sendMessageAndReceiveReplyName:@"com.liaocm.mitama.echo" userInfo:@{@"ping" : @"pong"}];
  return [replyWithMessage[@"ping"] isEqual:@"pong"];
}

- (void)saveCrashLog:(NSString *)content
{
  [self appendContentAt:kLogFilePath content:content];
}

- (void)savePreference:(NSDictionary *)pref
{
  [self savePreferenceAt:kPrefFilePath content:pref];
}

@end

#endif
