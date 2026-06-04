#import "MineViewController.h"
#import "../Auth/AuthManager.h"
#import "../Auth/LoginViewController.h"

static UIColor *QXMineColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

static UIColor *QXMineColorAlpha(NSUInteger hex, CGFloat alpha) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:alpha];
}

static CGFloat QXMineHairline(void) {
    return 1.0 / UIScreen.mainScreen.scale;
}

static UIImage *QXMineSystemImage(NSString *name) {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:name];
    }
    return nil;
}

static UIImage *QXMineSystemImageWithPointSize(NSString *name, CGFloat pointSize) {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:UIImageSymbolWeightRegular];
        return [UIImage systemImageNamed:name withConfiguration:configuration];
    }
    return nil;
}

@interface QXMinePaddedLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets textInsets;

@end

@implementation QXMinePaddedLabel

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += self.textInsets.left + self.textInsets.right;
    size.height += self.textInsets.top + self.textInsets.bottom;
    return size;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

@end

@interface MineViewController ()

@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) QXMinePaddedLabel *subtitleLabel;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *logoutRow;
@property (nonatomic, strong) UIView *logoutDivider;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = QXMineColor(0xF7FAFC);
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setupUI {
    UIView *topStrip = [[UIView alloc] init];
    topStrip.backgroundColor = QXMineColor(0x18BFAE);
    topStrip.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topStrip];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = QXMineColor(0xF7FAFC);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIStackView *contentStack = [[UIStackView alloc] init];
    contentStack.axis = UILayoutConstraintAxisVertical;
    contentStack.spacing = 12;
    contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentStack];

    self.headerView = [self createHeaderView];
    [contentStack addArrangedSubview:self.headerView];
    [contentStack setCustomSpacing:14 afterView:self.headerView];

    [contentStack addArrangedSubview:[self wrapCard:[self createAccountCard]]];
    [contentStack addArrangedSubview:[self wrapCard:[self createServiceCard]]];
    [contentStack addArrangedSubview:[self wrapCard:[self createSettingsCard]]];

    UIView *bottomSpacer = [[UIView alloc] init];
    [contentStack addArrangedSubview:bottomSpacer];
    [bottomSpacer.heightAnchor constraintEqualToConstant:12].active = YES;

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

    [self refreshUI];
}

- (UIView *)createHeaderView {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = QXMineColor(0x18BFAE);
    header.userInteractionEnabled = YES;
    header.translatesAutoresizingMaskIntoConstraints = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped)];
    [header addGestureRecognizer:tap];

    UIStackView *verticalStack = [[UIStackView alloc] init];
    verticalStack.axis = UILayoutConstraintAxisVertical;
    verticalStack.spacing = 18;
    verticalStack.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:verticalStack];

    UIStackView *profileStack = [[UIStackView alloc] init];
    profileStack.axis = UILayoutConstraintAxisHorizontal;
    profileStack.alignment = UIStackViewAlignmentCenter;
    profileStack.spacing = 14;
    [verticalStack addArrangedSubview:profileStack];

    UIView *avatarSurface = [[UIView alloc] init];
    avatarSurface.backgroundColor = UIColor.whiteColor;
    avatarSurface.layer.cornerRadius = 32;
    avatarSurface.layer.borderWidth = QXMineHairline();
    avatarSurface.layer.borderColor = QXMineColorAlpha(0xFFFFFF, 0.4).CGColor;
    [profileStack addArrangedSubview:avatarSurface];
    [NSLayoutConstraint activateConstraints:@[
        [avatarSurface.widthAnchor constraintEqualToConstant:64],
        [avatarSurface.heightAnchor constraintEqualToConstant:64],
    ]];

    UIImageView *avatarIcon = [[UIImageView alloc] initWithImage:QXMineSystemImage(@"person")];
    avatarIcon.tintColor = QXMineColor(0x18BFAE);
    avatarIcon.contentMode = UIViewContentModeScaleAspectFit;
    avatarIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [avatarSurface addSubview:avatarIcon];
    [NSLayoutConstraint activateConstraints:@[
        [avatarIcon.centerXAnchor constraintEqualToAnchor:avatarSurface.centerXAnchor],
        [avatarIcon.centerYAnchor constraintEqualToAnchor:avatarSurface.centerYAnchor],
        [avatarIcon.widthAnchor constraintEqualToConstant:34],
        [avatarIcon.heightAnchor constraintEqualToConstant:34],
    ]];

    UIStackView *nameStack = [[UIStackView alloc] init];
    nameStack.axis = UILayoutConstraintAxisVertical;
    nameStack.alignment = UIStackViewAlignmentLeading;
    nameStack.spacing = 6;
    [profileStack addArrangedSubview:nameStack];

    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.font = [UIFont systemFontOfSize:21 weight:UIFontWeightBold];
    self.userNameLabel.textColor = UIColor.whiteColor;
    self.userNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [nameStack addArrangedSubview:self.userNameLabel];

    self.subtitleLabel = [[QXMinePaddedLabel alloc] init];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    self.subtitleLabel.textColor = QXMineColor(0xEAF2FF);
    self.subtitleLabel.backgroundColor = QXMineColorAlpha(0xFFFFFF, 0.15);
    self.subtitleLabel.textInsets = UIEdgeInsetsMake(4, 10, 4, 10);
    self.subtitleLabel.layer.cornerRadius = 10;
    self.subtitleLabel.clipsToBounds = YES;
    [nameStack addArrangedSubview:self.subtitleLabel];

    UIImageView *chevron = [[UIImageView alloc] initWithImage:QXMineSystemImage(@"chevron.right")];
    chevron.tintColor = QXMineColorAlpha(0xFFFFFF, 0.8);
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    [profileStack addArrangedSubview:chevron];
    [NSLayoutConstraint activateConstraints:@[
        [chevron.widthAnchor constraintEqualToConstant:22],
        [chevron.heightAnchor constraintEqualToConstant:22],
    ]];

    UIStackView *metricsStack = [[UIStackView alloc] init];
    metricsStack.axis = UILayoutConstraintAxisHorizontal;
    metricsStack.spacing = 10;
    metricsStack.distribution = UIStackViewDistributionFillEqually;
    [verticalStack addArrangedSubview:metricsStack];
    [metricsStack addArrangedSubview:[self createMetricViewWithTitle:@"收藏"]];
    [metricsStack addArrangedSubview:[self createMetricViewWithTitle:@"优惠券"]];
    [metricsStack addArrangedSubview:[self createMetricViewWithTitle:@"消息"]];

    [NSLayoutConstraint activateConstraints:@[
        [verticalStack.topAnchor constraintEqualToAnchor:header.topAnchor constant:24],
        [verticalStack.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:20],
        [verticalStack.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-20],
        [verticalStack.bottomAnchor constraintEqualToAnchor:header.bottomAnchor constant:-20],
        [metricsStack.heightAnchor constraintEqualToConstant:60],
    ]];

    return header;
}

