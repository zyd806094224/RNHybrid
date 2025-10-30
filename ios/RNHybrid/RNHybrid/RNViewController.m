#import "RNViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootViewDelegate.h>

/**
 * RNViewController
 * 这是一个独立的React Native容器页面，类似于Android中的Activity
 * 负责加载和显示React Native内容
 */
@interface RNViewController () <RCTRootViewDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) RCTRootView *reactRootView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, assign) BOOL isBundleDownloaded;
@property (nonatomic, assign) BOOL hasTriedToInitializeReactNative;
@property (nonatomic, assign) BOOL isViewFirstTimeAppeared;
@property (nonatomic, assign) BOOL didShowErrorMessage;

@end

@implementation RNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"RN页面";
    
    NSLog(@"RNViewController viewDidLoad");
    
    // 隐藏导航栏以实现全屏效果
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // 添加加载指示器和标签
    [self setupLoadingUI];
    
    // 初始化下载状态
    self.isBundleDownloaded = NO;
    self.hasTriedToInitializeReactNative = NO;
    self.isViewFirstTimeAppeared = NO;
    self.didShowErrorMessage = NO;

#if DEBUG
    // DEBUG模式下，直接从Metro开发服务器加载
    [self initializeReactNativeWithBundle:nil];
#else
    // RELEASE模式下，从网络下载bundle文件
    [self downloadBundleFile];
#endif

}

- (void)setupLoadingUI {
    // 创建加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.center = self.view.center;
    [self.view addSubview:self.loadingIndicator];
    
    // 创建加载标签
    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.text = @"正在加载中...";
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    self.loadingLabel.font = [UIFont systemFontOfSize:16];
    self.loadingLabel.textColor = [UIColor blackColor];
    self.loadingLabel.frame = CGRectMake(0, self.loadingIndicator.frame.origin.y + 40, self.view.frame.size.width, 20);
    
    [self.view addSubview:self.loadingLabel];
}

- (void)downloadBundleFile {
    // 显示加载UI
    [self.loadingIndicator startAnimating];
    
    // 远程bundle文件URL（请替换为实际的URL）
    NSURL *bundleURL = [NSURL URLWithString:@"http://106.15.7.132:888/download/index.ios.bundle"];
    
    // 获取文档目录路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"index.ios.bundle"];
    
    NSLog(@"Downloading bundle to path: %@", filePath);
    
    // 检查本地是否已有有效的bundle文件
    if ([self isValidBundleFileAtPath:filePath]) {
        NSLog(@"Using existing local bundle file");
        [self.loadingIndicator stopAnimating];
        [self initializeReactNativeWithBundle:[NSURL fileURLWithPath:filePath]];
        return;
    }
    
    // 检查URL是否有效
    if (!bundleURL || bundleURL.host.length == 0) {
        NSLog(@"Invalid bundle URL, falling back to dev server");
        [self initializeReactNativeWithBundle:nil];
        return;
    }
    
    // 创建下载任务
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:bundleURL];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    
    // 保存文件路径到任务描述中，以便在代理方法中使用
    downloadTask.taskDescription = filePath;
    
    [downloadTask resume];
}

- (BOOL)isValidBundleFileAtPath:(NSString *)filePath {
    if (!filePath || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"Bundle file does not exist at path: %@", filePath);
        return NO;
    }
    
    // 检查文件大小
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if (fileAttributes) {
        NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
        long long size = [fileSize longLongValue];
        NSLog(@"Bundle file size: %lld bytes", size);
        if (size < 100) { // 文件过小认为无效
            NSLog(@"Bundle file is too small, considered invalid");
            return NO;
        }
    }
    
    return YES;
}

