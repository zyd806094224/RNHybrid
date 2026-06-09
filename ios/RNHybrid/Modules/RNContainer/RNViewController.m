#import "RNViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootViewDelegate.h>
#import "../Auth/AuthManager.h"
#import "../Auth/AuthModule.h"
#import "../Auth/LoginViewController.h"
#import <react-native-update/RCTPushy.h>

static NSString * const RNEmbeddedBundleName = @"main";
static NSString * const RNEmbeddedBundleExtension = @"jsbundle";

/**
 * RNViewController
 * React Native 容器页面，对标 Android RNPageActivity
 * 从 AuthManager 读取 token/username 传给 RN
 */
@interface RNViewController () <RCTRootViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) RCTRootView *reactRootView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, assign) BOOL hasTriedToInitializeReactNative;
@property (nonatomic, assign) BOOL isViewFirstTimeAppeared;
@property (nonatomic, assign) BOOL didShowErrorMessage;

@end

@implementation RNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"";
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    NSLog(@"RNViewController viewDidLoad");

    // 添加加载指示器和标签
    [self setupLoadingUI];

    // 初始化状态
    self.hasTriedToInitializeReactNative = NO;
    self.isViewFirstTimeAppeared = NO;
    self.didShowErrorMessage = NO;

    // 设置 token 过期回调
    AuthModule.tokenExpiredCallback = ^{
        [self handleTokenExpired];
    };

#if DEBUG
    [self loadDebugBundle];
#else
    [self loadPushyBundle];
#endif
}

- (void)dealloc {
    AuthModule.isHandling = NO;
    AuthModule.tokenExpiredCallback = nil;
    NSLog(@"RNViewController deallocated");
}

- (void)handleTokenExpired {
    // 关闭 RN 页面并跳转登录
    [self.navigationController popViewControllerAnimated:YES];

    // 在当前导航栈中找到可见的 VC，弹出登录页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *visibleVC = [self topViewController];
        if (visibleVC) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.hidesBottomBarWhenPushed = YES;
            if (visibleVC.navigationController) {
                [visibleVC.navigationController pushViewController:loginVC animated:YES];
            } else {
                loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [visibleVC presentViewController:loginVC animated:YES completion:nil];
            }
        }
    });
}

- (UIViewController *)topViewController {
    UIWindow *keyWindow = nil;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }
    return [self topViewControllerFrom:keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerFrom:(UIViewController *)vc {
    if (vc.presentedViewController) {
        return [self topViewControllerFrom:vc.presentedViewController];
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [self topViewControllerFrom:nav.visibleViewController];
    }
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        return [self topViewControllerFrom:tab.selectedViewController];
    }
    return vc;
}

- (void)setupLoadingUI {
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.view.center;
    [self.view addSubview:self.loadingIndicator];

    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.text = @"正在加载中...";
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.font = [UIFont systemFontOfSize:16];
    self.loadingLabel.textColor = [UIColor blackColor];
    self.loadingLabel.frame = CGRectMake(0, self.loadingIndicator.frame.origin.y + 40, self.view.frame.size.width, 20);
    [self.view addSubview:self.loadingLabel];

    [self.loadingIndicator startAnimating];
}

- (NSURL *)embeddedBundleURL {
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:RNEmbeddedBundleName
                                               withExtension:RNEmbeddedBundleExtension];
    if (!bundleURL) {
        NSLog(@"Embedded React Native bundle is missing.");
    }
    return bundleURL;
}

- (void)loadDebugBundle {
    self.loadingLabel.text = @"正在连接开发服务...";
    NSURL *embeddedBundleURL = [self embeddedBundleURL];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSURL *bundleURL = [[RCTBundleURLProvider sharedSettings]
            jsBundleURLForBundleRoot:@"index"
                 fallbackURLProvider:^NSURL * {
                     return embeddedBundleURL;
                 }];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (bundleURL.isFileURL) {
                NSLog(@"DEBUG mode: Metro unavailable, using embedded bundle.");
            } else {
                NSLog(@"DEBUG mode: Using Metro dev server.");
            }
            [self initializeReactNativeWithBundle:bundleURL];
        });
    });
}

- (void)fallbackToEmbeddedBundleWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hasTriedToInitializeReactNative) return;

        if (message.length > 0) {
            self.loadingLabel.text = message;
        }
        NSLog(@"Falling back to embedded React Native bundle.");
        [self initializeReactNativeWithBundle:[self embeddedBundleURL]];
    });
}

- (void)loadPushyBundle {
    self.loadingLabel.text = @"正在加载...";
    NSURL *pushyURL = [RCTPushy bundleURL];
    if (pushyURL) {
        NSLog(@"Loading Pushy hot update bundle: %@", pushyURL);
        [self initializeReactNativeWithBundle:pushyURL];
    } else {
        NSLog(@"No Pushy update found, falling back to embedded bundle.");
        [self fallbackToEmbeddedBundleWithMessage:@"正在加载内置页面..."];
    }
}

- (void)showLoadErrorUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
        [self.loadingIndicator setHidden:YES];
        [self.loadingLabel setHidden:YES];

        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.text = @"页面加载失败，请稍后重试。";
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.numberOfLines = 0;
        errorLabel.textColor = [UIColor redColor];
        errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:errorLabel];

        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        backButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:backButton];

        [NSLayoutConstraint activateConstraints:@[
            [errorLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [errorLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            [errorLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20],
            [errorLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20],
            [backButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [backButton.topAnchor constraintEqualToAnchor:errorLabel.bottomAnchor constant:20]
        ]];
    });
}

- (void)initializeReactNativeWithBundle:(NSURL *)bundleURL {
    if (self.hasTriedToInitializeReactNative) return;
    self.hasTriedToInitializeReactNative = YES;

    NSURL *finalBundleURL = bundleURL;

    NSLog(@"Initializing React Native with bundle URL: %@", finalBundleURL);

    if (finalBundleURL == nil) {
        NSLog(@"Error: Bundle URL is nil, cannot initialize React Native");
        if (self.didShowErrorMessage) return;
        self.didShowErrorMessage = YES;

        [self.loadingIndicator stopAnimating];
        [self.loadingIndicator removeFromSuperview];
        [self.loadingLabel removeFromSuperview];
        [self showLoadErrorUI];
        return;
    }

    @try {
        // 从 AuthManager 读取 token/username 传给 RN
        NSDictionary *initialParams = @{
            @"param1": @"ios",
            @"token": [[AuthManager sharedInstance] getToken],
            @"username": [[AuthManager sharedInstance] getUsername]
        };

        self.reactRootView = [[RCTRootView alloc] initWithBundleURL:finalBundleURL
                                                          moduleName:@"RNHybrid"
                                                   initialProperties:initialParams
                                                       launchOptions:nil];

        self.reactRootView.delegate = self;

        [self.loadingIndicator stopAnimating];
        [self.loadingIndicator removeFromSuperview];
        [self.loadingLabel removeFromSuperview];

        [self.view addSubview:self.reactRootView];

        self.reactRootView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.reactRootView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.reactRootView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [self.reactRootView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [self.reactRootView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];

    } @catch (NSException *exception) {
        NSLog(@"Exception occurred while initializing React Native: %@", exception.reason);

        [self.loadingIndicator stopAnimating];
        [self.loadingIndicator removeFromSuperview];
        [self.loadingLabel removeFromSuperview];

        if (self.didShowErrorMessage) return;
        self.didShowErrorMessage = YES;
        [self showLoadErrorUI];
    }
}

- (void)goBack {
    if (self.navigationController && self.navigationController.viewControllers.count > 1 && self.navigationController.topViewController == self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - RCTRootViewDelegate

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    // 可选：处理根视图大小变化
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏导航栏后，需要让手势代理指向 self 才能响应左滑返回
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复手势代理，避免影响其他页面
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isViewFirstTimeAppeared) {
        self.isViewFirstTimeAppeared = YES;
    }
}

@end
