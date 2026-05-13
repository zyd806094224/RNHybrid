#import "LoginViewController.h"
#import "AuthManager.h"

static NSString * const kLoginURL = @"https://106.15.7.132:8443/login";

@interface LoginViewController () <NSURLSessionDelegate>

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *togglePwdButton;
@property (nonatomic, assign) BOOL passwordVisible;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    self.title = @"登录";

    [self setupUI];
}

- (void)setupUI {
    CGFloat cardWidth = MIN(self.view.bounds.size.width - 40, 400);
    CGFloat centerX = self.view.bounds.size.width / 2.0;

    // 卡片容器
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 12;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOpacity = 0.08;
    cardView.layer.shadowOffset = CGSizeMake(0, 2);
    cardView.layer.shadowRadius = 8;
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:cardView];

    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"RNHybrid";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithRed:0.38 green:0.0 blue:0.93 alpha:1.0]; // purple_500
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:titleLabel];

    // 副标题
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"账号登录";
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.textColor = [UIColor grayColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:subtitleLabel];

    // 用户名输入框
    self.usernameField = [self createTextFieldWithPlaceholder:@"请输入用户名"];
    [cardView addSubview:self.usernameField];

    // 分隔线
    UIView *divider1 = [self createDivider];
    [cardView addSubview:divider1];

    // 密码输入框容器（包含密码框和切换按钮）
    UIView *passwordContainer = [[UIView alloc] init];
    passwordContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:passwordContainer];

    self.passwordField = [self createTextFieldWithPlaceholder:@"请输入密码"];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.translatesAutoresizingMaskIntoConstraints = NO;
    [passwordContainer addSubview:self.passwordField];

    self.togglePwdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.togglePwdButton setImage:[UIImage systemImageNamed:@"eye.slash"] forState:UIControlStateNormal];
    self.togglePwdButton.tintColor = [UIColor grayColor];
    self.togglePwdButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.togglePwdButton addTarget:self action:@selector(togglePasswordVisibility) forControlEvents:UIControlEventTouchUpInside];
    [passwordContainer addSubview:self.togglePwdButton];

    // 分隔线
    UIView *divider2 = [self createDivider];
    [cardView addSubview:divider2];

    // 登录按钮
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton setTitle:@"登 录" forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.38 green:0.0 blue:0.93 alpha:1.0];
    self.loginButton.layer.cornerRadius = 8;
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:self.loginButton];

    // 加载指示器
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.color = [UIColor whiteColor];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidden = YES;
    [self.loginButton addSubview:self.activityIndicator];

    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 卡片居中，距离顶部 120
        [cardView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [cardView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:100],
        [cardView.widthAnchor constraintEqualToConstant:cardWidth],

        // 标题
        [titleLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:30],
        [titleLabel.centerXAnchor constraintEqualToAnchor:cardView.centerXAnchor],

        // 副标题
        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [subtitleLabel.centerXAnchor constraintEqualToAnchor:cardView.centerXAnchor],

        // 用户名输入框
        [self.usernameField.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:30],
        [self.usernameField.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [self.usernameField.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [self.usernameField.heightAnchor constraintEqualToConstant:44],

        // 分隔线1
        [divider1.topAnchor constraintEqualToAnchor:self.usernameField.bottomAnchor constant:0],
        [divider1.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [divider1.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [divider1.heightAnchor constraintEqualToConstant:0.5],

        // 密码容器
        [passwordContainer.topAnchor constraintEqualToAnchor:divider1.bottomAnchor constant:0],
        [passwordContainer.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [passwordContainer.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [passwordContainer.heightAnchor constraintEqualToConstant:44],

        // 密码输入框
        [self.passwordField.leadingAnchor constraintEqualToAnchor:passwordContainer.leadingAnchor],
        [self.passwordField.centerYAnchor constraintEqualToAnchor:passwordContainer.centerYAnchor],
        [self.passwordField.heightAnchor constraintEqualToConstant:44],

        // 切换按钮
        [self.togglePwdButton.trailingAnchor constraintEqualToAnchor:passwordContainer.trailingAnchor],
        [self.togglePwdButton.centerYAnchor constraintEqualToAnchor:passwordContainer.centerYAnchor],
        [self.togglePwdButton.widthAnchor constraintEqualToConstant:40],
        [self.togglePwdButton.heightAnchor constraintEqualToConstant:40],
        [self.passwordField.trailingAnchor constraintEqualToAnchor:self.togglePwdButton.leadingAnchor],

        // 分隔线2
        [divider2.topAnchor constraintEqualToAnchor:passwordContainer.bottomAnchor constant:0],
        [divider2.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [divider2.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [divider2.heightAnchor constraintEqualToConstant:0.5],

        // 登录按钮
        [self.loginButton.topAnchor constraintEqualToAnchor:divider2.bottomAnchor constant:30],
        [self.loginButton.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [self.loginButton.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [self.loginButton.heightAnchor constraintEqualToConstant:48],
        [self.loginButton.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-30],

        // 加载指示器
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.loginButton.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.loginButton.centerYAnchor],
    ]];
}

- (UITextField *)createTextFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.font = [UIFont systemFontOfSize:16];
    field.translatesAutoresizingMaskIntoConstraints = NO;
    return field;
}

- (UIView *)createDivider {
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [UIColor groupTableViewBackgroundColor];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    return divider;
}

- (void)togglePasswordVisibility {
    self.passwordVisible = !self.passwordVisible;
    self.passwordField.secureTextEntry = !self.passwordVisible;
    NSString *imageName = self.passwordVisible ? @"eye" : @"eye.slash";
    [self.togglePwdButton setImage:[UIImage systemImageNamed:imageName] forState:UIControlStateNormal];
}

- (void)loginTapped {
    NSString *username = self.usernameField.text ?: @"";
    NSString *password = self.passwordField.text ?: @"";

    if (username.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入用户名"];
        return;
    }
    if (password.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入密码"];
        return;
    }

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

    // 允许自签名证书
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
            if (![json isKindOfClass:[NSDictionary class]]) {
                [self showAlertWithTitle:@"错误" message:@"登录失败"];
                return;
            }

            NSInteger code = [json[@"code"] integerValue];
            NSString *token = json[@"token"];
            NSString *msg = json[@"msg"] ?: @"登录失败";

            if (code == 200 && token.length > 0) {
                [[AuthManager sharedInstance] saveLoginWithToken:token username:username];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self showAlertWithTitle:@"提示" message:msg];
            }
        });
    }];
    [task resume];
}

- (void)setLoading:(BOOL)loading {
    self.isLoading = loading;
    self.usernameField.enabled = !loading;
    self.passwordField.enabled = !loading;
    self.loginButton.enabled = !loading;

    if (loading) {
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden = NO;
        [self.loginButton setTitle:@"" forState:UIControlStateNormal];
        self.loginButton.backgroundColor = [UIColor colorWithRed:0.38 green:0.0 blue:0.93 alpha:0.6];
    } else {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        [self.loginButton setTitle:@"登 录" forState:UIControlStateNormal];
        self.loginButton.backgroundColor = [UIColor colorWithRed:0.38 green:0.0 blue:0.93 alpha:1.0];
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - NSURLSessionDelegate (证书校验)

/**
 * Debug 模式：信任所有证书（方便 Charles/Fiddler 抓包）
 * Release 模式：仅信任内置的自签名 server_cert.pem
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    if (![challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        return;
    }

    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;

#ifdef DEBUG
    // Debug 模式：直接信任服务器证书
    NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
#else
    // Release 模式：校验内置自签名证书
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

    // 将内置证书设置为锚点证书
    SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)@[ (__bridge id)pinnedCert ]);
    SecTrustSetAnchorCertificatesOnly(serverTrust, true);

    // 评估信任
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