- (void)showLoadErrorUI {
    // 确保在主线程执行UI更新
    dispatch_async(dispatch_get_main_queue(), ^{
        // 停止并隐藏加载UI
        [self.loadingIndicator stopAnimating];
        [self.loadingIndicator setHidden:YES];
        [self.loadingLabel setHidden:YES];

        // 创建错误标签
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.text = @"页面加载失败，请稍后重试。";
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.numberOfLines = 0;
        errorLabel.textColor = [UIColor redColor];
        errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:errorLabel];

        // 创建返回按钮
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        backButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:backButton];

        // 设置约束
        [NSLayoutConstraint activateConstraints:@[
            [errorLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [errorLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            [errorLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20],
            [errorLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20],

            [backButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [backButton.topAnchor constraintEqualToAnchor:errorLabel.bottomAnchor constant:20]
        ]];
    });
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    // 获取保存的文件路径
    NSString *filePath = downloadTask.taskDescription;
    
    NSLog(@"Download finished, moving file to: %@", filePath);
    
    // 确保目标目录存在
    NSString *directory = [filePath stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    
    // 删除已存在的文件
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    // 将下载的文件移动到目标位置
    NSError *error;
    BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&error];
    
    if (!moveSuccess || error) {
        if (error && [error isKindOfClass:[NSError class]]) {
            NSLog(@"Error moving file: %@", error.localizedDescription);
        } else {
            NSLog(@"Unknown error moving file");
        }
        // 如果下载失败，使用默认方式加载
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeReactNativeWithBundle:nil];
        });
    } else {
        NSLog(@"Successfully downloaded bundle to: %@", filePath);
        self.isBundleDownloaded = YES;
        // 验证下载的文件
        if ([self isValidBundleFileAtPath:filePath]) {
            // 下载成功，使用下载的bundle文件
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initializeReactNativeWithBundle:[NSURL fileURLWithPath:filePath]];
            });
        } else {
            NSLog(@"Downloaded bundle file is invalid");
            // 文件无效，使用默认方式加载
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initializeReactNativeWithBundle:nil];
            });
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        if ([error isKindOfClass:[NSError class]]) {
            NSLog(@"Download completed with error: %@", error.localizedDescription);
            
            // 处理连接失败的情况
            if (error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorTimedOut) {
                NSLog(@"Cannot connect to server. Falling back to local bundle.");
            }
        } else {
            NSLog(@"Download completed with unknown error");
        }
        
        // 回退到本地bundle或开发服务器
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeReactNativeWithBundle:nil];
        });
    } else {
        // 下载成功但还没有处理的情况
        if (![self isBundleDownloaded] && ![self hasTriedToInitializeReactNative]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initializeReactNativeWithBundle:nil];
            });
        }
    }
}

- (void)initializeReactNativeWithBundle:(NSURL *)bundleURL {
    // 防止重复初始化
    if (self.hasTriedToInitializeReactNative) {
        return;
    }
    self.hasTriedToInitializeReactNative = YES;
    
    NSURL *finalBundleURL;

#if DEBUG
    NSLog(@"DEBUG mode: Using Metro dev server.");
    finalBundleURL = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
    NSLog(@"RELEASE mode: Using downloaded bundle.");
    finalBundleURL = bundleURL;
#endif
    
    NSLog(@"Initializing React Native with bundle URL: %@", bundleURL);
    
    // 停止并隐藏加载指示器
    [self.loadingIndicator stopAnimating];
    [self.loadingIndicator removeFromSuperview];
    [self.loadingLabel removeFromSuperview];
    
    // 防御性检查，确保bundleURL不为空
    if (finalBundleURL == nil) {
        NSLog(@"Error: Bundle URL is nil, cannot initialize React Native");
        
        // 避免重复显示错误
        if (self.didShowErrorMessage) {
            return;
        }
        self.didShowErrorMessage = YES;
        
        [self showLoadErrorUI];
        return;
    }
    
    // 创建React Native根视图
    @try {
        //透传参数
        NSDictionary *initialParams = @{
                @"param1": @"ios"
            };
        // 强制走本地服务器  zyd
        finalBundleURL = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
        self.reactRootView = [[RCTRootView alloc] initWithBundleURL:finalBundleURL
                                                            moduleName:@"RNHybrid"
                                                     initialProperties:initialParams
                                                         launchOptions:nil];
        
        self.reactRootView.delegate = self;
        
        [self.view addSubview:self.reactRootView];
        
        // 设置约束
        self.reactRootView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.reactRootView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.reactRootView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [self.reactRootView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [self.reactRootView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
        
        // 添加返回按钮
        [self addBackButton];
    } @catch (NSException *exception) {
        NSLog(@"Exception occurred while initializing React Native: %@", exception.reason);

        // 避免重复显示错误
        if (self.didShowErrorMessage) {
            return;
        }
        self.didShowErrorMessage = YES;

        [self showLoadErrorUI];
    }
}

- (void)addBackButton {
    // 创建返回按钮（在React Native视图之后添加，确保在最上层）
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
}

- (void)goBack {
    // 如果RN页面是被push进来的，则pop返回
    if (self.navigationController && self.navigationController.viewControllers.count > 1 && self.navigationController.topViewController == self) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    // 如果RN页面（或其所在的导航控制器）是被present出来的，则dismiss返回
    else if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - RCTRootViewDelegate

- (void)rootViewDidChangeIntrinsicSize:(RCTRootView *)rootView {
    // 可选：处理根视图大小变化
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 标记视图已经出现过
    if (!self.isViewFirstTimeAppeared) {
        self.isViewFirstTimeAppeared = YES;
        
        // 可以在这里处理一些需要在视图完全显示后才执行的逻辑
    }
}

@end
