//
//  MTMRecord.m
//  libmitamaui
//
//  Created by Chengming Liao on 6/28/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import "MTMRecord.h"

static const NSUInteger kDisplayListMaxSize = 1000;
static const NSUInteger kFlushThreshold = 50;

@implementation MTMRecord
{
  NSMutableArray<NSString *> *_displayList;
  NSMutableArray<NSString *> *_flushList;

  NSMutableArray<id<MTMRecordListener>> *_listener;
}

+ (instancetype)get
{
  static MTMRecord *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    shared = [[MTMRecord alloc] init];
  });
  return shared;
}

+ (void)clear
{
  MTMRecord *r = [MTMRecord get];
  r->_displayList = [NSMutableArray new];
  r->_flushList = [NSMutableArray new];
  [r publishUpdate];
}

- (instancetype)init
{
  if (self = [super init]) {
    _displayList = [NSMutableArray new];
    _flushList = [NSMutableArray new];
    _listener = [NSMutableArray new];
  }
  return self;
}

- (void)record:(NSString *)format, ...
{
  va_list args;
  va_start(args, format);
  NSString *entry =
  [[NSString alloc]
   initWithFormat:format arguments:args];
  va_end(args);
  [self _record:entry];
  [self publishUpdate];
}

- (NSArray<NSString *> *)displayList
{
  return [NSArray arrayWithArray:_displayList];
}

- (void)_record:(NSString *)entry
{
  NSDate *now = [NSDate now];
  NSDateFormatter *formatter = [NSDateFormatter new];
  formatter.dateFormat = @"MMM dd HH:mm:ss";
  NSString *dateString = [formatter stringFromDate:now];
  NSString *decorated =
  [NSString stringWithFormat:@"%@ > %@", dateString, entry];
  // if debug, we can also nslog this
  [self _listBump:decorated];
}

- (void)_listBump:(NSString *)entry
{
  if (!entry.length) {
    return;
  }

  if (_displayList.count < kDisplayListMaxSize) {
    [_displayList addObject:entry];
  } else {
    NSString *first = [_displayList objectAtIndex:0];
    [_displayList removeObjectAtIndex:0];
    [_displayList addObject:entry];
    [_flushList addObject:first];
  }

  if (_flushList.count >= kFlushThreshold) {
    // flush to disk

    // clear flush buffer
    _flushList = [NSMutableArray new];
  }
}

// PubSub
- (void)addListener:(id<MTMRecordListener>)listener
{
  [_listener addObject:listener];
}

- (void)removeListener:(id<MTMRecordListener>)listener
{
  [_listener removeObject:listener];
}

- (void)publishUpdate
{
  for (id<MTMRecordListener> listener in _listener) {
    [listener recordDidUpdate:self];
  }
}

@end
