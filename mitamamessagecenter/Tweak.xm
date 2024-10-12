#import "MMCService.h"

#import <SpringBoard/SpringBoard.h>

%hook SpringBoard

- (id)init
{
  [MMCService sharedInstance];
  return %orig;
}

%end