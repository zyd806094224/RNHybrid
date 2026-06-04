#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 登录态管理器
 * token 使用 Keychain 安全存储，username 使用 NSUserDefaults 持久化
 */
@interface AuthManager : NSObject

+ (instancetype)sharedInstance;

- (void)prepareForLaunch;
- (BOOL)saveLoginWithToken:(NSString *)token username:(NSString *)username;
- (NSString *)getToken;
- (NSString *)getUsername;
- (BOOL)isLoggedIn;
- (void)logout;

@end

NS_ASSUME_NONNULL_END
