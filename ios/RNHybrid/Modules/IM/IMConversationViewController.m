#import "IMConversationViewController.h"
#import "../Auth/AuthManager.h"
#import <Shared/Shared.h>

static UIColor *IMColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

static UIView *IMInstallHeader(UIViewController *controller,
                               NSString *title,
                               SEL backAction,
                               NSString *rightTitle,
                               SEL rightAction) {
    UIView *statusFill = [[UIView alloc] init];
    statusFill.backgroundColor = IMColor(0x12BFA5);
    statusFill.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view addSubview:statusFill];

    UIView *header = [[UIView alloc] init];
    header.backgroundColor = IMColor(0x12BFA5);
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [controller.view addSubview:header];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"‹" forState:UIControlStateNormal];
    [backButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightLight];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:controller action:backAction forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:backButton];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:titleLabel];

    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightButton setTitle:rightTitle ?: @"" forState:UIControlStateNormal];
    [rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    rightButton.hidden = rightTitle.length == 0;
    if (rightAction) {
        [rightButton addTarget:controller action:rightAction forControlEvents:UIControlEventTouchUpInside];
    }
    [header addSubview:rightButton];

    [NSLayoutConstraint activateConstraints:@[
        [statusFill.topAnchor constraintEqualToAnchor:controller.view.topAnchor],
        [statusFill.leadingAnchor constraintEqualToAnchor:controller.view.leadingAnchor],
        [statusFill.trailingAnchor constraintEqualToAnchor:controller.view.trailingAnchor],
        [statusFill.bottomAnchor constraintEqualToAnchor:controller.view.safeAreaLayoutGuide.topAnchor],

        [header.topAnchor constraintEqualToAnchor:controller.view.safeAreaLayoutGuide.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:controller.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:controller.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:52],

        [backButton.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:8],
        [backButton.centerYAnchor constraintEqualToAnchor:header.centerYAnchor constant:-1],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44],

        [rightButton.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-12],
        [rightButton.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [rightButton.widthAnchor constraintGreaterThanOrEqualToConstant:64],
        [rightButton.heightAnchor constraintEqualToConstant:44],

        [titleLabel.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:backButton.trailingAnchor constant:4],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:rightButton.leadingAnchor constant:-4],
    ]];

    [statusFill release];
    [titleLabel release];
    return [header autorelease];
}

static UILabel *IMCreateEmptyLabel(NSString *text) {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = IMColor(0x98A2B3);
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return [label autorelease];
}

static NSString *IMListResultError(SharedChatUseCaseListResult *result, NSError *error) {
    if (error.localizedDescription.length > 0) {
        return error.localizedDescription;
    }
    if ([result isKindOfClass:SharedChatUseCaseListResultFail.class]) {
        return ((SharedChatUseCaseListResultFail *)result).errMsg;
    }
    return @"请求失败，请稍后重试";
}

@class IMChatViewController;

@interface IMUserListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithChatUseCase:(SharedChatUseCase *)chatUseCase;

@end

@interface IMChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

- (instancetype)initWithChatUseCase:(SharedChatUseCase *)chatUseCase
                     conversationId:(int64_t)conversationId
                           targetId:(int64_t)targetId
                         targetName:(NSString *)targetName;

@end

@interface IMConversationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) SharedChatUseCase *chatUseCase;
@property (nonatomic, retain) NSArray<SharedImConversation *> *conversations;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL socketStarted;

@end

