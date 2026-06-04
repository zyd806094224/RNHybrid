#import "MainViewController.h"
#import "HomeViewController.h"
#import "MineViewController.h"

static UIColor *QXMainColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

static UIImage *QXMainSystemImage(NSString *name) {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:name];
    }
    return nil;
}

@interface MainViewController () <UITabBarControllerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 全屏布局：视图延伸到状态栏和底部安全区域
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.delegate = self;

    // 主页 Tab
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.navigationBarHidden = YES;
    homeNav.tabBarItem.title = @"主页";
    homeNav.tabBarItem.image = QXMainSystemImage(@"house");
    homeNav.tabBarItem.selectedImage = QXMainSystemImage(@"house.fill");

    // 我的 Tab
    MineViewController *mineVC = [[MineViewController alloc] init];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.navigationBarHidden = YES;
    mineNav.tabBarItem.title = @"我的";
    mineNav.tabBarItem.image = QXMainSystemImage(@"person");
    mineNav.tabBarItem.selectedImage = QXMainSystemImage(@"person.fill");

    // 设置 TabBar 外观
    self.viewControllers = @[homeNav, mineNav];
    self.tabBar.tintColor = QXMainColor(0x12BFA5);
    self.tabBar.unselectedItemTintColor = QXMainColor(0xAAB4C0);
    self.tabBar.backgroundColor = UIColor.whiteColor;
    self.tabBar.translucent = NO;

    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = UIColor.whiteColor;
        appearance.stackedLayoutAppearance.selected.iconColor = QXMainColor(0x12BFA5);
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: QXMainColor(0x12BFA5)};
        appearance.stackedLayoutAppearance.normal.iconColor = QXMainColor(0xAAB4C0);
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: QXMainColor(0xAAB4C0)};
        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *selected = self.selectedViewController;
    if ([selected isKindOfClass:UINavigationController.class]) {
        return ((UINavigationController *)selected).topViewController;
    }
    return selected;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
