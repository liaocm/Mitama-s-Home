//
//  MTMHookManager.h
//
//
//  Created by Chengming Liao on 7/25/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTMHookManager : NSObject

+ (instancetype)get;
- (void)hookParser;
- (void)hookStringify;
- (void)setDiscOverrides:(NSDictionary *)discOverrides;
- (void)setMiscOverrides:(NSDictionary *)miscOverrides;

@end

NS_ASSUME_NONNULL_END