@implementation IMConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    SharedChatRepository *repository = [[[SharedChatRepository alloc] init] autorelease];
    self.chatUseCase = [[[SharedChatUseCase alloc] initWithChatRepository:repository] autorelease];
    self.conversations = @[];

    [self setupUI];
    [self startSocketIfNeeded];
    [self loadConversations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isViewLoaded) {
        [self loadConversations];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self.chatUseCase stop];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setupUI {
    UIView *header = IMInstallHeader(self,
                                     @"消息",
                                     @selector(backTapped),
                                     @"发起聊天",
                                     @selector(newChatTapped));

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.separatorColor = IMColor(0xEAECF0);
    tableView.rowHeight = 76;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = IMColor(0x12BFA5);
    [refreshControl addTarget:self action:@selector(loadConversations) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;
    self.refreshControl = refreshControl;
    [refreshControl release];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)startSocketIfNeeded {
    if (self.socketStarted) {
        return;
    }
    NSString *token = [[AuthManager sharedInstance] getToken];
    if (token.length == 0) {
        return;
    }
    self.socketStarted = YES;
    [self.chatUseCase startToken:token completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"[IM] WebSocket 启动失败: %@", error.localizedDescription);
        }
    }];
}

- (void)loadConversations {
    if (self.loading) {
        [self.refreshControl endRefreshing];
        return;
    }
    self.loading = YES;

    [self.chatUseCase getConversationsWithCompletionHandler:^(SharedChatUseCaseListResult *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loading = NO;
            [self.refreshControl endRefreshing];

            if ([result isKindOfClass:SharedChatUseCaseListResultSuccess.class]) {
                NSArray *data = ((SharedChatUseCaseListResultSuccess *)result).data ?: @[];
                self.conversations = data;
                self.tableView.backgroundView = data.count == 0 ? IMCreateEmptyLabel(@"暂无会话\n点击右上角“发起聊天”") : nil;
            } else {
                self.conversations = @[];
                NSString *message = IMListResultError(result, error);
                self.tableView.backgroundView = IMCreateEmptyLabel([NSString stringWithFormat:@"加载失败\n%@", message]);
            }
            [self.tableView reloadData];
        });
    }];
}

- (void)backTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)newChatTapped {
    IMUserListViewController *controller = [[IMUserListViewController alloc] initWithChatUseCase:self.chatUseCase];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"IMConversationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        cell.textLabel.textColor = IMColor(0x223033);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = IMColor(0x98A2B3);
        cell.detailTextLabel.numberOfLines = 1;
        cell.imageView.tintColor = IMColor(0x12BFA5);
    }

    SharedImConversation *conversation = self.conversations[indexPath.row];
    cell.textLabel.text = conversation.targetName.length > 0
        ? conversation.targetName
        : [NSString stringWithFormat:@"用户%lld", conversation.targetId];

    NSString *summary = conversation.lastMsgContent.length > 0 ? conversation.lastMsgContent : @"暂无消息";
    if (conversation.lastMsgTime.length > 0) {
        summary = [NSString stringWithFormat:@"%@  ·  %@", summary, conversation.lastMsgTime];
    }
    cell.detailTextLabel.text = summary;

    if (@available(iOS 13.0, *)) {
        cell.imageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"];
    } else {
        cell.imageView.image = nil;
    }

    if (conversation.unreadCount > 0) {
        UILabel *badge = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, 24)] autorelease];
        badge.text = conversation.unreadCount > 99
            ? @"99+"
            : [NSString stringWithFormat:@"%d", conversation.unreadCount];
        badge.textColor = UIColor.whiteColor;
        badge.backgroundColor = IMColor(0xF04438);
        badge.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
        badge.textAlignment = NSTextAlignmentCenter;
        badge.layer.cornerRadius = 12;
        badge.clipsToBounds = YES;
        cell.accessoryView = badge;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SharedImConversation *conversation = self.conversations[indexPath.row];
    IMChatViewController *controller = [[IMChatViewController alloc]
        initWithChatUseCase:self.chatUseCase
        conversationId:conversation.conversationId
        targetId:conversation.targetId
        targetName:conversation.targetName];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)dealloc {
    [_chatUseCase release];
    [_conversations release];
    [_tableView release];
    [_refreshControl release];
    [super dealloc];
}

@end

#pragma mark - 联系人列表

@interface IMUserListViewController ()

