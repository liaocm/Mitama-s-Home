#import <WebKit/WebKit.h>

#pragma mark - crash supression

@interface SmartBeat : NSObject
+ (id)shared;
+ (id)startWithApiKey:(NSString *)apiKey withEnabled:(BOOL)arg2;
+ (id)startWithApiKey:(NSString *)apiKey;
- (id)initWithApiKey:(id)arg1;
@end

@interface CYZDefines : NSObject
{
  BOOL _isJailBreaked;
}
+ (id)sharedDefines;
- (BOOL)checkJailBreak;
- (BOOL)isJailBreaked;
@end

@interface SmartBeatUtil : NSObject
+ (BOOL)isJailbroken;
@end


#pragma mark - AppDelegate

@interface AppController : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    UIViewController *_rootViewController;
}

@property(readonly, nonatomic) UIViewController *rootViewController; // @synthesize rootViewController=_rootViewController;
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;
- (void)applicationDidBecomeActive:(id)arg1;

@property(retain, nonatomic) UIWindow *window;

@end

#pragma mark - rootViewController & Views

@class RootViewController;
@interface RootViewController : UIViewController
{
  RootViewController *_rootViewController;
}

@property(readonly, nonatomic) UIView *eaglView;
- (void)viewDidLoad;

@end


@interface CCEAGLView : UIView
@end

#pragma mark - webviews

@interface WebViewWrapper : NSObject
- (void)userContentController:(WKUserContentController *)arg1 didReceiveScriptMessage:(WKScriptMessage *)arg2;
- (void)setWkWebView:(WKWebView *)wkWebView;
- (void)setWkConfig:(WKWebViewConfiguration *)wkConfig;
@end

#pragma mark - misc

@interface _UIFlowLayoutSection
-(void)logInvalidSizesForHorizontalDirection:(BOOL)arg1 warnAboutDelegateValues:(BOOL)arg2;
@end

