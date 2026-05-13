#import "MainViewController.h"
#import "HomeViewController.h"
#import "MineViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 主页 Tab
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem.title = @"主页";
    homeNav.tabBarItem.image = [UIImage systemImageNamed:@"house"];
    homeNav.tabBarItem.selectedImage = [UIImage systemImageNamed:@"house.fill"];

    // 我的 Tab
    MineViewController *mineVC = [[MineViewController alloc] init];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem.title = @"我的";
    mineNav.tabBarItem.image = [UIImage systemImageNamed:@"person"];
    mineNav.tabBarItem.selectedImage = [UIImage systemImageNamed:@"person.fill"];

    // 设置 TabBar 外观
    self.viewControllers = @[homeNav, mineNav];
    self.tabBar.tintColor = [UIColor colorWithRed:0.24 green:0.0 blue:0.72 alpha:1.0]; // purple_700
    self.tabBar.unselectedItemTintColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];

    // 导航栏外观
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor blackColor],
            NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]
        };

        for (UINavigationController *nav in self.viewControllers) {
            nav.navigationBar.standardAppearance = appearance;
            nav.navigationBar.scrollEdgeAppearance = appearance;
        }
    }
}

@end
