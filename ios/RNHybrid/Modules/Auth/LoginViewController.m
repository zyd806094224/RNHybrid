#import "LoginViewController.h"
#import "AuthManager.h"
#import <QuartzCore/QuartzCore.h>
#import <Security/Security.h>

static NSString * const kLoginURL = @"https://106.15.7.132:8443/login";

static UIColor *QXLoginColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

static UIColor *QXLoginColorAlpha(NSUInteger hex, CGFloat alpha) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:alpha];
}

static CGFloat QXLoginHairline(void) {
    return 1.0 / UIScreen.mainScreen.scale;
}

static UIImage *QXLoginSystemImage(NSString *name) {
    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:name];
    }
    return nil;
}

@interface QXLoginGradientView : UIView

@property (nonatomic, copy) NSArray<UIColor *> *gradientColors;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *locations;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@end

@implementation QXLoginGradientView

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (void)setGradientColors:(NSArray<UIColor *> *)gradientColors {
    _gradientColors = [gradientColors copy];

    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:gradientColors.count];
    for (UIColor *color in gradientColors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }

    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    layer.colors = cgColors;
}

- (void)setLocations:(NSArray<NSNumber *> *)locations {
    _locations = [locations copy];
    ((CAGradientLayer *)self.layer).locations = locations;
}

- (void)setStartPoint:(CGPoint)startPoint {
    _startPoint = startPoint;
    ((CAGradientLayer *)self.layer).startPoint = startPoint;
}

- (void)setEndPoint:(CGPoint)endPoint {
    _endPoint = endPoint;
    ((CAGradientLayer *)self.layer).endPoint = endPoint;
}

@end

@interface LoginViewController () <NSURLSessionDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *togglePwdButton;
@property (nonatomic, assign) id<UIGestureRecognizerDelegate> previousPopGestureDelegate;
@property (nonatomic, assign) BOOL passwordVisible;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL managesPopGesture;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    self.view.backgroundColor = QXLoginColor(0xFFFFFF);
    self.modalPresentationCapturesStatusBarAppearance = YES;

    [self setupUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIGestureRecognizer *popGesture = self.navigationController.interactivePopGestureRecognizer;
    if (popGesture && self.navigationController.viewControllers.count > 1) {
        self.previousPopGestureDelegate = popGesture.delegate;
        popGesture.delegate = self;
        popGesture.enabled = YES;
        self.managesPopGesture = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    UIGestureRecognizer *popGesture = self.navigationController.interactivePopGestureRecognizer;
    if (self.managesPopGesture && popGesture.delegate == self) {
        popGesture.delegate = self.previousPopGestureDelegate;
    }
    self.managesPopGesture = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return self.navigationController.viewControllers.count > 1 && !self.isLoading;
    }
    return YES;
}

