#import <React/RCTURLRequestHandler.h>
#import <React/RCTInvalidating.h>

/**
 * 自定义 HTTP 请求处理器，替换 RN 默认网络层
 * 对标 Android CustomOkHttpClientFactory
 *
 * Debug 模式：信任所有证书（方便 Charles/Fiddler 抓包）
 * Release 模式：仅信任内置的自签名 server_cert.pem
 */
@interface CustomHTTPRequestHandler : NSObject <RCTURLRequestHandler, RCTInvalidating>

@end
