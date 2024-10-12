//
//  MTMDiscRow.h
//  libmitamaui
//
//  Created by Chengming Liao on 7/25/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTMDiscRowModel : NSObject

+ (instancetype)newWithTypes:(NSArray<NSString *> *)types title:(NSUInteger)title enabled:(BOOL)enabled;

@property (nonatomic) NSArray<NSString *> *discTypes;
@property (nonatomic, assign) NSUInteger title;
@property (nonatomic, assign) BOOL enabled;

@end

@interface MTMDiscRow : UIView

@property (nonatomic) MTMDiscRowModel *model;

@end

NS_ASSUME_NONNULL_END
