#import <React/RCTBridgeModule.h>

@interface AuthModule : NSObject <RCTBridgeModule>

/**
 * token 过期防重入标志
 */
@property (class, nonatomic, assign) BOOL isHandling;

/**
 * token 过期回调，由 RNViewController 设置
 */
@property (class, nonatomic, copy, nullable) void (^tokenExpiredCallback)(void);

@end
