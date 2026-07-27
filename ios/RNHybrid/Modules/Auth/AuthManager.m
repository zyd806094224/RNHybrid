#import "AuthManager.h"
#import <Security/Security.h>
#import <Shared/Shared.h>

static NSString * const kAuthLegacyTokenKey = @"auth_token";
static NSString * const kAuthUsernameKey = @"auth_username";
static NSString * const kAuthInstallMarkerKey = @"auth_install_marker_v1";
static NSString * const kAuthKeychainResetPendingKey = @"auth_keychain_reset_pending";
static NSString * const kAuthKeychainAccount = @"auth_token";
static NSString * const kAuthKeychainServiceSuffix = @".authentication";

@interface AuthManager ()

- (NSString *)keychainService;
- (NSMutableDictionary *)keychainQuery;
- (BOOL)saveTokenToKeychain:(NSString *)token;
- (NSString *)tokenFromKeychain;
- (BOOL)deleteTokenFromKeychain;

@end

@implementation AuthManager

+ (instancetype)sharedInstance {
    static AuthManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AuthManager alloc] init];
    });
    return instance;
}

- (void)prepareForLaunch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasInstallMarker = [defaults objectForKey:kAuthInstallMarkerKey] != nil;
    NSString *legacyToken = [defaults stringForKey:kAuthLegacyTokenKey] ?: @"";

    if (!hasInstallMarker) {
        [defaults setBool:YES forKey:kAuthInstallMarkerKey];

        if (legacyToken.length > 0) {
            if ([self saveTokenToKeychain:legacyToken]) {
                [defaults removeObjectForKey:kAuthLegacyTokenKey];
                [defaults removeObjectForKey:kAuthKeychainResetPendingKey];
            } else {
                NSLog(@"[Auth] Legacy token migration failed");
            }
        } else {
            BOOL deleted = [self deleteTokenFromKeychain];
            [defaults removeObjectForKey:kAuthUsernameKey];
            [defaults setBool:!deleted forKey:kAuthKeychainResetPendingKey];
        }
    } else if ([defaults boolForKey:kAuthKeychainResetPendingKey]) {
        if ([self deleteTokenFromKeychain]) {
            [defaults removeObjectForKey:kAuthKeychainResetPendingKey];
        }
    } else if (legacyToken.length > 0) {
        if ([self saveTokenToKeychain:legacyToken]) {
            [defaults removeObjectForKey:kAuthLegacyTokenKey];
        } else {
            NSLog(@"[Auth] Legacy token migration retry failed");
        }
    }

    [defaults synchronize];

    NSString *token = [self getToken];
    if (token.length > 0) {
        [[SharedTokenManager shared] saveTokenToken:token];
    } else {
        [[SharedTokenManager shared] clearToken];
    }
}

- (BOOL)saveLoginWithToken:(NSString *)token username:(NSString *)username {
    if (![self saveTokenToKeychain:token]) {
        return NO;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:kAuthUsernameKey];
    [defaults setBool:YES forKey:kAuthInstallMarkerKey];
    [defaults removeObjectForKey:kAuthLegacyTokenKey];
    [defaults removeObjectForKey:kAuthKeychainResetPendingKey];
    [defaults synchronize];
    [[SharedTokenManager shared] saveTokenToken:token];
    return YES;
}

- (NSString *)getToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kAuthKeychainResetPendingKey]) {
        return @"";
    }
    return [self tokenFromKeychain];
}

- (NSString *)getUsername {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAuthUsernameKey] ?: @"";
}

- (BOOL)isLoggedIn {
    return self.getToken.length > 0;
}

- (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL deleted = [self deleteTokenFromKeychain];
    [defaults setBool:!deleted forKey:kAuthKeychainResetPendingKey];
    [defaults removeObjectForKey:kAuthLegacyTokenKey];
    [defaults removeObjectForKey:kAuthUsernameKey];
    [defaults synchronize];
    [[SharedTokenManager shared] clearToken];
}

- (NSString *)keychainService {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    if (bundleIdentifier.length == 0) {
        bundleIdentifier = @"com.rnhybrid";
    }
    return [bundleIdentifier stringByAppendingString:kAuthKeychainServiceSuffix];
}

- (NSMutableDictionary *)keychainQuery {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            [self keychainService], (__bridge id)kSecAttrService,
            kAuthKeychainAccount, (__bridge id)kSecAttrAccount,
            nil];
}

- (BOOL)saveTokenToKeychain:(NSString *)token {
    if (token.length == 0) {
        return NO;
    }

    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    if (!tokenData) {
        return NO;
    }

    NSMutableDictionary *query = [self keychainQuery];
    NSDictionary *attributes = @{
        (__bridge id)kSecValueData: tokenData,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    };

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query,
                                    (__bridge CFDictionaryRef)attributes);
    if (status == errSecItemNotFound) {
        [query addEntriesFromDictionary:attributes];
        [query setObject:@NO forKey:(__bridge id)kSecAttrSynchronizable];
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }

    if (status != errSecSuccess) {
        NSLog(@"[Auth] Keychain token save failed, status=%d", (int)status);
        return NO;
    }
    return YES;
}

- (NSString *)tokenFromKeychain {
    NSMutableDictionary *query = [self keychainQuery];
    [query setObject:@YES forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecItemNotFound) {
        return @"";
    }
    if (status != errSecSuccess || !result) {
        NSLog(@"[Auth] Keychain token read failed, status=%d", (int)status);
        return @"";
    }

    NSData *tokenData = (__bridge NSData *)result;
    NSString *token = [[[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding] autorelease];
    CFRelease(result);
    return token ?: @"";
}

- (BOOL)deleteTokenFromKeychain {
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)[self keychainQuery]);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        NSLog(@"[Auth] Keychain token delete failed, status=%d", (int)status);
        return NO;
    }
    return YES;
}

@end
