# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

RNHybrid 是一个 React Native 混合开发示例项目，演示如何在原生 Android 和鸿蒙（HarmonyOS）应用中集成 RN 页面。一套 JS 代码同时支持 Android、iOS、鸿蒙三个平台。

**技术栈：** React Native 0.72.5、React 18.2.0、React Navigation 6.x、TypeScript、Kotlin（Android）、ArkTS/ETS（鸿蒙）。

## 常用命令

```bash
# 安装依赖
npm install

# 启动 Metro 打包服务
npm start

# 运行 Android 应用
npm run android

# 构建 Android APK
cd android && ./gradlew assembleDebug

# 鸿蒙：打包开发模式 JS Bundle（生成 bundle.harmony.js）
npm run dev

# 运行测试
npm test

# 代码检查
npm run lint
```

## 架构说明

### 三端混合结构

- **`src/`** — 共享的 RN JS/TS 代码（页面、组件、导航、stub）
- **`android/`** — 原生 Android 应用，集成 RN
  - `android/app/` — 主应用模块（Kotlin，Navigation Component）
  - `android/lib_rn/` — RN 集成库（`RNPageActivity.kt`、`ReactNativeManager.kt`）
- **`harmony/`** — 鸿蒙应用（ArkTS/ETS，DevEco Studio 工程）
  - `harmony/entry/` — 主模块，包含 RNPage.ets、EntryAbility.ets
  - `harmony/features/` — 业务特性模块（one、two、three、four）
  - `harmony/common/` — 公共组件（refresh、skeleton、tab、safeArea）

### Android 原生 ↔ RN 桥接

- `ReactNativeManager.kt` — 单例管理 `ReactInstanceManager`（混编项目中必须全局共享，避免重复创建导致 native 库加载失败）
- `RNPageActivity.kt` — 承载 `ReactRootView` 的 Activity，处理生命周期和返回键
- RN 模块注册名为 `"RNHybrid"`，通过 `ReactRootView.startReactApplication()` 启动
- 原生通过 `Bundle` 向 RN 传参（如 `putString("param1", "android")`）

### 鸿蒙原生 ↔ RN 桥接

- 使用 `@rnoh/react-native-openharmony`（RNOH）作为 RN 桥接层
- `EntryAbility.ets` 初始化 `RNInstancesCoordinator` 并存入 `AppStorage`
- `RNPage.ets` 渲染 `RNApp` 组件，三种 Bundle 加载策略（按优先级）：Metro 热加载 → Pushy 热更新 → Resource 内置包兜底
- 物理返回键协作处理：`RNPage.ets` 拦截 → 转发给 RN `BackHandler` → stub 导航栈处理栈内返回 → 根页面时 `BackHandler.exitApp()` 通知原生侧退出

### 鸿蒙 Stub 机制

`src/stubs/` 存放鸿蒙暂无原生实现的库的 JS 替代实现。仅当 `platform === 'harmony'` 时通过 `metro.config.js` 的 `resolveRequest` 钩子激活，不影响 Android/iOS：

| 原库 | Stub 文件 | 说明 |
|------|-----------|------|
| `react-native-screens` | `react-native-screens.js` | 空 View 包装 |
| `react-native-safe-area-context` | `react-native-safe-area-context.js` | 返回零 inset 的 SafeArea |
| `@react-navigation/native` | `@react-navigation-native.js` | NavigationContainer 包装为 View |
| `@react-navigation/native-stack` | `@react-navigation-native-stack.js` | **完整的 JS 端导航栈，含 BackHandler 支持** |

### 导航

- `AppNavigator.js` — React Navigation Native Stack，注册路由：Home、Details、ProfileScreen、FlatListScreen、AlgorithmScreen、TypeScriptScreen
- `SafeContainer.js` — 平台适配安全区域：Android/iOS 使用 `SafeAreaView`，鸿蒙使用普通 `View`（安全区域由原生侧处理）

### 热更新（Pushy）

- 集成 `react-native-update`，三端独立 `appKey`
- Debug 模式策略 `alwaysAlert`，Release 模式 `silentAndLater`
- 鸿蒙端：`PushyFileJSBundleProvider` 加载已下载的热更包，`ResourceJSBundleProvider` 加载 rawfile 中的 `bundle.harmony.js`
- **关键约束**：上传到 Pushy 的包和上架应用市场的包必须是同一次构建产物（通过 `meta.json` 中的 `pushy_build_time` 匹配）

## 开发约定

- 新增 RN 页面时，在 `src/navigation/AppNavigator.js` 中注册路由
- 鸿蒙 Stub 必须保持与原库一致的 API 接口
- Android 端 `ReactInstanceManager` 必须保持单例，禁止创建多个实例
- 鸿蒙平台判断使用 `Platform.OS === 'harmony'`
- 详细的鸿蒙集成指南见 `docs/harmony-rn-integration.md`，包含 Pushy 操作流程和物理返回键适配
