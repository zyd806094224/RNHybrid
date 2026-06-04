#import "AppDelegate.h"
#import "../Modules/Main/SplashViewController.h"
#import "../Modules/Auth/AuthManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [[AuthManager sharedInstance] prepareForLaunch];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.backgroundColor = [UIColor whiteColor];
  
  // 设置根视图控制器为启动页
  SplashViewController *splashVC = [[SplashViewController alloc] init];
  self.window.rootViewController = splashVC;
  
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
