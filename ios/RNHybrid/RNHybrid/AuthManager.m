#import "AuthManager.h"

static NSString * const kAuthTokenKey = @"auth_token";
static NSString * const kAuthUsernameKey = @"auth_username";

@implementation AuthManager

+ (instancetype)sharedInstance {
    static AuthManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AuthManager alloc] init];
    });
    return instance;
}

- (void)saveLoginWithToken:(NSString *)token username:(NSString *)username {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kAuthTokenKey];
    [defaults setObject:username forKey:kAuthUsernameKey];
    [defaults synchronize];
}

- (NSString *)getToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAuthTokenKey] ?: @"";
}

- (NSString *)getUsername {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAuthUsernameKey] ?: @"";
}

- (BOOL)isLoggedIn {
    return self.getToken.length > 0;
}

- (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAuthTokenKey];
    [defaults removeObjectForKey:kAuthUsernameKey];
    [defaults synchronize];
}

@end
