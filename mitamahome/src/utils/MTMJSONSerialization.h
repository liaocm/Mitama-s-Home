//
//  MTMJSONSerialization.h
//  libmitamaui
//
//  Created by Chengming Liao on 8/9/20.
//  Copyright © 2020 Chengming Liao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTMJSONSerialization : NSObject

+ (NSString *)serializeDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
