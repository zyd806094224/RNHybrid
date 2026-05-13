#import "MineViewController.h"
#import "../Auth/AuthManager.h"
#import "../Auth/LoginViewController.h"

@interface MineViewController ()

@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIView *headerView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUI];
}

- (void)setupUI {
    CGFloat width = self.view.bounds.size.width;

    // 顶部紫色区域
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor colorWithRed:0.38 green:0.0 blue:0.93 alpha:1.0];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerView];

    // 用户图标
    UIImageView *avatarView = [[UIImageView alloc] init];
    avatarView.image = [UIImage systemImageNamed:@"person.circle.fill"];
    avatarView.tintColor = [UIColor whiteColor];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:avatarView];

    // 用户名
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.userNameLabel.textColor = [UIColor whiteColor];
    self.userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.userNameLabel];

    // 副标题
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.font = [UIFont systemFontOfSize:13];
    self.subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.subtitleLabel];

    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped)];
    [self.headerView addGestureRecognizer:headerTap];

    // 个人信息卡片
    UIView *infoCard = [self createCardView];
    [self.view addSubview:infoCard];

    UILabel *infoTitle = [self createSectionTitle:@"个人信息"];
    [infoCard addSubview:infoTitle];

    UIView *phoneRow = [self createInfoRowWithIcon:@"phone.fill" title:@"手机" value:@"未绑定"];
    UIView *emailRow = [self createInfoRowWithIcon:@"envelope.fill" title:@"邮箱" value:@"未绑定"];
    [infoCard addSubview:phoneRow];
    [infoCard addSubview:emailRow];

    // 设置卡片
    UIView *settingsCard = [self createCardView];
    [self.view addSubview:settingsCard];

    UILabel *settingsTitle = [self createSectionTitle:@"设置"];
    [settingsCard addSubview:settingsTitle];

    UIView *aboutRow = [self createInfoRowWithIcon:@"info.circle.fill" title:@"关于" value:@"RNHybrid v1.0"];
    [settingsCard addSubview:aboutRow];

    // 操作按钮（登录/退出）
    self.actionLabel = [[UILabel alloc] init];
    self.actionLabel.textAlignment = NSTextAlignmentCenter;
    self.actionLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.actionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *actionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapped)];
    [self.actionLabel addGestureRecognizer:actionTap];
    [self.view addSubview:self.actionLabel];

    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 顶部区域
        [self.headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.headerView.heightAnchor constraintEqualToConstant:140],

        [avatarView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:20],
        [avatarView.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
        [avatarView.widthAnchor constraintEqualToConstant:50],
        [avatarView.heightAnchor constraintEqualToConstant:50],

        [self.userNameLabel.leadingAnchor constraintEqualToAnchor:avatarView.trailingAnchor constant:15],
        [self.userNameLabel.topAnchor constraintEqualToAnchor:avatarView.topAnchor constant:2],

        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.userNameLabel.leadingAnchor],
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.userNameLabel.bottomAnchor constant:6],

        // 个人信息卡片
        [infoCard.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:12],
        [infoCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:12],
        [infoCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-12],

        [infoTitle.topAnchor constraintEqualToAnchor:infoCard.topAnchor constant:14],
        [infoTitle.leadingAnchor constraintEqualToAnchor:infoCard.leadingAnchor constant:16],

        [phoneRow.topAnchor constraintEqualToAnchor:infoTitle.bottomAnchor constant:10],
        [phoneRow.leadingAnchor constraintEqualToAnchor:infoCard.leadingAnchor constant:16],
        [phoneRow.trailingAnchor constraintEqualToAnchor:infoCard.trailingAnchor constant:-16],
        [phoneRow.heightAnchor constraintEqualToConstant:40],

        [emailRow.topAnchor constraintEqualToAnchor:phoneRow.bottomAnchor constant:0],
        [emailRow.leadingAnchor constraintEqualToAnchor:infoCard.leadingAnchor constant:16],
        [emailRow.trailingAnchor constraintEqualToAnchor:infoCard.trailingAnchor constant:-16],
        [emailRow.heightAnchor constraintEqualToConstant:40],
        [emailRow.bottomAnchor constraintEqualToAnchor:infoCard.bottomAnchor constant:-10],

        // 设置卡片
        [settingsCard.topAnchor constraintEqualToAnchor:infoCard.bottomAnchor constant:12],
        [settingsCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:12],
        [settingsCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-12],

        [settingsTitle.topAnchor constraintEqualToAnchor:settingsCard.topAnchor constant:14],
        [settingsTitle.leadingAnchor constraintEqualToAnchor:settingsCard.leadingAnchor constant:16],

        [aboutRow.topAnchor constraintEqualToAnchor:settingsTitle.bottomAnchor constant:10],
        [aboutRow.leadingAnchor constraintEqualToAnchor:settingsCard.leadingAnchor constant:16],
        [aboutRow.trailingAnchor constraintEqualToAnchor:settingsCard.trailingAnchor constant:-16],
        [aboutRow.heightAnchor constraintEqualToConstant:40],
        [aboutRow.bottomAnchor constraintEqualToAnchor:settingsCard.bottomAnchor constant:-10],

        // 操作按钮
        [self.actionLabel.topAnchor constraintEqualToAnchor:settingsCard.bottomAnchor constant:30],
        [self.actionLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.actionLabel.widthAnchor constraintEqualToConstant:120],
        [self.actionLabel.heightAnchor constraintEqualToConstant:40],
    ]];
}

- (void)refreshUI {
    if ([[AuthManager sharedInstance] isLoggedIn]) {
        self.userNameLabel.text = [[AuthManager sharedInstance] getUsername];
        self.subtitleLabel.text = @"已登录";
        self.actionLabel.text = @"退出登录";
        self.actionLabel.textColor = [UIColor colorWithRed:0.96 green:0.26 blue:0.21 alpha:1.0]; // red
    } else {
        self.userNameLabel.text = @"未登录";
        self.subtitleLabel.text = @"点击去登录";
        self.actionLabel.text = @"登录";
        self.actionLabel.textColor = [UIColor colorWithRed:0.38 green:0.0 blue:0.93 alpha:1.0]; // purple
    }
}

- (void)headerTapped {
    if (![[AuthManager sharedInstance] isLoggedIn]) {
        [self presentLoginVC];
    }
}

- (void)actionTapped {
    if ([[AuthManager sharedInstance] isLoggedIn]) {
        // 退出登录
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"确定要退出登录吗？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[AuthManager sharedInstance] logout];
            [self refreshUI];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self presentLoginVC];
    }
}

- (void)presentLoginVC {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:loginVC animated:YES completion:nil];
}

#pragma mark - UI Helpers

- (UIView *)createCardView {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 10;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    return card;
}

- (UILabel *)createSectionTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    label.textColor = [UIColor blackColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UIView *)createInfoRowWithIcon:(NSString *)iconName title:(NSString *)title value:(NSString *)value {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *icon = [[UIImageView alloc] init];
    icon.image = [UIImage systemImageNamed:iconName];
    icon.tintColor = [UIColor colorWithRed:0.38 green:0.0 blue:0.93 alpha:1.0];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:icon];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:14];
    valueLabel.textColor = [UIColor lightGrayColor];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:valueLabel];

    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
        [icon.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:22],
        [icon.heightAnchor constraintEqualToConstant:22],

        [titleLabel.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
        [titleLabel.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],

        [valueLabel.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
        [valueLabel.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [valueLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:titleLabel.trailingAnchor constant:10],
    ]];

    return row;
}

@end
