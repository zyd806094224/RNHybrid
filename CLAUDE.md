# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## 项目概述

RNHybrid 是轻匣的三端 React Native 混合移动工程。Android、iOS、HarmonyOS 使用原生壳实现启动页、主页、我的、登录和系统导航，账号与备忘等业务页面由 `src/` 下的 React Native 代码跨端复用。

开始修改前先阅读：

- `README.md`：应用介绍、技术栈和文档导航
- `docs/technical-architecture.md`：三端架构边界、鉴权和 Bundle 策略
- `android/README.md`、`ios/README.md`、`harmony/README.md`：平台实现说明
- `docs/harmony-rn-integration.md`：HarmonyOS RNOH、Stub 和返回键实现

## 常用命令

```bash
npm install
npm start
npm run android
npm run ios
npm run dev
npm test
npm run lint
```

Android Debug 构建：

```bash
cd android
./gradlew assembleDebug
```

iOS 首次安装或原生依赖变化后：

```bash
cd ios
pod install
```

HarmonyOS 使用 DevEco Studio 打开 `harmony/` 并运行 `entry` 模块。

## 架构约束

- 原生层是持久化登录态的事实来源；RN 不直接持久化 Token。
- 原生 RN 容器通过 `initialProps` 注入 `token` 和 `username`。
- RN 请求收到 401 后，通过平台 `AuthModule` 通知原生层退出登录并打开登录页。
- Android 的 `ReactInstanceManager` 必须保持单例。
- iOS Token 使用 Keychain，用户名使用 `NSUserDefaults`。
- HarmonyOS 使用 RNOH `RNApp`，Bundle 顺序为 Metro、Pushy、本地 rawfile。
- HarmonyOS Stub 只在 `Platform.OS === 'harmony'` 时生效，不应影响 Android/iOS。
- 服务地址、App Key、签名凭据和生产 Token 不应新增到说明文档或业务源码。

## RN 共享业务

`src/navigation/AppNavigator.js` 当前注册：

- `Home`
- `AccountList`
- `AccountEdit`
- `MemoList`
- `MemoDetail`
- `MemoEdit`

新增 RN 页面时，在 `src/screens/` 实现并在 `src/navigation/AppNavigator.js` 注册。修改共享 API 时，应保持三端原生注入参数和 401 回调协议兼容。

## 发布约束

- 原生代码、依赖、权限和资源变化必须发布新的原生包。
- 热更新必须分别验证 Android、iOS、HarmonyOS 的 Release Bundle 加载与回退行为。
- Pushy 基线包和实际发布包应来自同一次构建。
- HarmonyOS 修改 ArkTS、C++、依赖或资源后必须重新构建应用。
