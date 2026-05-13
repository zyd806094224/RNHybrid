#import "HomeViewController.h"
#import "../RNContainer/RNViewController.h"
#import "../Auth/AuthManager.h"
#import "../Auth/LoginViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    [self setupUI];
}

- (void)setupUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];

    // 2x4 网格数据
    NSArray *cards = @[
        @{@"icon": @"house.fill",     @"title": @"小仓库", @"subtitle": @"密码管理", @"color": @(0x6200EE), @"active": @(YES)},
        @{@"icon": @"chart.bar.fill", @"title": @"数据分析", @"subtitle": @"敬请期待", @"color": @(0x2196F3), @"active": @(NO)},
        @{@"icon": @"bell.fill",      @"title": @"消息中心", @"subtitle": @"敬请期待", @"color": @(0x4CAF50), @"active": @(NO)},
        @{@"icon": @"gearshape.fill", @"title": @"系统设置", @"subtitle": @"敬请期待", @"color": @(0xFF9800), @"active": @(NO)},
        @{@"icon": @"doc.fill",       @"title": @"文档管理", @"subtitle": @"敬请期待", @"color": @(0xF44336), @"active": @(NO)},
        @{@"icon": @"person.fill",    @"title": @"通讯录",   @"subtitle": @"敬请期待", @"color": @(0x009688), @"active": @(NO)},
        @{@"icon": @"camera.fill",    @"title": @"相册",     @"subtitle": @"敬请期待", @"color": @(0xE91E63), @"active": @(NO)},
        @{@"icon": @"map.fill",       @"title": @"地图",     @"subtitle": @"敬请期待", @"color": @(0x3F51B5), @"active": @(NO)},
    ];

    CGFloat cardPadding = 12;
    CGFloat cardH = 90;
    CGFloat edgeMargin = 10;

    NSMutableArray *constraints = [NSMutableArray array];

    UIView *previousTopAnchor = contentView.topAnchor;
    CGFloat previousHeight = 0;

    NSInteger rowCount = (cards.count + 1) / 2;

    for (NSInteger row = 0; row < rowCount; row++) {
        NSInteger col0Index = row * 2;
        NSInteger col1Index = row * 2 + 1;

        UIView *leftCard = nil;
        UIView *rightCard = nil;

        if (col0Index < cards.count) {
            NSDictionary *card = cards[col0Index];
            leftCard = [self createCardWithIcon:card[@"icon"]
                                          title:card[@"title"]
                                       subtitle:card[@"subtitle"]
                                          color:[card[@"color"] integerValue]
                                         active:[card[@"active"] boolValue]];
            [contentView addSubview:leftCard];

            if ([card[@"active"] boolValue]) {
                leftCard.tag = col0Index;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
                [leftCard addGestureRecognizer:tap];
            }
        }

        if (col1Index < cards.count) {
            NSDictionary *card = cards[col1Index];
            rightCard = [self createCardWithIcon:card[@"icon"]
                                           title:card[@"title"]
                                        subtitle:card[@"subtitle"]
                                           color:[card[@"color"] integerValue]
                                          active:[card[@"active"] boolValue]];
            [contentView addSubview:rightCard];

            if ([card[@"active"] boolValue]) {
                rightCard.tag = col1Index;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTapped:)];
                [rightCard addGestureRecognizer:tap];
            }
        }

        // 行间距
        CGFloat topOffset = (row == 0) ? edgeMargin : cardPadding;

        // 左卡片约束
        [constraints addObject:[leftCard.topAnchor constraintEqualToAnchor:previousTopAnchor constant:topOffset]];
        [constraints addObject:[leftCard.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:edgeMargin]];
        [constraints addObject:[leftCard.widthAnchor constraintEqualToAnchor:contentView.widthAnchor
                                                            multiplier:0.5
                                                              constant:-(edgeMargin + cardPadding / 2.0)]];
        [constraints addObject:[leftCard.heightAnchor constraintEqualToConstant:cardH]];

        if (rightCard) {
            // 右卡片约束
            [constraints addObject:[rightCard.topAnchor constraintEqualToAnchor:leftCard.topAnchor]];
            [constraints addObject:[rightCard.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-edgeMargin]];
            [constraints addObject:[rightCard.widthAnchor constraintEqualToAnchor:leftCard.widthAnchor]];
            [constraints addObject:[rightCard.heightAnchor constraintEqualToConstant:cardH]];

            previousTopAnchor = leftCard.bottomAnchor;
        } else {
            previousTopAnchor = leftCard.bottomAnchor;
        }
    }

    // contentView 底部约束
    [constraints addObject:[contentView.bottomAnchor constraintGreaterThanOrEqualToAnchor:previousTopAnchor constant:edgeMargin]];

    // scrollView 和 contentView 基本约束
    [constraints addObjectsFromArray:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [contentView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],
    ]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (UIView *)createCardWithIcon:(NSString *)iconName
                         title:(NSString *)title
                      subtitle:(NSString *)subtitle
                         color:(NSInteger)hexColor
                        active:(BOOL)active {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 10;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.06;
    card.layer.shadowOffset = CGSizeMake(0, 1);
    card.layer.shadowRadius = 4;
    card.translatesAutoresizingMaskIntoConstraints = NO;

    CGFloat r = ((hexColor >> 16) & 0xFF) / 255.0;
    CGFloat g = ((hexColor >> 8) & 0xFF) / 255.0;
    CGFloat b = (hexColor & 0xFF) / 255.0;
    UIColor *iconColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    UIColor *iconBgColor = [UIColor colorWithRed:r green:g blue:b alpha:0.1];

    // 图标背景
    UIView *iconBg = [[UIView alloc] init];
    iconBg.backgroundColor = iconBgColor;
    iconBg.layer.cornerRadius = 18;
    iconBg.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:iconBg];

    // 图标
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:iconName];
    iconView.tintColor = iconColor;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [iconBg addSubview:iconView];

    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    titleLabel.textColor = active ? [UIColor blackColor] : [UIColor grayColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:titleLabel];

    // 副标题
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = subtitle;
    subtitleLabel.font = [UIFont systemFontOfSize:12];
    subtitleLabel.textColor = [UIColor lightGrayColor];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [iconBg.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:12],
        [iconBg.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [iconBg.widthAnchor constraintEqualToConstant:36],
        [iconBg.heightAnchor constraintEqualToConstant:36],

        [iconView.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:20],
        [iconView.heightAnchor constraintEqualToConstant:20],

        [titleLabel.leadingAnchor constraintEqualToAnchor:iconBg.trailingAnchor constant:10],
        [titleLabel.centerYAnchor constraintEqualToAnchor:card.centerYAnchor constant:-8],

        [subtitleLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:2],
    ]];

    if (!active) {
        card.alpha = 0.6;
    }

    return card;
}

- (void)cardTapped:(UITapGestureRecognizer *)gesture {
    NSInteger tag = gesture.view.tag;
    if (tag == 0) {
        // 小仓库 → RN 密码管理页面
        [self goToRNPage];
    }
}

- (void)goToRNPage {
    if (![[AuthManager sharedInstance] isLoggedIn]) {
        // 未登录，先跳转登录
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }

    RNViewController *rnVC = [[RNViewController alloc] init];
    rnVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rnVC animated:YES];
}

@end