- (void)setupUI {
    QXLoginGradientView *backgroundView = [[QXLoginGradientView alloc] init];
    backgroundView.gradientColors = @[QXLoginColor(0xE6FFF8), QXLoginColor(0xF6FFFC), QXLoginColor(0xFFFFFF)];
    backgroundView.locations = @[@0, @0.52, @1];
    backgroundView.startPoint = CGPointMake(0.5, 0);
    backgroundView.endPoint = CGPointMake(0.5, 1);
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backgroundView];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scrollView.backgroundColor = UIColor.clearColor;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];

    UIView *headerView = [self createHeaderView];
    [contentView addSubview:headerView];

    UIView *loginCard = [self createLoginCard];
    [contentView addSubview:loginCard];

    UIView *noticeView = [self createNoticeView];
    [contentView addSubview:noticeView];

    UIView *bottomSpacer = [[UIView alloc] init];
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:bottomSpacer];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    [NSLayoutConstraint activateConstraints:@[
        [backgroundView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [backgroundView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [backgroundView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [backgroundView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [contentView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],
        [contentView.heightAnchor constraintGreaterThanOrEqualToAnchor:scrollView.frameLayoutGuide.heightAnchor],

        [headerView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],

        [loginCard.topAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:14],
        [loginCard.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [loginCard.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],

        [noticeView.topAnchor constraintEqualToAnchor:loginCard.bottomAnchor constant:20],
        [noticeView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:24],
        [noticeView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-24],

        [bottomSpacer.topAnchor constraintEqualToAnchor:noticeView.bottomAnchor constant:28],
        [bottomSpacer.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
        [bottomSpacer.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
        [bottomSpacer.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
        [bottomSpacer.heightAnchor constraintGreaterThanOrEqualToConstant:0],
    ]];
}

- (UIView *)createHeaderView {
    QXLoginGradientView *header = [[QXLoginGradientView alloc] init];
    header.gradientColors = @[QXLoginColor(0xDDFCF6), QXLoginColor(0xF2FFFB), QXLoginColor(0xFFFFFF)];
    header.locations = @[@0, @0.54, @1];
    header.startPoint = CGPointMake(0.5, 0);
    header.endPoint = CGPointMake(0.5, 1);
    header.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *brandRow = [[UIStackView alloc] init];
    brandRow.axis = UILayoutConstraintAxisHorizontal;
    brandRow.alignment = UIStackViewAlignmentCenter;
    brandRow.spacing = 14;
    brandRow.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:brandRow];

    QXLoginGradientView *logoPlate = [[QXLoginGradientView alloc] init];
    logoPlate.gradientColors = @[QXLoginColor(0x4BE4D2), QXLoginColor(0x0EA394)];
    logoPlate.startPoint = CGPointMake(0, 0);
    logoPlate.endPoint = CGPointMake(1, 1);
    logoPlate.layer.cornerRadius = 14;
    logoPlate.clipsToBounds = YES;
    [brandRow addArrangedSubview:logoPlate];
    [NSLayoutConstraint activateConstraints:@[
        [logoPlate.widthAnchor constraintEqualToConstant:48],
        [logoPlate.heightAnchor constraintEqualToConstant:48],
    ]];

    UIImageView *logoView = [[UIImageView alloc] initWithImage:[self brandLogoImage]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.translatesAutoresizingMaskIntoConstraints = NO;
    [logoPlate addSubview:logoView];
    [NSLayoutConstraint activateConstraints:@[
        [logoView.topAnchor constraintEqualToAnchor:logoPlate.topAnchor constant:5],
        [logoView.leadingAnchor constraintEqualToAnchor:logoPlate.leadingAnchor constant:5],
        [logoView.trailingAnchor constraintEqualToAnchor:logoPlate.trailingAnchor constant:-5],
        [logoView.bottomAnchor constraintEqualToAnchor:logoPlate.bottomAnchor constant:-5],
    ]];

    UIStackView *brandTextStack = [[UIStackView alloc] init];
    brandTextStack.axis = UILayoutConstraintAxisVertical;
    brandTextStack.spacing = 2;
    [brandRow addArrangedSubview:brandTextStack];

    UILabel *appNameLabel = [[UILabel alloc] init];
    appNameLabel.text = @"轻匣";
    appNameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    appNameLabel.textColor = QXLoginColor(0x203437);
    [brandTextStack addArrangedSubview:appNameLabel];

    UILabel *brandSubtitleLabel = [[UILabel alloc] init];
    brandSubtitleLabel.text = @"账号与备忘安全收纳";
    brandSubtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    brandSubtitleLabel.textColor = QXLoginColor(0x5F7376);
    [brandTextStack addArrangedSubview:brandSubtitleLabel];

    UILabel *welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.text = @"欢迎回到轻匣";
    welcomeLabel.font = [UIFont systemFontOfSize:27 weight:UIFontWeightBold];
    welcomeLabel.textColor = QXLoginColor(0x172C30);
    welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:welcomeLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"验证身份后访问你的私密空间";
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    subtitleLabel.textColor = QXLoginColor(0x60777B);
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [brandRow.topAnchor constraintEqualToAnchor:header.topAnchor constant:68],
        [brandRow.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:24],
        [brandRow.trailingAnchor constraintLessThanOrEqualToAnchor:header.trailingAnchor constant:-24],
        [brandRow.heightAnchor constraintEqualToConstant:48],

        [welcomeLabel.topAnchor constraintEqualToAnchor:brandRow.bottomAnchor constant:30],
        [welcomeLabel.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:24],
        [welcomeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:header.trailingAnchor constant:-24],

        [subtitleLabel.topAnchor constraintEqualToAnchor:welcomeLabel.bottomAnchor constant:7],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:welcomeLabel.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:header.trailingAnchor constant:-24],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:header.bottomAnchor constant:-26],
    ]];

    return header;
}

- (UIView *)createLoginCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 8;
    card.layer.borderWidth = QXLoginHairline();
    card.layer.borderColor = QXLoginColor(0xE7F0EE).CGColor;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.shadowOpacity = 0.08;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowRadius = 8;
    card.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"账号密码登录";
    titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    titleLabel.textColor = QXLoginColor(0x1F2F34);
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"请填写用于进入轻匣的账号信息";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    subtitleLabel.textColor = QXLoginColor(0x7A878B);
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:subtitleLabel];

    UILabel *usernameLabel = [self createFieldLabel:@"账号"];
    [card addSubview:usernameLabel];

    self.usernameField = [self createTextFieldWithPlaceholder:@"请输入账号" secure:NO];
    UIView *usernameInput = [self createInputContainerWithSymbol:@"person" textField:self.usernameField trailingButton:nil];
    [card addSubview:usernameInput];

    UILabel *passwordLabel = [self createFieldLabel:@"密码"];
    [card addSubview:passwordLabel];

    self.passwordField = [self createTextFieldWithPlaceholder:@"请输入密码" secure:YES];
    self.togglePwdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.togglePwdButton setImage:QXLoginSystemImage(@"eye.slash") forState:UIControlStateNormal];
    self.togglePwdButton.tintColor = QXLoginColor(0x7C9094);
    self.togglePwdButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.togglePwdButton addTarget:self action:@selector(togglePasswordVisibility) forControlEvents:UIControlEventTouchUpInside];
    UIView *passwordInput = [self createInputContainerWithSymbol:@"lock" textField:self.passwordField trailingButton:self.togglePwdButton];
    [card addSubview:passwordInput];

    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton setTitle:@"安全登录" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.loginButton.backgroundColor = QXLoginColor(0x18BFAE);
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:self.loginButton];

    UIActivityIndicatorViewStyle indicatorStyle;
    if (@available(iOS 13.0, *)) {
        indicatorStyle = UIActivityIndicatorViewStyleMedium;
    } else {
        indicatorStyle = UIActivityIndicatorViewStyleWhite;
    }
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
    self.activityIndicator.color = UIColor.whiteColor;
    self.activityIndicator.hidden = YES;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton addSubview:self.activityIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:22],
        [titleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-20],

        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:5],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-20],

        [usernameLabel.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:24],
        [usernameLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [usernameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-20],

        [usernameInput.topAnchor constraintEqualToAnchor:usernameLabel.bottomAnchor constant:8],
        [usernameInput.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [usernameInput.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [usernameInput.heightAnchor constraintEqualToConstant:52],

        [passwordLabel.topAnchor constraintEqualToAnchor:usernameInput.bottomAnchor constant:18],
        [passwordLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [passwordLabel.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-20],

        [passwordInput.topAnchor constraintEqualToAnchor:passwordLabel.bottomAnchor constant:8],
        [passwordInput.leadingAnchor constraintEqualToAnchor:usernameInput.leadingAnchor],
        [passwordInput.trailingAnchor constraintEqualToAnchor:usernameInput.trailingAnchor],
        [passwordInput.heightAnchor constraintEqualToConstant:52],

        [self.loginButton.topAnchor constraintEqualToAnchor:passwordInput.bottomAnchor constant:26],
        [self.loginButton.leadingAnchor constraintEqualToAnchor:usernameInput.leadingAnchor],
        [self.loginButton.trailingAnchor constraintEqualToAnchor:usernameInput.trailingAnchor],
        [self.loginButton.heightAnchor constraintEqualToConstant:52],
        [self.loginButton.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-22],

        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.loginButton.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.loginButton.centerYAnchor],
    ]];

    return card;
}