@property (nonatomic, retain) SharedChatUseCase *chatUseCase;
@property (nonatomic, retain) NSArray<SharedSimpleUser *> *users;
@property (nonatomic, retain) UITableView *tableView;

@end

@implementation IMUserListViewController

- (instancetype)initWithChatUseCase:(SharedChatUseCase *)chatUseCase {
    self = [super init];
    if (self) {
        _chatUseCase = [chatUseCase retain];
        _users = [@[] retain];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    UIView *header = IMInstallHeader(self, @"选择联系人", @selector(backTapped), nil, NULL);

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.rowHeight = 66;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorColor = IMColor(0xEAECF0);
    tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    self.tableView.backgroundView = IMCreateEmptyLabel(@"联系人加载中…");
    [self loadUsers];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadUsers {
    [self.chatUseCase getChatUsersWithCompletionHandler:^(SharedChatUseCaseListResult *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result isKindOfClass:SharedChatUseCaseListResultSuccess.class]) {
                NSArray *data = ((SharedChatUseCaseListResultSuccess *)result).data ?: @[];
                self.users = data;
                self.tableView.backgroundView = data.count == 0 ? IMCreateEmptyLabel(@"暂无可聊天联系人") : nil;
            } else {
                self.users = @[];
                NSString *message = IMListResultError(result, error);
                self.tableView.backgroundView = IMCreateEmptyLabel([NSString stringWithFormat:@"加载失败\n%@", message]);
            }
            [self.tableView reloadData];
        });
    }];
}

- (void)backTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"IMUserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        cell.textLabel.textColor = IMColor(0x223033);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = IMColor(0x98A2B3);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.tintColor = IMColor(0x12BFA5);
    }

    SharedSimpleUser *user = self.users[indexPath.row];
    cell.textLabel.text = user.nickName.length > 0 ? user.nickName : user.userName;
    cell.detailTextLabel.text = user.userName.length > 0 ? user.userName : [NSString stringWithFormat:@"用户%lld", user.userId];
    if (@available(iOS 13.0, *)) {
        cell.imageView.image = [UIImage systemImageNamed:@"person.crop.circle"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SharedSimpleUser *user = self.users[indexPath.row];
    NSString *name = user.nickName.length > 0 ? user.nickName : user.userName;
    IMChatViewController *controller = [[IMChatViewController alloc]
        initWithChatUseCase:self.chatUseCase
        conversationId:0
        targetId:user.userId
        targetName:name];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)dealloc {
    [_chatUseCase release];
    [_users release];
    [_tableView release];
    [super dealloc];
}

@end

#pragma mark - 聊天页

@interface IMBubbleLabel : UILabel
@end

@implementation IMBubbleLabel

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(10, 14, 10, 14))];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + 28, size.height + 20);
}

@end

@interface IMChatViewController ()

@property (nonatomic, retain) SharedChatUseCase *chatUseCase;
@property (nonatomic, assign) int64_t conversationId;
@property (nonatomic, assign) int64_t targetId;
@property (nonatomic, copy) NSString *targetName;
@property (nonatomic, retain) NSArray<SharedImMessage *> *messages;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UITextField *inputField;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) NSLayoutConstraint *inputBottomConstraint;
@property (nonatomic, retain) NSTimer *pollTimer;
@property (nonatomic, assign) BOOL loadingHistory;

@end

@implementation IMChatViewController

