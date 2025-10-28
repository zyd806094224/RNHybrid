#import "RNViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootViewDelegate.h>

/**
 * RNViewController
 * 这是一个独立的React Native容器页面，类似于Android中的Activity
 * 负责加载和显示React Native内容
 */
@interface RNViewController () <RCTRootViewDelegate>

@property (nonatomic, strong) RCTRootView *reactRootView;

@end

@implementation RNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"RN页面";
    
    // 隐藏导航栏以实现全屏效果
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // 初始化React Native视图
    NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
    
    self.reactRootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:@"RNHybrid"
                                                 initialProperties:nil
                                                     launchOptions:nil];
    
    self.reactRootView.delegate = self;
    
    [self.view addSubview:self.reactRootView];
    
    // 设置约束，确保React Native视图填充整个屏幕
    self.reactRootView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.reactRootView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.reactRootView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.reactRootView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.reactRootView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    // 创建返回按钮（在React Native视图之后添加，确保在最上层）
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [backButton sizeToFit];
    backButton.backgroundColor = [UIColor systemBlueColor];
    backButton.layer.cornerRadius = 8.0;
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
    
    // 设置返回按钮约束
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [backButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50],
        [backButton.widthAnchor constraintGreaterThanOrEqualToConstant:60],
        [backButton.heightAnchor constraintGreaterThanOrEqualToConstant:30]
    ]];
}

- (void)goBack {
    // 检查是否有可以返回的页面，如果没有则返回到主页面
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // 如果没有可返回的页面，dismiss整个导航控制器
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - RCTRootViewDelegate

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    // 可选：处理根视图大小变化
}

@end