- (UIView *)createNoticeView {
    UIView *notice = [[UIView alloc] init];
    notice.backgroundColor = QXLoginColor(0xECFFF9);
    notice.layer.cornerRadius = 8;
    notice.layer.borderWidth = QXLoginHairline();
    notice.layer.borderColor = QXLoginColor(0xCFF2EA).CGColor;
    notice.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:QXLoginSystemImage(@"shield")];
    iconView.tintColor = QXLoginColor(0x18BFAE);
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [notice addSubview:iconView];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"账号信息仅用于身份校验，请妥善保管";
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    label.textColor = QXLoginColor(0x63787C);
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [notice addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [iconView.leadingAnchor constraintEqualToAnchor:notice.leadingAnchor constant:14],
        [iconView.centerYAnchor constraintEqualToAnchor:notice.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:18],
        [iconView.heightAnchor constraintEqualToConstant:18],

        [label.topAnchor constraintEqualToAnchor:notice.topAnchor constant:12],
        [label.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:9],
        [label.trailingAnchor constraintEqualToAnchor:notice.trailingAnchor constant:-14],
        [label.bottomAnchor constraintEqualToAnchor:notice.bottomAnchor constant:-12],
    ]];

    return notice;
}

- (UILabel *)createFieldLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    label.textColor = QXLoginColor(0x344054);
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (UITextField *)createTextFieldWithPlaceholder:(NSString *)placeholder secure:(BOOL)secure {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    field.textColor = QXLoginColor(0x203033);
    field.secureTextEntry = secure;
    field.clearButtonMode = secure ? UITextFieldViewModeNever : UITextFieldViewModeWhileEditing;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.translatesAutoresizingMaskIntoConstraints = NO;
    return field;
}