- (UIView *)createMetricViewWithTitle:(NSString *)title {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = QXMineColorAlpha(0xFFFFFF, 0.12);
    view.layer.cornerRadius = 8;
    view.layer.borderWidth = QXMineHairline();
    view.layer.borderColor = QXMineColorAlpha(0xFFFFFF, 0.2).CGColor;

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 4;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:stack];

    UILabel *numberLabel = [[UILabel alloc] init];
    numberLabel.text = @"0";
    numberLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    numberLabel.textColor = UIColor.whiteColor;
    [stack addArrangedSubview:numberLabel];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    titleLabel.textColor = QXMineColorAlpha(0xEAF2FF, 0.8);
    [stack addArrangedSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
    ]];

    return view;
}

- (UIView *)wrapCard:(UIView *)card {
    UIView *wrapper = [[UIView alloc] init];
    wrapper.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapper addSubview:card];
    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:wrapper.topAnchor],
        [card.leadingAnchor constraintEqualToAnchor:wrapper.leadingAnchor constant:16],
        [card.trailingAnchor constraintEqualToAnchor:wrapper.trailingAnchor constant:-16],
        [card.bottomAnchor constraintEqualToAnchor:wrapper.bottomAnchor],
    ]];
    return wrapper;
}

- (UIView *)createCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 8;
    card.layer.borderWidth = QXMineHairline();
    card.layer.borderColor = QXMineColorAlpha(0x101828, 0.06).CGColor;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    return card;
}

- (UIView *)createAccountCard {
    UIView *card = [self createCard];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];

    UILabel *titleLabel = [self createSectionTitle:@"账户信息"];
    [stack addArrangedSubview:titleLabel];
    [stack setCustomSpacing:12 afterView:titleLabel];

    [stack addArrangedSubview:[self createInfoRowWithSymbol:@"phone"
                                                      title:@"手机号"
                                                      value:@"未绑定"
                                            iconBackground:0xEEF4FF
                                                   iconTint:0x155EEF]];
    [stack addArrangedSubview:[self createDividerWithLeading:48]];
    [stack addArrangedSubview:[self createInfoRowWithSymbol:@"envelope"
                                                      title:@"邮箱"
                                                      value:@"未绑定"
                                            iconBackground:0xDFF8F4
                                                   iconTint:0x008E7D]];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
    ]];

    return card;
}

