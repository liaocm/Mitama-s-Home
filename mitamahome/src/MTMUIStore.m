#import "MTMUIStore.h"

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "MTMRecord.h"
#import "MTMLayout.h"

@interface MTMUIStore () <UIGestureRecognizerDelegate>
@end

@implementation MTMUIStore
{
  UIView *_eaglView;
  WKWebView *_webview;

  MTMUIStoreGestureCallback _gestureCallback;
}

+ (instancetype)get
{
  static MTMUIStore *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    shared = [[MTMUIStore alloc] init];
  });
  return shared;
}

- (void)setCallback:(MTMUIStoreGestureCallback)callback
{
  _gestureCallback = callback;
}

- (void)setRootView:(UIView *)view
{
  _eaglView = view;
}

- (UIView *)rootView
{
  return _eaglView;
}

- (void)setWebView:(WKWebView *)webview
{
  [[MTMRecord get] record:@"[UIStore] Acquiring webview: %@; old webview: %@", webview, _webview];
  [webview.configuration.preferences setValue:@YES forKey:@"developerExtrasEnabled"];
  _webview = webview;

  UIScreenEdgePanGestureRecognizer *left =
    [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanLeftEdge:)];
  left.edges = UIRectEdgeLeft;
  [webview addGestureRecognizer:left];

  UIScreenEdgePanGestureRecognizer *right =
    [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanRightEdge:)];
  right.edges = UIRectEdgeRight;
  [webview addGestureRecognizer:right];

  left.delegate = self;
  right.delegate = self;
}

- (void)didPanLeftEdge:(UIScreenEdgePanGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateRecognized) {
    if (_gestureCallback) {
      _gestureCallback(0, sender);
    }
  }
}

- (void)didPanRightEdge:(UIScreenEdgePanGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateRecognized) {
    if (_gestureCallback) {
      _gestureCallback(1, sender);
    }
  }
}

- (WKWebView *)webview
{
  return _webview;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  return YES;
}

@end

UIButton *MTMGenericButtonCreate(NSString *title)
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.translatesAutoresizingMaskIntoConstraints = NO;
  [button setTitle:title forState:UIControlStateNormal];
  [button setBackgroundColor:RGBA(0, 0, 0, 0.2)];
  button.titleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightBold];
  [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  button.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);
  button.layer.cornerRadius = 6.f;
  return button;
}