- (UIView *)createInputContainerWithSymbol:(NSString *)symbol
                                 textField:(UITextField *)textField
                            trailingButton:(UIButton *)trailingButton {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = QXLoginColor(0xFBFEFD);
    container.layer.cornerRadius = 8;
    container.layer.borderWidth = QXLoginHairline();
    container.layer.borderColor = QXLoginColor(0xDCEBE8).CGColor;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *iconView = [[UIImageView alloc] initWithImage:QXLoginSystemImage(symbol)];
    iconView.tintColor = QXLoginColor(0x7C9094);
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:iconView];
    [container addSubview:textField];

    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithArray:@[
        [iconView.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:14],
        [iconView.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:20],
        [iconView.heightAnchor constraintEqualToConstant:20],

        [textField.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:10],
        [textField.topAnchor constraintEqualToAnchor:container.topAnchor],
        [textField.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
    ]];

    if (trailingButton) {
        [container addSubview:trailingButton];
        [constraints addObjectsFromArray:@[
            [trailingButton.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
            [trailingButton.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
            [trailingButton.widthAnchor constraintEqualToConstant:44],
            [trailingButton.heightAnchor constraintEqualToConstant:44],
            [textField.trailingAnchor constraintEqualToAnchor:trailingButton.leadingAnchor],
        ]];
    } else {
        [constraints addObject:[textField.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-14]];
    }

    [NSLayoutConstraint activateConstraints:constraints];
    return container;
}

- (UIImage *)brandLogoImage {
    UIImage *image = [UIImage imageNamed:@"QingxiaLauncher"];
    if (image) {
        return image;
    }
    return QXLoginSystemImage(@"archivebox.fill");
}

- (void)endEditing {
    [self.view endEditing:YES];
}

- (void)togglePasswordVisibility {
    self.passwordVisible = !self.passwordVisible;
    self.passwordField.secureTextEntry = !self.passwordVisible;
    NSString *imageName = self.passwordVisible ? @"eye" : @"eye.slash";
    [self.togglePwdButton setImage:QXLoginSystemImage(imageName) forState:UIControlStateNormal];
}

- (void)loginTapped {
    NSString *username = [self.usernameField.text ?: @"" stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSString *password = [self.passwordField.text ?: @"" stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

    if (username.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入用户名"];
        return;
    }
    if (password.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入密码"];
        return;
    }

    [self.view endEditing:YES];
    [self setLoading:YES];
    [self performLoginWithUsername:username password:password];
}

- (void)performLoginWithUsername:(NSString *)username password:(NSString *)password {
    NSDictionary *params = @{@"username": username, @"password": password};
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];

    NSURL *url = [NSURL URLWithString:kLoginURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = bodyData;
    request.timeoutInterval = 30;

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setLoading:NO];

            if (error) {
                [self showAlertWithTitle:@"错误" message:error.localizedDescription ?: @"网络异常"];
                return;
            }

            if (!data) {
                [self showAlertWithTitle:@"错误" message:@"登录失败"];
                return;
            }

            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (![json isKindOfClass:NSDictionary.class]) {
                [self showAlertWithTitle:@"错误" message:@"登录失败"];
                return;
            }

            NSInteger code = [json[@"code"] integerValue];
            NSString *token = json[@"token"];
            NSString *msg = json[@"msg"] ?: @"登录失败";

            if (code == 200 && token.length > 0) {
                [[AuthManager sharedInstance] saveLoginWithToken:token username:username];
                [self closeAfterLogin];
            } else {
                [self showAlertWithTitle:@"提示" message:msg];
            }
        });
    }];
    [task resume];
}

- (void)closeAfterLogin {
    if (self.navigationController.topViewController == self &&
        self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLoading:(BOOL)loading {
    self.isLoading = loading;
    self.usernameField.enabled = !loading;
    self.passwordField.enabled = !loading;
    self.togglePwdButton.enabled = !loading;
    self.loginButton.enabled = !loading;

    if (loading) {
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden = NO;
        [self.loginButton setTitle:@"" forState:UIControlStateNormal];
        self.loginButton.backgroundColor = QXLoginColorAlpha(0x18BFAE, 0.65);
    } else {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        [self.loginButton setTitle:@"安全登录" forState:UIControlStateNormal];
        self.loginButton.backgroundColor = QXLoginColor(0x18BFAE);
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    if (![challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        return;
    }

    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;

#ifdef DEBUG
    NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
#else
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"server_cert" ofType:@"pem"];
    if (!certPath) {
        NSLog(@"[SSL] 内置证书未找到，拒绝连接");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    NSData *certData = [NSData dataWithContentsOfFile:certPath];
    SecCertificateRef pinnedCert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    if (!pinnedCert) {
        NSLog(@"[SSL] 内置证书解析失败，拒绝连接");
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

    SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)@[ (__bridge id)pinnedCert ]);
    SecTrustSetAnchorCertificatesOnly(serverTrust, true);

    SecTrustResultType result;
    OSStatus status = SecTrustEvaluate(serverTrust, &result);

    CFRelease(pinnedCert);

    if (status == errSecSuccess && (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed)) {
        NSLog(@"[SSL] 证书校验通过");
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        NSLog(@"[SSL] 证书校验失败，拒绝连接 (result: %d)", result);
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
#endif
}

@end
