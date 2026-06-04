#import "SplashViewController.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

static UIColor *QXSplashColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@interface QXSplashGradientView : UIView

@property (nonatomic, copy) NSArray<UIColor *> *gradientColors;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *locations;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@end

@implementation QXSplashGradientView

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (void)setGradientColors:(NSArray<UIColor *> *)gradientColors {
    _gradientColors = [gradientColors copy];

    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:gradientColors.count];
    for (UIColor *color in gradientColors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }

    ((CAGradientLayer *)self.layer).colors = cgColors;
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

@interface SplashViewController ()

@property (nonatomic, assign) BOOL hasScheduledTransition;
@property (nonatomic, assign) BOOL hasTransitioned;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = QXSplashColor(0xFFFFFF);
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.hasScheduledTransition) {
        return;
    }
    self.hasScheduledTransition = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self transitionToMainViewController];
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)setupUI {
    QXSplashGradientView *backgroundView = [[QXSplashGradientView alloc] init];
    backgroundView.gradientColors = @[QXSplashColor(0xE4FFF8), QXSplashColor(0xF6FFFC), QXSplashColor(0xFFFFFF)];
    backgroundView.locations = @[@0, @0.52, @1];
    backgroundView.startPoint = CGPointMake(0.5, 0);
    backgroundView.endPoint = CGPointMake(0.5, 1);
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backgroundView];

    UIView *logoPlate = [[UIView alloc] init];
    logoPlate.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.96];
    logoPlate.layer.cornerRadius = 36;
    logoPlate.layer.borderWidth = 1.0 / UIScreen.mainScreen.scale;
    logoPlate.layer.borderColor = QXSplashColor(0xDDF4EF).CGColor;
    logoPlate.layer.shadowColor = UIColor.blackColor.CGColor;
    logoPlate.layer.shadowOpacity = 0.12;
    logoPlate.layer.shadowOffset = CGSizeMake(0, 10);
    logoPlate.layer.shadowRadius = 18;
    logoPlate.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:logoPlate];

    UIImageView *splashImageView = [[UIImageView alloc] initWithImage:[self splashImage]];
    splashImageView.contentMode = UIViewContentModeScaleAspectFit;
    splashImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [logoPlate addSubview:splashImageView];

    UILabel *appNameLabel = [[UILabel alloc] init];
    appNameLabel.text = @"轻匣";
    appNameLabel.font = [UIFont systemFontOfSize:33 weight:UIFontWeightBold];
    appNameLabel.textColor = QXSplashColor(0x12363A);
    appNameLabel.textAlignment = NSTextAlignmentCenter;
    appNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:appNameLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"安全收纳账号与备忘";
    subtitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    subtitleLabel.textColor = QXSplashColor(0x5F777A);
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subtitleLabel];

    UIView *progressTrack = [[UIView alloc] init];
    progressTrack.backgroundColor = QXSplashColor(0xDDF3EF);
    progressTrack.layer.cornerRadius = 3;
    progressTrack.clipsToBounds = YES;
    progressTrack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:progressTrack];

    QXSplashGradientView *progressFill = [[QXSplashGradientView alloc] init];
    progressFill.gradientColors = @[QXSplashColor(0x51E8D5), QXSplashColor(0x10B8A7)];
    progressFill.startPoint = CGPointMake(0, 0.5);
    progressFill.endPoint = CGPointMake(1, 0.5);
    progressFill.layer.cornerRadius = 3;
    progressFill.clipsToBounds = YES;
    progressFill.translatesAutoresizingMaskIntoConstraints = NO;
    [progressTrack addSubview:progressFill];

    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.text = @"Secure notes, lighter life";
    footerLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    footerLabel.textColor = QXSplashColor(0x8AA0A2);
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:footerLabel];

    [NSLayoutConstraint activateConstraints:@[
        [backgroundView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [backgroundView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [backgroundView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [backgroundView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [logoPlate.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [logoPlate.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-62],
        [logoPlate.widthAnchor constraintEqualToConstant:236],
        [logoPlate.heightAnchor constraintEqualToConstant:236],

        [splashImageView.topAnchor constraintEqualToAnchor:logoPlate.topAnchor constant:10],
        [splashImageView.leadingAnchor constraintEqualToAnchor:logoPlate.leadingAnchor constant:10],
        [splashImageView.trailingAnchor constraintEqualToAnchor:logoPlate.trailingAnchor constant:-10],
        [splashImageView.bottomAnchor constraintEqualToAnchor:logoPlate.bottomAnchor constant:-10],

        [appNameLabel.topAnchor constraintEqualToAnchor:logoPlate.bottomAnchor constant:28],
        [appNameLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [subtitleLabel.topAnchor constraintEqualToAnchor:appNameLabel.bottomAnchor constant:8],
        [subtitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [subtitleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:28],
        [subtitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-28],

        [progressTrack.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:32],
        [progressTrack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [progressTrack.widthAnchor constraintEqualToConstant:132],
        [progressTrack.heightAnchor constraintEqualToConstant:6],

        [progressFill.topAnchor constraintEqualToAnchor:progressTrack.topAnchor],
        [progressFill.leadingAnchor constraintEqualToAnchor:progressTrack.leadingAnchor],
        [progressFill.bottomAnchor constraintEqualToAnchor:progressTrack.bottomAnchor],
        [progressFill.widthAnchor constraintEqualToConstant:86],

        [footerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [footerLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-34],
    ]];
}

- (UIImage *)splashImage {
    UIImage *image = [UIImage imageNamed:@"QingxiaSplash"];
    if (image) {
        return image;
    }

    image = [UIImage imageNamed:@"QingxiaLauncher"];
    if (image) {
        return image;
    }

    if (@available(iOS 13.0, *)) {
        return [UIImage systemImageNamed:@"archivebox.fill"];
    }
    return nil;
}

- (void)transitionToMainViewController {
    if (self.hasTransitioned) {
        return;
    }
    self.hasTransitioned = YES;

    MainViewController *mainVC = [[MainViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    navController.navigationBarHidden = YES;
    navController.modalPresentationStyle = UIModalPresentationFullScreen;

    UIWindow *window = self.view.window ?: [self activeWindow];
    if (!window) {
        return;
    }

    [UIView transitionWithView:window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
        window.rootViewController = navController;
    } completion:nil];
}

- (UIWindow *)activeWindow {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    return UIApplication.sharedApplication.windows.firstObject;
}

@end
