# 轻匣技术架构说明

## 1. 设计目标

轻匣使用“原生壳 + React Native 共享业务层”的混合架构，目标是在三端维持一致业务体验的同时，保留原生启动速度、系统导航、登录体验和平台能力。

架构遵循以下边界：

- 原生层负责启动、主页、我的、登录、系统返回、登录态持久化和 RN 容器生命周期。
- RN 层负责适合跨端复用的业务页面、接口调用、页面内导航和业务状态。
- 登录态以原生层为事实来源，RN 仅在当前容器生命周期内使用原生注入的数据。
- 三端共享业务协议，但平台实现可以根据系统能力独立演进。

## 2. 分层与职责

```text
┌────────────────────────────────────────────┐
│ 原生应用层                                 │
│ 启动页 / 主页 / 我的 / 登录 / 原生路由     │
├────────────────────────────────────────────┤
│ 混合容器层                                 │
│ RN 生命周期 / initialProps / AuthModule    │
├────────────────────────────────────────────┤
│ React Native 共享业务层                    │
│ 账号 / 备忘 / React Navigation / API       │
├────────────────────────────────────────────┤
│ 服务层                                     │
│ 登录接口 / 业务接口 / Bundle 与更新服务    │
└────────────────────────────────────────────┘
```

### 原生层

- 渲染启动页、主页、我的和登录页面。
- 判断受保护入口是否需要登录。
- 持久化 Token 和用户名。
- 创建 RN 容器并通过 `initialProps` 注入 `token`、`username`。
- 接收 RN 的 Token 失效事件，清理登录态并返回登录页。

### RN 层

- `src/navigation/AppNavigator.js` 管理共享业务导航。
- `src/api/request.js` 统一添加 `Authorization: Bearer <token>`。
- `src/context/AuthProvider.js` 和 `src/api/auth.js` 保存当前 RN 容器内的登录态。
- 接口响应为 HTTP 401 或业务码 401 时，通过原生 `AuthModule` 通知宿主。

当前 RN 路由包括：

| 路由 | 页面 |
|------|------|
| `Home` | RN 业务入口 |
| `AccountList` / `AccountEdit` | 账号列表与编辑 |
| `MemoList` / `MemoDetail` / `MemoEdit` | 备忘列表、详情与编辑 |

## 3. 三端实现对照

| 能力 | Android | iOS | HarmonyOS |
|------|---------|-----|-----------|
| 原生语言/UI | Kotlin / Android View | Objective-C / UIKit | ArkTS / ArkUI |
| 原生路由 | Navigation、ARouter | UIKit 导航栈 | HMRouter |
| RN 容器 | `ReactRootView` | `RCTRootView` | RNOH `RNApp` |
| 原生桥 | `AuthModule` | `AuthModule` | `AuthTurboModule` |
| Token 存储 | MMKV | Keychain | ArkData Preferences |
| 用户名存储 | MMKV | `NSUserDefaults` | ArkData Preferences |
| Debug Bundle | Metro | Metro | Metro |
| Release Bundle | Pushy / assets | Documents 本地 Bundle | Pushy / rawfile |

平台具体结构见 [Android](../android/README.md)、[iOS](../ios/README.md) 和 [HarmonyOS](../harmony/README.md) 说明。

## 4. 登录与鉴权方案

### 登录成功

```text
用户提交登录
  → 原生登录页请求登录接口
  → 原生 AuthManager 持久化 token / username
  → 恢复受保护目标页或进入 RN 容器
  → RN 容器通过 initialProps 获得登录态
  → RN 请求自动携带 Bearer Token
```

### Token 失效

```text
RN 接口返回 401
  → RN 调用 AuthModule.onTokenExpired()
  → 原生层防重复处理
  → 清除持久化登录态
  → 关闭 RN 容器
  → 打开原生登录页
```

### 持久化策略

三端 Token 都会跨应用重启保留，但安全等级不同：

- iOS 使用 Keychain，配置为仅本机、设备解锁后可访问，并处理旧明文 Token 迁移及卸载重装残留。
- Android 当前使用 MMKV 持久化 Token 和用户名。MMKV 主要提供高性能持久化，不等同于系统安全凭据存储。
- HarmonyOS 当前使用 ArkData Preferences 持久化 Token 和用户名，同样属于通用偏好存储。
- RN 层不持久化 Token，仅持有原生注入的当前会话数据。

如需提升 Android 和 HarmonyOS 的生产安全等级，应将 Token 迁移到平台安全凭据能力或增加系统密钥保护的加密层。

## 5. RN Bundle 与更新方案

### Debug

三端 Debug 构建均优先使用 Metro，便于热重载和调试：

```bash
npm start
```

### Release

- Android：`ReactNativeManager` 通过 `UpdateContext` 选择 Pushy 已下载更新包，未命中时回退到 `assets://index.android.bundle`。
- iOS：`RNViewController` 优先读取 Documents 中的 `index.ios.bundle`，文件不存在时从配置的服务端下载。该流程目前是自定义实现，且没有内置离线 Bundle 兜底。
- HarmonyOS：RNOH 按 `MetroJSBundleProvider`、`PushyFileJSBundleProvider`、`ResourceJSBundleProvider` 的顺序加载。

`App.js` 统一接入 `react-native-update` 的更新客户端，但三个原生容器的 Release Bundle 解析方式并不完全相同。发布前应分别验证三端基线包、更新包、回退能力和无可用 Bundle 时的错误处理。

## 6. 导航与返回

- Android 使用原生 Navigation/ARouter 管理壳页面，RN 页面内由 React Navigation 管理，系统返回事件转交 RN 实例。
- iOS 使用 `UINavigationController` 管理原生页面，支持系统侧边返回手势；RN 页面内由 React Navigation 管理。
- HarmonyOS 使用 HMRouter 管理原生页面。`RNPage` 拦截系统返回并转发给 RN；RN 到达根页面后再通知原生弹出容器。

受保护页面的入口应始终由原生层进行登录判断，避免业务页面各自重复实现拦截逻辑。

## 7. 网络方案

- RN 请求统一通过 `src/api/request.js` 发起，负责 Token 注入、响应结构转换和 401 处理。
- Android 原生网络基于 Retrofit/OkHttp。
- iOS 原生网络基于系统网络能力和自定义请求处理器。
- HarmonyOS 原生网络封装位于 `harmony/common/network/`。
- 当前工程包含自签名证书访问适配。生产环境应优先使用受信任证书，并限制自签名证书仅用于受控环境。

## 8. 工程与发布约束

- 原生代码、原生依赖、权限或资源变化必须发布新的原生包。
- 仅共享 RN 业务变化可以评估使用热更新，但必须遵守应用商店政策。
- 三个平台的版本号、签名和更新应用配置独立管理。
- Pushy 基线包与市场发布包应来自同一次构建，避免构建标识不一致。
- 服务地址、签名密码、证书私钥、App Key 和生产 Token 不应写入文档或业务源码。
- 发布前至少验证登录、退出、Token 失效、系统返回、冷启动和 Bundle 回退链路。
