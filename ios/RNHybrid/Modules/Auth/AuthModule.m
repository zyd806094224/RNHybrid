#import "AuthModule.h"
#import "AuthManager.h"

@implementation AuthModule

RCT_EXPORT_MODULE(AuthModule);

static BOOL _isHandling = NO;
static void (^_tokenExpiredCallback)(void) = nil;

+ (BOOL)isHandling {
    return _isHandling;
}

+ (void)setIsHandling:(BOOL)handling {
    _isHandling = handling;
}

+ (void (^)(void))tokenExpiredCallback {
    return _tokenExpiredCallback;
}

+ (void)setTokenExpiredCallback:(void (^)(void))callback {
    _tokenExpiredCallback = [callback copy];
}

RCT_EXPORT_METHOD(onTokenExpired) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isHandling) return;
        _isHandling = YES;

        // 清除登录态
        [[AuthManager sharedInstance] logout];

        // 执行回调（关闭 RN 页面 → 跳转登录页）
        if (_tokenExpiredCallback) {
            _tokenExpiredCallback();
        }
    });
}

@end
