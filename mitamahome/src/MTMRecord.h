//
//  MTMRecord.h
//  libmitamaui
//
//  Created by Chengming Liao on 6/28/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTMRecord;

@protocol MTMRecordListener <NSObject>

- (void)recordDidUpdate:(MTMRecord *_Nonnull)record;

@end

NS_ASSUME_NONNULL_BEGIN

@interface MTMRecord : NSObject

+ (instancetype)get;
+ (void)clear;

- (void)record:(NSString *)format, ...;
- (NSArray<NSString *> *)displayList;
- (void)addListener:(id<MTMRecordListener>)listener;
- (void)removeListener:(id<MTMRecordListener>)listener;

@end

NS_ASSUME_NONNULL_END
