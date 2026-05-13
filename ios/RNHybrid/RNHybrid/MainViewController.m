#import "MainViewController.h"
#import "HomeViewController.h"
#import "MineViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 全屏布局：视图延伸到状态栏和底部安全区域
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    // 主页 Tab
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.navigationBarHidden = YES;
    homeNav.tabBarItem.title = @"主页";
    homeNav.tabBarItem.image = [UIImage systemImageNamed:@"house"];
    homeNav.tabBarItem.selectedImage = [UIImage systemImageNamed:@"house.fill"];

    // 我的 Tab
    MineViewController *mineVC = [[MineViewController alloc] init];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.navigationBarHidden = YES;
    mineNav.tabBarItem.title = @"我的";
    mineNav.tabBarItem.image = [UIImage systemImageNamed:@"person"];
    mineNav.tabBarItem.selectedImage = [UIImage systemImageNamed:@"person.fill"];

    // 设置 TabBar 外观
    self.viewControllers = @[homeNav, mineNav];
    self.tabBar.tintColor = [UIColor colorWithRed:0.24 green:0.0 blue:0.72 alpha:1.0]; // purple_700
    self.tabBar.unselectedItemTintColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
}

@end