- (UIView *)createServiceCard {
    UIView *card = [self createCard];

    UIStackView *grid = [[UIStackView alloc] init];
    grid.axis = UILayoutConstraintAxisHorizontal;
    grid.distribution = UIStackViewDistributionFillEqually;
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:grid];

    [grid addArrangedSubview:[self createServiceItemWithSymbol:@"creditcard"
                                                         title:@"钱包"
                                               iconBackground:0xFFF7ED
                                                      iconTint:0xD97706]];
    [grid addArrangedSubview:[self createServiceItemWithSymbol:@"ticket"
                                                         title:@"卡券"
                                               iconBackground:0xECFDF3
                                                      iconTint:0x16A34A]];
    [grid addArrangedSubview:[self createServiceItemWithSymbol:@"headphones"
                                                         title:@"客服"
                                               iconBackground:0xFEF3F2
                                                      iconTint:0xDC2626]];
    [grid addArrangedSubview:[self createServiceItemWithSymbol:@"gearshape"
                                                         title:@"设置"
                                               iconBackground:0xF4F3FF
                                                      iconTint:0x7C3AED]];

    [NSLayoutConstraint activateConstraints:@[
        [grid.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
        [grid.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [grid.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        [grid.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
        [grid.heightAnchor constraintEqualToConstant:82],
    ]];

    return card;
}

- (UIView *)createSettingsCard {
    UIView *card = [self createCard];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 0;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];

    [stack addArrangedSubview:[self createActionRowWithSymbol:@"shield"
                                                        title:@"账户安全"
                                                        value:@"待完善"
                                               iconBackground:0xECFDF3
                                                      iconTint:0x16A34A
                                                       isLogout:NO]];
    [stack addArrangedSubview:[self createDividerWithLeading:48]];
    [stack addArrangedSubview:[self createActionRowWithSymbol:@"info.circle"
                                                        title:@"关于我们"
                                                        value:nil
                                               iconBackground:0xEEF4FF
                                                      iconTint:0x155EEF
                                                       isLogout:NO]];
    self.logoutDivider = [self createDividerWithLeading:48];
    [stack addArrangedSubview:self.logoutDivider];
    self.logoutRow = [self createActionRowWithSymbol:@"arrow.right.square"
                                               title:@"退出登录"
                                               value:nil
                                      iconBackground:0xFEF3F2
                                             iconTint:0xDC2626
                                              isLogout:YES];
    UITapGestureRecognizer *logoutTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutTapped)];
    [self.logoutRow addGestureRecognizer:logoutTap];
    [stack addArrangedSubview:self.logoutRow];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:8],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-8],
    ]];

    return card;
}

- (UILabel *)createSectionTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    label.textColor = QXMineColor(0x101828);
    return label;
}

