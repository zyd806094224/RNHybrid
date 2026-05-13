#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 登录态管理器
 * 使用 NSUserDefaults 持久化存储 token/username，对标 Android AuthManager.kt
 */
@interface AuthManager : NSObject

+ (instancetype)sharedInstance;

- (void)saveLoginWithToken:(NSString *)token username:(NSString *)username;
- (NSString *)getToken;
- (NSString *)getUsername;
- (BOOL)isLoggedIn;
- (void)logout;

@end

NS_ASSUME_NONNULL_END
