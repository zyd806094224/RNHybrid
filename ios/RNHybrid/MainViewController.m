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

@end