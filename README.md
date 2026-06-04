# 轻匣

轻匣是一款面向个人信息管理的三端移动应用，应用标语为“安全收纳账号与备忘”。工程采用原生壳与 React Native 混合架构，同时覆盖 Android、iOS 和 HarmonyOS。

原生层负责启动页、主页、我的、登录、系统导航和登录态持久化；React Native 负责账号管理、备忘录等可复用业务页面。三端保持一致的产品结构，同时保留各平台原生体验和工程能力。

## 当前能力

- 原生启动页、主页、我的和登录流程
- 账号信息的列表、分类和编辑
- 备忘录的列表、详情和编辑
- 登录态持久化、受保护页面拦截和 401 失效处理
- Android、iOS、HarmonyOS 三端 RN 容器
- Metro 开发调试、离线 Bundle 和热更新能力
- 自签名 HTTPS 服务访问适配

主页已预留数据看板、消息、多媒体、设置等工作台入口，未完成能力会显示为待开放状态。

## 架构概览

```text
Android / iOS / HarmonyOS 原生壳
  ├─ 启动页、主页、我的、登录
  ├─ 原生路由与登录态持久化
  └─ RN 容器
       ├─ initialProps 注入 token / username
       ├─ React Navigation 管理 RN 业务页面
       └─ AuthModule 将 401 失效事件通知原生层
```

| 平台 | 原生技术 | 导航与容器 | Token 存储 | Release Bundle |
|------|----------|------------|------------|----------------|
| Android | Kotlin、AndroidX | Navigation、ARouter、`ReactRootView` | MMKV | Pushy 更新包或内置 Bundle |
| iOS | Objective-C、UIKit | `UINavigationController`、`RCTRootView` | Keychain | 本地已下载 Bundle |
| HarmonyOS | ArkTS、ArkUI | HMRouter、RNOH `RNApp` | ArkData Preferences | Pushy 更新包或 rawfile Bundle |

完整边界、鉴权链路和 Bundle 策略见 [技术架构说明](docs/technical-architecture.md)。

## 技术栈

| 范围 | 主要技术 |
|------|----------|
| 共享业务层 | React Native 0.72.5、React 18.2、React Navigation 6 |
| Android | Kotlin、AndroidX、ARouter、Retrofit/OkHttp、MMKV |
| iOS | Objective-C、UIKit、Security/Keychain、CocoaPods |
| HarmonyOS | ArkTS、ArkUI、HMRouter、RNOH 0.72.133、Hvigor |
| 更新能力 | Metro、离线 Bundle、react-native-update 10.39.1 |
| 测试与规范 | Jest、ESLint、Prettier |

## 项目结构

```text
.
├── src/                     # 三端共享 React Native 业务代码
│   ├── api/                 # 接口与鉴权请求封装
│   ├── components/          # 共享组件
│   ├── context/             # RN 全局状态
│   ├── navigation/          # RN 页面导航
│   ├── screens/             # 账号、备忘等业务页面
│   └── stubs/               # HarmonyOS 平台兼容实现
├── android/                 # Android 原生壳及基础模块
├── ios/                     # iOS 原生壳
├── harmony/                 # HarmonyOS 原生壳及模块
├── docs/                    # 架构与专项集成文档
├── App.js                   # RN 根组件与更新客户端
└── index.js                 # RN 入口
```

## 文档导航

- [统一技术架构](docs/technical-architecture.md)
- [Android 平台说明](android/README.md)
- [iOS 平台说明](ios/README.md)
- [HarmonyOS 平台说明](harmony/README.md)
- [HarmonyOS 集成 React Native](docs/harmony-rn-integration.md)
- [Pushy 命令手册](Pushy命令手册.md)

## 快速开始

### 通用环境

- Node.js 16 或更高版本
- npm
- 对应平台的开发工具和 SDK

```bash
npm install
npm start
```

### Android

```bash
npm run android

# 刷新 Debug 模式的 APK 内置 RN 兜底 Bundle
npm run bundle:android:debug-fallback

# 构建 Android Debug 包
cd android
./gradlew assembleDebug
```

### iOS

```bash
cd ios
pod install
cd ..

# 刷新 Debug 模式的 App 内置 RN 兜底 Bundle
npm run bundle:ios:debug-fallback

# 发布 Release 前生成生产模式内置 Bundle
npm run bundle:ios:release

npm run ios
```

### HarmonyOS

使用 DevEco Studio 打开 `harmony/` 并运行 `entry` 模块。需要生成内置 RN Bundle 时执行：

```bash
# 刷新 Debug 模式的 HAP 内置 RN 兜底 Bundle
npm run bundle:harmony:debug-fallback

# 发布 Release 前生成生产模式内置 Bundle
npm run bundle:harmony:release
```

## 开发约定

- 原生壳负责平台能力、系统导航和持久化登录态，RN 不直接持久化 Token。
- 新增共享业务页面时，在 `src/screens/` 实现并在 `src/navigation/` 注册。
- 修改原生代码后，需要重新构建对应平台应用。
- 仅修改 RN 代码时，可使用 Metro 调试；发布热更新前必须验证对应平台 Release 包。
- 服务地址、App Key、签名文件和生产凭据应通过环境配置或 CI 注入，不应写入说明文档或新增到源码。

## 关联项目

- Web 前端：[Vue3SeedProject](https://github.com/zyd806094224/Vue3SeedProject)
- 后端服务：[SpringBootServiceSeedProject](https://github.com/zyd806094224/SpringBootServiceSeedProject)
