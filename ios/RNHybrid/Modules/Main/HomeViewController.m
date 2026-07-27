#import "HomeViewController.h"
#import "../RNContainer/RNViewController.h"
#import "../Auth/AuthManager.h"
#import "../Auth/LoginViewController.h"
#import "../IM/IMConversationViewController.h"

static UIColor *QXHomeColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

static UIColor *QXHomeColorAlpha(NSUInteger hex, CGFloat alpha) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:alpha];
}

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = QXHomeColor(0xF7FAFC);
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    [self setupUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)setupUI {
    UIView *topStrip = [[UIView alloc] init];
    topStrip.backgroundColor = QXHomeColor(0xE9FFF8);
    topStrip.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topStrip];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = QXHomeColor(0xF7FAFC);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIStackView *contentStack = [[UIStackView alloc] init];
    contentStack.axis = UILayoutConstraintAxisVertical;
    contentStack.spacing = 0;
    contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentStack];

    UIView *introView = [self createIntroView];
    [contentStack addArrangedSubview:introView];

    UIView *gridWrapper = [self createGridWrapper];
    [contentStack addArrangedSubview:gridWrapper];

    [NSLayoutConstraint activateConstraints:@[
        [topStrip.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [topStrip.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [topStrip.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [topStrip.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:6],

        [scrollView.topAnchor constraintEqualToAnchor:topStrip.bottomAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [contentStack.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [contentStack.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [contentStack.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [contentStack.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [contentStack.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],
    ]];
}

- (UIView *)createIntroView {
    UIView *introView = [[UIView alloc] init];
    introView.backgroundColor = QXHomeColor(0xE9FFF8);
    introView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"工作台";
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    titleLabel.textColor = QXHomeColor(0x223033);
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [introView addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"常用工具与业务入口";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    subtitleLabel.textColor = QXHomeColor(0x6C7A7D);
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [introView addSubview:subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:introView.topAnchor constant:8],
        [titleLabel.leadingAnchor constraintEqualToAnchor:introView.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:introView.trailingAnchor constant:-20],

        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:6],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:introView.trailingAnchor constant:-20],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:introView.bottomAnchor constant:-22],
    ]];

    return introView;
}

- (UIView *)createGridWrapper {
    UIView *wrapper = [[UIView alloc] init];
    wrapper.backgroundColor = QXHomeColor(0xF7FAFC);
    wrapper.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *rowsStack = [[UIStackView alloc] init];
    rowsStack.axis = UILayoutConstraintAxisVertical;
    rowsStack.spacing = 8;
    rowsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapper addSubview:rowsStack];

    NSArray<NSDictionary *> *cards = @[
        @{@"emoji": @"📦", @"title": @"小仓库", @"subtitle": @"密码管理", @"color": @(0xDFF8F4), @"active": @(YES)},
        @{@"emoji": @"📊", @"title": @"数据看板", @"subtitle": @"敬请期待", @"color": @(0xEEF4FF), @"active": @(NO)},
        @{@"emoji": @"📝", @"title": @"备忘录", @"subtitle": @"敬请期待", @"color": @(0xECFDF3), @"active": @(NO)},
        @{@"emoji": @"💬", @"title": @"消息中心", @"subtitle": @"即时通讯", @"color": @(0xFFF7ED), @"active": @(YES)},
        @{@"emoji": @"🎬", @"title": @"多媒体", @"subtitle": @"敬请期待", @"color": @(0xFEF3F2), @"active": @(NO)},
        @{@"emoji": @"⚙️", @"title": @"系统设置", @"subtitle": @"敬请期待", @"color": @(0xF4F3FF), @"active": @(NO)},
    ];

    for (NSInteger row = 0; row < cards.count / 2; row++) {
        UIStackView *rowStack = [[UIStackView alloc] init];
        rowStack.axis = UILayoutConstraintAxisHorizontal;
        rowStack.spacing = 8;
        rowStack.distribution = UIStackViewDistributionFillEqually;
        [rowsStack addArrangedSubview:rowStack];

        for (NSInteger column = 0; column < 2; column++) {
            NSInteger index = row * 2 + column;
            NSDictionary *cardInfo = cards[index];
            UIView *card = [self createCardWithEmoji:cardInfo[@"emoji"]
                                               title:cardInfo[@"title"]
                                            subtitle:cardInfo[@"subtitle"]
                                     iconBackground:[cardInfo[@"color"] unsignedIntegerValue]
                                              active:[cardInfo[@"active"] boolValue]];
            card.tag = index;
            [rowStack addArrangedSubview:card];
            [card.heightAnchor constraintEqualToConstant:116].active = YES;

            if ([cardInfo[@"active"] boolValue]) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
                [card addGestureRecognizer:tap];
            }
        }
    }

    [NSLayoutConstraint activateConstraints:@[
        [rowsStack.topAnchor constraintEqualToAnchor:wrapper.topAnchor constant:14],
        [rowsStack.leadingAnchor constraintEqualToAnchor:wrapper.leadingAnchor constant:12],
        [rowsStack.trailingAnchor constraintEqualToAnchor:wrapper.trailingAnchor constant:-12],
        [rowsStack.bottomAnchor constraintEqualToAnchor:wrapper.bottomAnchor constant:-24],
    ]];

    return wrapper;
}

- (UIView *)createCardWithEmoji:(NSString *)emoji
                          title:(NSString *)title
                       subtitle:(NSString *)subtitle
                iconBackground:(NSUInteger)iconBackground
                         active:(BOOL)active {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 8;
    card.layer.borderWidth = 1.0 / UIScreen.mainScreen.scale;
    card.layer.borderColor = QXHomeColorAlpha(0x101828, 0.06).CGColor;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.userInteractionEnabled = active;

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];

    UILabel *iconLabel = [[UILabel alloc] init];
    iconLabel.text = emoji;
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.font = [UIFont systemFontOfSize:22];
    iconLabel.backgroundColor = QXHomeColor(iconBackground);
    iconLabel.layer.cornerRadius = 22;
    iconLabel.clipsToBounds = YES;
    [stack addArrangedSubview:iconLabel];
    [NSLayoutConstraint activateConstraints:@[
        [iconLabel.widthAnchor constraintEqualToConstant:44],
        [iconLabel.heightAnchor constraintEqualToConstant:44],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    titleLabel.textColor = QXHomeColor(0x223033);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = subtitle;
    subtitleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    subtitleLabel.textColor = active ? QXHomeColor(0x98A2B3) : QXHomeColor(0xB8C0C8);
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:subtitleLabel];

    [stack setCustomSpacing:8 afterView:iconLabel];
    [stack setCustomSpacing:2 afterView:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [stack.leadingAnchor constraintGreaterThanOrEqualToAnchor:card.leadingAnchor constant:8],
        [stack.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-8],
    ]];

    return card;
}

- (void)cardTapped:(UITapGestureRecognizer *)gesture {
    if (gesture.view.tag == 0) {
        [self goToRNPage];
    } else if (gesture.view.tag == 3) {
        [self goToIMPage];
    }
}

- (void)goToRNPage {
    if (![[AuthManager sharedInstance] isLoggedIn]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginVC animated:YES];
        [loginVC release];
        return;
    }

    RNViewController *rnVC = [[RNViewController alloc] init];
    rnVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rnVC animated:YES];
}

- (void)goToIMPage {
    if (![[AuthManager sharedInstance] isLoggedIn]) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginVC animated:YES];
        [loginVC release];
        return;
    }

    IMConversationViewController *imVC = [[IMConversationViewController alloc] init];
    imVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:imVC animated:YES];
    [imVC release];
}

@end
