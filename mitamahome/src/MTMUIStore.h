#import <UIKit/UIKit.h>

@class WKWebView;
@interface MTMUIStore : NSObject

typedef void (^MTMUIStoreGestureCallback)(NSInteger, id);

+ (instancetype)get;
- (void)setRootView:(UIView *)view;
- (UIView *)rootView;
- (void)setWebView:(WKWebView *)webview;
- (WKWebView *)webview;
- (void)setCallback:(MTMUIStoreGestureCallback)callback;

@end

UIButton *MTMGenericButtonCreate(NSString *title);
