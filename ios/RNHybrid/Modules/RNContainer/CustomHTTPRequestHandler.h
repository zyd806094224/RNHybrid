#import <React/RCTURLRequestHandler.h>
#import <React/RCTInvalidating.h>

/**
 * 自定义 HTTP 请求处理器，替换 RN 默认网络层
 * 对标 Android CustomOkHttpClientFactory
 *
 * Debug 模式：信任所有证书（方便 Charles/Fiddler 抓包）
 * Release 模式：106.15.7.132 使用内置 server_cert.der 做完整证书固定，
 *              其他 HTTPS 使用系统默认校验
 */
@interface CustomHTTPRequestHandler : NSObject <RCTURLRequestHandler, RCTInvalidating>

@end