- (instancetype)initWithChatUseCase:(SharedChatUseCase *)chatUseCase
                     conversationId:(int64_t)conversationId
                           targetId:(int64_t)targetId
                         targetName:(NSString *)targetName {
    self = [super init];
    if (self) {
        _chatUseCase = [chatUseCase retain];
        _conversationId = conversationId;
        _targetId = targetId;
        _targetName = [targetName copy];
        _messages = [@[] retain];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = IMColor(0xF7FAFC);
    [self setupUI];
    [self observeKeyboard];
    [self ensureConversationAndLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                      target:self
                                                    selector:@selector(loadHistory)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pollTimer invalidate];
    self.pollTimer = nil;
    [self.view endEditing:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setupUI {
    NSString *title = self.targetName.length > 0
        ? self.targetName
        : [NSString stringWithFormat:@"用户%lld", self.targetId];
    UIView *header = IMInstallHeader(self, title, @selector(backTapped), nil, NULL);

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = IMColor(0xF7FAFC);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    tableView.estimatedRowHeight = 56;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0);
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];

    UIView *inputBar = [[UIView alloc] init];
    inputBar.backgroundColor = UIColor.whiteColor;
    inputBar.layer.borderWidth = 1.0 / UIScreen.mainScreen.scale;
    inputBar.layer.borderColor = IMColor(0xEAECF0).CGColor;
    inputBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:inputBar];

    UITextField *inputField = [[UITextField alloc] init];
    inputField.placeholder = @"输入消息…";
    inputField.font = [UIFont systemFontOfSize:15];
    inputField.textColor = IMColor(0x223033);
    inputField.backgroundColor = IMColor(0xF2F4F7);
    inputField.layer.cornerRadius = 10;
    inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputField.returnKeyType = UIReturnKeySend;
    inputField.delegate = self;
    inputField.leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)] autorelease];
    inputField.leftViewMode = UITextFieldViewModeAlways;
    inputField.translatesAutoresizingMaskIntoConstraints = NO;
    [inputBar addSubview:inputField];
    self.inputField = inputField;
    [inputField release];

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    sendButton.backgroundColor = IMColor(0x12BFA5);
    sendButton.layer.cornerRadius = 10;
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendButton addTarget:self action:@selector(sendTapped) forControlEvents:UIControlEventTouchUpInside];
    [inputBar addSubview:sendButton];
    self.sendButton = sendButton;

    self.inputBottomConstraint = [inputBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:inputBar.topAnchor],

        [inputBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [inputBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.inputBottomConstraint,

        [self.inputField.topAnchor constraintEqualToAnchor:inputBar.topAnchor constant:8],
        [self.inputField.leadingAnchor constraintEqualToAnchor:inputBar.leadingAnchor constant:10],
        [self.inputField.bottomAnchor constraintEqualToAnchor:inputBar.bottomAnchor constant:-8],
        [self.inputField.heightAnchor constraintEqualToConstant:42],

        [self.sendButton.leadingAnchor constraintEqualToAnchor:self.inputField.trailingAnchor constant:8],
        [self.sendButton.trailingAnchor constraintEqualToAnchor:inputBar.trailingAnchor constant:-10],
        [self.sendButton.centerYAnchor constraintEqualToAnchor:self.inputField.centerYAnchor],
        [self.sendButton.widthAnchor constraintEqualToConstant:64],
        [self.sendButton.heightAnchor constraintEqualToConstant:42],
    ]];

    [inputBar release];
    self.tableView.backgroundView = IMCreateEmptyLabel(@"消息加载中…");
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)keyboardFrameChanged:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat overlap = MAX(0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(keyboardFrame));
    self.inputBottomConstraint.constant = -MAX(0, overlap - self.view.safeAreaInsets.bottom);

    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
        [self scrollToBottomAnimated:NO];
    } completion:nil];
}

- (void)ensureConversationAndLoad {
    if (self.conversationId > 0) {
        [self loadHistory];
        return;
    }

    [self.chatUseCase getOrCreateConversationTargetId:self.targetId completionHandler:^(SharedImConversation *conversation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (conversation) {
                self.conversationId = conversation.conversationId;
                [self loadHistory];
            } else {
                NSString *message = error.localizedDescription ?: @"创建会话失败";
                self.tableView.backgroundView = IMCreateEmptyLabel(message);
            }
        });
    }];
}