- (UIView *)createInfoRowWithSymbol:(NSString *)symbol
                              title:(NSString *)title
                              value:(NSString *)value
                    iconBackground:(NSUInteger)iconBackground
                           iconTint:(NSUInteger)iconTint {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *iconCircle = [self createIconCircleWithSymbol:symbol background:iconBackground tint:iconTint size:36 symbolSize:18];
    [row addSubview:iconCircle];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    titleLabel.textColor = QXMineColor(0x344054);
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    valueLabel.textColor = QXMineColor(0x98A2B3);
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:valueLabel];

    [NSLayoutConstraint activateConstraints:@[
        [row.heightAnchor constraintEqualToConstant:54],
        [iconCircle.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
        [iconCircle.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],

        [titleLabel.leadingAnchor constraintEqualToAnchor:iconCircle.trailingAnchor constant:12],
        [titleLabel.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],

        [valueLabel.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
        [valueLabel.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [valueLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:titleLabel.trailingAnchor constant:10],
    ]];

    return row;
}

- (UIView *)createServiceItemWithSymbol:(NSString *)symbol
                                  title:(NSString *)title
                        iconBackground:(NSUInteger)iconBackground
                               iconTint:(NSUInteger)iconTint {
    UIView *item = [[UIView alloc] init];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 9;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [item addSubview:stack];

    [stack addArrangedSubview:[self createIconCircleWithSymbol:symbol background:iconBackground tint:iconTint size:42 symbolSize:21]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    titleLabel.textColor = QXMineColor(0x344054);
    [stack addArrangedSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:item.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:item.centerYAnchor],
    ]];

    return item;
}

- (UIView *)createActionRowWithSymbol:(NSString *)symbol
                                title:(NSString *)title
                                value:(NSString *)value
                       iconBackground:(NSUInteger)iconBackground
                              iconTint:(NSUInteger)iconTint
                              isLogout:(BOOL)isLogout {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.userInteractionEnabled = isLogout;

    UIView *iconCircle = [self createIconCircleWithSymbol:symbol background:iconBackground tint:iconTint size:36 symbolSize:18];
    [row addSubview:iconCircle];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:isLogout ? UIFontWeightBold : UIFontWeightRegular];
    titleLabel.textColor = isLogout ? QXMineColor(0xDC2626) : QXMineColor(0x344054);
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLabel];

    UILabel *valueLabel = nil;
    if (value.length > 0) {
        valueLabel = [[UILabel alloc] init];
        valueLabel.text = value;
        valueLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        valueLabel.textColor = QXMineColor(0x98A2B3);
        valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [row addSubview:valueLabel];
    }

    UIImageView *chevron = nil;
    if (!isLogout) {
        chevron = [[UIImageView alloc] initWithImage:QXMineSystemImage(@"chevron.right")];
        chevron.tintColor = QXMineColor(0x98A2B3);
        chevron.contentMode = UIViewContentModeScaleAspectFit;
        chevron.translatesAutoresizingMaskIntoConstraints = NO;
        [row addSubview:chevron];
    }

    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithArray:@[
        [row.heightAnchor constraintEqualToConstant:56],
        [iconCircle.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
        [iconCircle.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],

        [titleLabel.leadingAnchor constraintEqualToAnchor:iconCircle.trailingAnchor constant:12],
        [titleLabel.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
    ]];

    if (isLogout) {
        [constraints addObject:[titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:row.trailingAnchor]];
    } else {
        [constraints addObjectsFromArray:@[
            [chevron.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
            [chevron.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
            [chevron.widthAnchor constraintEqualToConstant:18],
            [chevron.heightAnchor constraintEqualToConstant:18],
        ]];

        if (valueLabel) {
            [constraints addObjectsFromArray:@[
                [valueLabel.trailingAnchor constraintEqualToAnchor:chevron.leadingAnchor constant:-6],
                [valueLabel.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
                [valueLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:titleLabel.trailingAnchor constant:10],
            ]];
        } else {
            [constraints addObject:[titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:chevron.leadingAnchor constant:-10]];
        }
    }

    [NSLayoutConstraint activateConstraints:constraints];
    return row;
}

- (UIView *)createIconCircleWithSymbol:(NSString *)symbol
                            background:(NSUInteger)background
                                  tint:(NSUInteger)tint
                                  size:(CGFloat)size
                            symbolSize:(CGFloat)symbolSize {
    UIView *circle = [[UIView alloc] init];
    circle.backgroundColor = QXMineColor(background);
    circle.layer.cornerRadius = size / 2.0;
    circle.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:QXMineSystemImageWithPointSize(symbol, symbolSize)];
    iconView.tintColor = QXMineColor(tint);
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [circle addSubview:iconView];

    [NSLayoutConstraint activateConstraints:@[
        [circle.widthAnchor constraintEqualToConstant:size],
        [circle.heightAnchor constraintEqualToConstant:size],
        [iconView.centerXAnchor constraintEqualToAnchor:circle.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:circle.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:symbolSize],
        [iconView.heightAnchor constraintEqualToConstant:symbolSize],
    ]];

    return circle;
}

- (UIView *)createDividerWithLeading:(CGFloat)leading {
    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [container.heightAnchor constraintEqualToConstant:QXMineHairline()].active = YES;

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = QXMineColor(0xF2F4F7);
    line.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:line];

    [NSLayoutConstraint activateConstraints:@[
        [line.topAnchor constraintEqualToAnchor:container.topAnchor],
        [line.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:leading],
        [line.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [line.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
    ]];

    return container;
}

- (void)refreshUI {
    BOOL loggedIn = [[AuthManager sharedInstance] isLoggedIn];
    if (loggedIn) {
        NSString *username = [[AuthManager sharedInstance] getUsername];
        self.userNameLabel.text = username.length > 0 ? username : @"已登录用户";
        self.subtitleLabel.text = @"已登录";
        self.logoutRow.hidden = NO;
        self.logoutDivider.hidden = NO;
    } else {
        self.userNameLabel.text = @"未登录";
        self.subtitleLabel.text = @"点击去登录";
        self.logoutRow.hidden = YES;
        self.logoutDivider.hidden = YES;
    }

    [self.subtitleLabel invalidateIntrinsicContentSize];
}

- (void)headerTapped {
    if (![[AuthManager sharedInstance] isLoggedIn]) {
        [self presentLoginVC];
    }
}

- (void)logoutTapped {
    if (![[AuthManager sharedInstance] isLoggedIn]) {
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"确定要退出登录吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[AuthManager sharedInstance] logout];
        [self refreshUI];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentLoginVC {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginVC animated:YES];
}

@end
