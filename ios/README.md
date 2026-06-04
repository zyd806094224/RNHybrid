# iOS 平台说明

iOS 工程是轻匣的 Objective-C/UIKit 原生宿主，负责启动页、主页、我的、登录、系统导航、登录态安全存储和 React Native 容器。

## 工程结构

```text
ios/
├── RNHybrid/
│   ├── App/                    # AppDelegate 与应用入口
│   ├── Modules/
│   │   ├── Main/               # 启动页、主页、我的和主导航
│   │   ├── Auth/               # 登录页、AuthManager、AuthModule
│   │   └── RNContainer/        # RNViewController 与请求处理
│   ├── Resources/
│   │   ├── Media.xcassets/     # 应用图标、启动图等资源
│   │   └── LaunchScreen.storyboard
│   └── SupportingFiles/
├── Podfile
└── RNHybrid.xcworkspace
```

## 页面流程

```text
AppDelegate
  → AuthManager.prepareForLaunch
  → SplashViewController
  → MainViewController
      ├─ HomeViewController
      └─ MineViewController

受保护入口
  → 未登录时 push LoginViewController
  → 登录成功后 push RNViewController
```

原生页面由 UIKit 导航栈管理，支持 iOS 系统左侧边缘返回手势。RN 容器内的共享业务页面由 React Navigation 管理。

## 鉴权与持久化

iOS 使用系统主流方案存储登录态：

- Token 存入 Keychain 的 Generic Password 条目。
- Keychain 服务名为 `<bundle-id>.authentication`，账号名为 `auth_token`。
- 可访问级别为 `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`，仅本机且设备解锁后可读。
- Token 不参与 iCloud 同步。
- 用户名存入 `NSUserDefaults`，因为它不属于敏感凭据。
- 启动时会迁移旧版 `NSUserDefaults` 明文 Token。
- 通过安装标记处理 Keychain 在卸载重装后可能残留的问题。
- 退出登录时删除 Keychain Token；删除失败时进入重置等待状态，避免继续使用旧 Token。

RN 不持久化 Token。`RNViewController` 从 `AuthManager` 读取登录态并通过 `initialProps` 注入；RN 收到 401 后调用 `AuthModule`，由原生层退出登录并返回登录页。

## RN Bundle

- Debug：通过 `RCTBundleURLProvider` 优先连接 Metro，Metro 不可用时回退 App 内置 `main.jsbundle`，且不读取 Documents 更新包。
- Release：优先读取 Documents 目录中的 `index.ios.bundle`；文件不存在时，由 `RNViewController` 从配置的 Bundle 服务下载；下载不可用或失败时回退 App 内置 `main.jsbundle`。

Metro 已连接但返回 Bundle 编译错误时，会保留 React Native 开发错误页面，不会回退旧 Bundle。当前 Release 更新加载仍是 iOS 自定义实现，与 Android、HarmonyOS 的原生 Pushy Bundle Provider 不完全一致。

## 构建与运行

```bash
npm install
cd ios
pod install
cd ..
npm start
npm run ios
```

也可使用 Xcode 打开 `ios/RNHybrid.xcworkspace`，选择 `RNHybrid` Scheme 和目标设备运行。

刷新 Debug 模式的 App 内置 RN 兜底 Bundle：

```bash
npm run bundle:ios:debug-fallback
```

发布 Release 前生成生产模式内置 Bundle：

```bash
npm run bundle:ios:release
```

两个命令都会覆盖 `RNHybrid/Resources/main.jsbundle` 和配套 `assets/`，构建 App 前应执行与目标构建模式对应的命令。

命令行构建模拟器 Debug 包：

```bash
xcodebuild \
  -workspace ios/RNHybrid.xcworkspace \
  -scheme RNHybrid \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath /private/tmp/RNHybridDerivedData \
  build
```

## 应用名称、图标与启动页

- 应用显示名称：`轻匣`
- App Icon：`ios/RNHybrid/Resources/Media.xcassets/AppIcon.appiconset/`
- 启动页：`ios/RNHybrid/Resources/LaunchScreen.storyboard`
- 启动与品牌图片：`ios/RNHybrid/Resources/Media.xcassets/`

替换图标时应使用 Xcode 的 Asset Catalog 管理对应尺寸，并验证真机、浅色模式和不同屏幕尺寸。

## 关键文件

| 文件 | 作用 |
|------|------|
| `RNHybrid/App/AppDelegate.mm` | 应用启动和初始页面 |
| `RNHybrid/Modules/Main/MainViewController.m` | 原生主导航 |
| `RNHybrid/Modules/Auth/LoginViewController.m` | 原生登录页 |
| `RNHybrid/Modules/Auth/AuthManager.m` | Keychain 登录态管理 |
| `RNHybrid/Modules/Auth/AuthModule.m` | RN 到原生鉴权桥 |
| `RNHybrid/Modules/RNContainer/RNViewController.m` | RN 容器和 Bundle 加载 |