- (void)loadHistory {
    if (self.loadingHistory || self.conversationId <= 0) {
        return;
    }
    self.loadingHistory = YES;

    [self.chatUseCase loadHistoryConversationId:self.conversationId
                                      lastMsgId:nil
                              completionHandler:^(SharedChatUseCaseListResult *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingHistory = NO;
            if ([result isKindOfClass:SharedChatUseCaseListResultSuccess.class]) {
                NSArray *descending = ((SharedChatUseCaseListResultSuccess *)result).data ?: @[];
                self.messages = [[descending reverseObjectEnumerator] allObjects];
                self.tableView.backgroundView = self.messages.count == 0 ? IMCreateEmptyLabel(@"暂无消息，开始聊天吧") : nil;
                [self.tableView reloadData];
                [self scrollToBottomAnimated:NO];
            } else if (self.messages.count == 0) {
                self.tableView.backgroundView = IMCreateEmptyLabel(IMListResultError(result, error));
            }
        });
    }];
}

- (void)sendTapped {
    NSString *content = [self.inputField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (content.length == 0) {
        return;
    }
    if (self.conversationId <= 0) {
        [self ensureConversationAndLoad];
        return;
    }

    self.sendButton.enabled = NO;
    self.sendButton.alpha = 0.6;
    [self.chatUseCase sendMessageReceiverId:self.targetId
                                    msgType:1
                                    content:content
                          completionHandler:^(SharedChatUseCaseSendResult *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sendButton.enabled = YES;
            self.sendButton.alpha = 1.0;

            if ([result isKindOfClass:SharedChatUseCaseSendResultSuccess.class]) {
                self.inputField.text = @"";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    [self loadHistory];
                });
            } else {
                NSString *message = error.localizedDescription;
                if ([result isKindOfClass:SharedChatUseCaseSendResultFail.class]) {
                    message = ((SharedChatUseCaseSendResultFail *)result).errMsg;
                }
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发送失败"
                                                                               message:message ?: @"请检查网络连接后重试"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

- (void)backTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendTapped];
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SharedImMessage *message = self.messages[indexPath.row];
    BOOL incoming = message.senderId == self.targetId;
    NSString *identifier = incoming ? @"IMIncomingMessageCell" : @"IMOutgoingMessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.backgroundColor = UIColor.clearColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        IMBubbleLabel *bubble = [[IMBubbleLabel alloc] init];
        bubble.tag = 901;
        bubble.font = [UIFont systemFontOfSize:15];
        bubble.numberOfLines = 0;
        bubble.layer.cornerRadius = 12;
        bubble.clipsToBounds = YES;
        bubble.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:bubble];

        NSLayoutConstraint *widthConstraint = [bubble.widthAnchor constraintLessThanOrEqualToAnchor:cell.contentView.widthAnchor multiplier:0.76];
        if (incoming) {
            bubble.backgroundColor = UIColor.whiteColor;
            bubble.textColor = IMColor(0x344054);
            [NSLayoutConstraint activateConstraints:@[
                [bubble.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:14],
                [bubble.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:5],
                [bubble.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-5],
                widthConstraint,
            ]];
        } else {
            bubble.backgroundColor = IMColor(0x12BFA5);
            bubble.textColor = UIColor.whiteColor;
            [NSLayoutConstraint activateConstraints:@[
                [bubble.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-14],
                [bubble.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:5],
                [bubble.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-5],
                widthConstraint,
            ]];
        }
        [bubble release];
    }

    IMBubbleLabel *bubble = [cell.contentView viewWithTag:901];
    bubble.text = message.msgType == 2 ? @"[图片]" : message.content;
    return cell;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger count = self.messages.count;
    if (count == 0) {
        return;
    }
    NSIndexPath *last = [NSIndexPath indexPathForRow:count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_pollTimer invalidate];
    [_pollTimer release];
    [_chatUseCase release];
    [_targetName release];
    [_messages release];
    [_tableView release];
    [_inputField release];
    [_sendButton release];
    [_inputBottomConstraint release];
    [super dealloc];
}

@end
