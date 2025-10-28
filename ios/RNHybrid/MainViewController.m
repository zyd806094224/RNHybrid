#import "MainViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>
#import "RNViewController.h"

/**
 * MainViewController
 * 这是一个独立的原生页面，类似于Android中的Activity
 * 负责展示主页面内容，并提供跳转到RN页面的功能
 */
@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"主页面";
    
    // 隐藏导航栏以实现全屏效果
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // 创建返回按钮
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
    
    // 创建标签
    UILabel *label = [[UILabel alloc] init];
    label.text = @"主页面";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    
    [self.view addSubview:label];
    
    // 设置标签约束，实现全屏居中
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    // 创建跳转到RN页面的按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"跳转到RN页面" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button sizeToFit];
    button.backgroundColor = [UIColor systemBlueColor];
    button.layer.cornerRadius = 8.0;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToRNPage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    // 设置按钮约束
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [button.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:40],
        [button.widthAnchor constraintGreaterThanOrEqualToConstant:120],
        [button.heightAnchor constraintGreaterThanOrEqualToConstant:40]
    ]];
}

- (void)goToRNPage {
    // 创建并跳转到RN页面
    RNViewController *rnVC = [[RNViewController alloc] init];
    [self.navigationController pushViewController:rnVC animated:YES];
}

- (void)goBack {
    // 检查是否有可以返回的页面，如果没有则返回到启动页
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // 如果没有可返回的页面，dismiss整个导航控制器
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end