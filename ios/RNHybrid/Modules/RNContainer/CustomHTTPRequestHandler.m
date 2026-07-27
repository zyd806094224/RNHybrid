#import "CustomHTTPRequestHandler.h"
#import <React/RCTBridge.h>
#import <Security/Security.h>

@interface CustomHTTPRequestHandler () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary *> *tasks;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) BOOL isValid;

@end

@implementation CustomHTTPRequestHandler

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

- (instancetype)init {
    if (self = [super init]) {
        _tasks = [NSMutableDictionary new];
        _lock = [NSLock new];
        _isValid = YES;

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30;
        config.timeoutIntervalForResource = 60;
        config.HTTPShouldSetCookies = YES;
        config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        config.HTTPShouldUsePipelining = YES;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return self;
}

#pragma mark - RCTURLRequestHandler

- (BOOL)canHandleRequest:(NSURLRequest *)request {
    return [@[@"http", @"https"] containsObject:request.URL.scheme.lowercaseString];
}

- (float)handlerPriority {
    return 10; // 高于默认的 RCTHTTPRequestHandler (9)
}

- (id)sendRequest:(NSURLRequest *)request
     withDelegate:(id<RCTURLRequestDelegate>)delegate {
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];

    NSDictionary *taskData = @{
        @"delegate": delegate,
        @"request": request,
    };

    [_lock lock];
    _tasks[@(task.taskIdentifier)] = [taskData mutableCopy];
    [_lock unlock];

    [task resume];
    return task;
}

- (void)cancelRequest:(id)requestToken {
    if ([requestToken isKindOfClass:[NSURLSessionDataTask class]]) {
        NSURLSessionDataTask *task = (NSURLSessionDataTask *)requestToken;
        [task cancel];

        [_lock lock];
        [_tasks removeObjectForKey:@(task.taskIdentifier)];
        [_lock unlock];
    }
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    _isValid = NO;
    [_session invalidateAndCancel];
    [_lock lock];
    [_tasks removeAllObjects];
    [_lock unlock];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSDictionary *taskData = [self taskDataForTask:dataTask];
    id<RCTURLRequestDelegate> delegate = taskData[@"delegate"];

    if (delegate && _isValid) {
        [delegate URLRequest:dataTask didReceiveResponse:response];
    }

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSDictionary *taskData = [self taskDataForTask:dataTask];
    id<RCTURLRequestDelegate> delegate = taskData[@"delegate"];

    if (delegate && _isValid) {
        [delegate URLRequest:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    NSDictionary *taskData = [self taskDataForTask:task];
    id<RCTURLRequestDelegate> delegate = taskData[@"delegate"];

    if (delegate && _isValid) {
        if (error) {
            [delegate URLRequest:task didCompleteWithError:error];
        } else {
            [delegate URLRequest:task didCompleteWithError:nil];
        }
    }

    [_lock lock];
    [_tasks removeObjectForKey:@(task.taskIdentifier)];
    [_lock unlock];
}

#pragma mark - NSURLSessionDelegate (证书校验)

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {

    if (![challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        return;
    }

    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    if (!serverTrust) {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        return;
    }

#ifdef DEBUG
    // Debug 模式保留抓包能力。
    NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
#else
    // 仅为当前自签名证书服务启用证书固定，其他 HTTPS 保持系统默认校验。
    if (![challenge.protectionSpace.host isEqualToString:@"106.15.7.132"]) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        return;
    }

    if ([self validateServerTrust:serverTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        NSLog(@"[SSL] RN 网络请求证书校验失败，拒绝连接: %@",
              challenge.protectionSpace.host);
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
#endif
}

#pragma mark - 证书校验

- (BOOL)validateServerTrust:(SecTrustRef)serverTrust {
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"server_cert" ofType:@"der"];
    NSData *pinnedCertData = certPath ? [NSData dataWithContentsOfFile:certPath] : nil;
    SecCertificateRef serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0);
    CFDataRef serverCertData = serverCert ? SecCertificateCopyData(serverCert) : NULL;
    BOOL certificateMatches = pinnedCertData && serverCertData &&
        [pinnedCertData isEqualToData:(__bridge NSData *)serverCertData];

    if (serverCertData) {
        CFRelease(serverCertData);
    }

    return certificateMatches;
}

#pragma mark - Helper

- (NSDictionary *)taskDataForTask:(NSURLSessionTask *)task {
    [_lock lock];
    NSDictionary *data = _tasks[@(task.taskIdentifier)];
    [_lock unlock];
    return data;
}

@end
