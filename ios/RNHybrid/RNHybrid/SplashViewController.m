#import "SplashViewController.h"
#import "MainViewController.h"

/**
 * SplashViewController
 * 这是一个独立的启动页，类似于Android中的Activity
 * 负责展示启动画面并倒计时3秒后跳转到主页面
 */
@interface SplashViewController ()

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSInteger countdownSeconds;
@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic, assign) BOOL isViewDidAppear;
@property (nonatomic, assign) BOOL hasStartedCountdown;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化倒计时秒数
    self.countdownSeconds = 3;
    
    // 创建倒计时标签
    [self setupCountdownLabel];
    
    // 创建欢迎标签（居中显示）
    UILabel *welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.text = @"欢迎使用RN混合应用";
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    welcomeLabel.textColor = [UIColor blackColor];
    
    [self.view addSubview:welcomeLabel];
    
    // 设置欢迎标签居中
    welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [welcomeLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [welcomeLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewDidAppear = YES;
    
    // 确保只启动一次倒计时
    if (!self.hasStartedCountdown) {
        self.hasStartedCountdown = YES;
        [self startCountdown];
    }
    
    // 如果倒计时已经结束但未跳转，则执行跳转
    if (self.countdownSeconds <= 0) {
        [self countdownFinished];
    }
}

- (void)setupCountdownLabel {
    self.countdownLabel = [[UILabel alloc] init];
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel.font = [UIFont systemFontOfSize:20];
    self.countdownLabel.textColor = [UIColor blackColor];
    self.countdownLabel.text = [NSString stringWithFormat:@"跳过 %ld", (long)self.countdownSeconds];
    
    [self.view addSubview:self.countdownLabel];
    
    // 设置约束
    self.countdownLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.countdownLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.countdownLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50],
        [self.countdownLabel.widthAnchor constraintEqualToConstant:80],
        [self.countdownLabel.heightAnchor constraintEqualToConstant:40]
    ]];
    
    // 添加边框
    self.countdownLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.countdownLabel.layer.borderWidth = 1.0;
    self.countdownLabel.layer.cornerRadius = 6.0;
}

- (void)startCountdown {
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateCountdown)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)updateCountdown {
    self.countdownSeconds--;
    self.countdownLabel.text = [NSString stringWithFormat:@"跳过 %ld", (long)self.countdownSeconds];
    
    if (self.countdownSeconds <= 0) {
        [self countdownFinished];
    }
}

- (void)countdownFinished {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    
    // 确保视图已经加载完成再跳转
    if (self.isViewDidAppear) {
        // 跳转到主页面
        [self transitionToMainViewController];
    }
    // 如果视图尚未加载完成，不执行任何操作，等待viewDidAppear时再处理
}

- (void)transitionToMainViewController {
    MainViewController *mainVC = [[MainViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    
    // 设置导航控制器全屏显示（隐藏状态栏）
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // 动画过渡到主页面
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 点击任意位置立即跳过启动页
    if (self.countdownTimer) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
    }
    
    // 确保视图已经加载完成再跳转
    if (self.isViewDidAppear) {
        [self transitionToMainViewController];
    } else {
        // 如果视图尚未加载完成，直接设置倒计时结束标志，等待viewDidAppear时再处理
        self.countdownSeconds = 0;
    }
}

@end