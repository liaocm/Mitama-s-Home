#import <Foundation/Foundation.h>

typedef void (^MTMEventParamFetchCallback)(NSDictionary *);

@interface MTMEventParamFetcher : NSObject

+ (instancetype)get;
- (void)startFetching;
- (void)processDataIfNecessary:(NSString *)data;

@property (readwrite, copy) MTMEventParamFetchCallback callback;

@end
