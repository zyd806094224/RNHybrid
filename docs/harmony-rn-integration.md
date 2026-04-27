# 鸿蒙集成 React Native 指南

## 一、项目概述

本项目是一个 React Native 混合开发工程，同时支持 Android 和 HarmonyOS（鸿蒙）平台。鸿蒙端使用 `@rnoh/react-native-openharmony`（RNOH）作为 RN 桥接层，支持三种 JS Bundle 加载模式：Metro 开发热加载、Pushy 热更新、内置 Bundle。

## 二、版本兼容性说明

| 依赖 | 版本 | 说明 |
|------|------|------|
| React Native | 0.72.5 | JS 框架版本 |
| @rnoh/react-native-openharmony | 0.72.133 | RN 鸿蒙桥接层 |
| react-native-update | ^10.39.1 | Pushy 热更新 |
| @react-native-oh/react-native-harmony | ^0.72.53-1 | Metro 鸿蒙适配 |
| DevEco Studio | 6.0.0 | IDE 版本 |
| HarmonyOS SDK | API 15 (5.0.5) | 最低 SDK 要求 |

> **重要**: RNOH 0.72.133 需要 API 15 及以上 SDK，低版本 SDK 会缺少 `getWindowDecorVisible`、`HTM_BLOCK_DESCENDANTS` 等接口。

## 三、项目结构

```
harmony/
├── entry/                          # 主模块
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── pages/
│   │   │   │   ├── Launcher.ets    # 原生启动页
│   │   │   │   └── RNPage.ets      # RN 载体页
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets # 应用入口
│   │   │   └── RNPackagesFactory.ts # RN Package 工厂
│   │   ├── cpp/
│   │   │   ├── CMakeLists.txt      # C++ 构建配置
│   │   │   └── PackageProvider.cpp  # C++ Package 提供者
│   │   └── resources/rawfile/
│   │       ├── bundle.harmony.js   # 内置 RN Bundle
│   │       └── meta.json           # Pushy 构建时间戳
│   ├── oh-package.json5            # 模块依赖
│   ├── hvigorfile.ts               # 构建插件配置
│   └── build-profile.json5         # 构建配置
├── common/
│   ├── component/                  # 公共组件模块
│   ├── network/                    # 网络模块
│   └── lib_rn/                     # RN 公共模块
├── features/                       # 业务特性模块
│   ├── one/
│   ├── two/
│   ├── three/
│   └── four/
├── hvigor/
│   └── hvigor-config.json5         # Hvigor 依赖配置
├── oh-package.json5                # 根依赖配置
└── build-profile.json5             # 应用构建配置
```

## 四、核心集成配置

### 4.1 应用入口 (EntryAbility.ets)

初始化 RNOH 上下文，配置 Metro 开发服务器连接：

```typescript
import { RNInstancesCoordinator, StandardRNOHLogger } from '@rnoh/react-native-openharmony';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const rnohLogger = new StandardRNOHLogger();
    const rnCoordinator = RNInstancesCoordinator.create({
      logger: rnohLogger,
      uiAbilityContext: this.context,
      defaultBackPressHandler: () => {},
      rnohWorkerScriptUrl: undefined,
    }, {
      disableCleaningRNInstances: false,
      launchURI: want.uri,
      // DEBUG 模式连接 Metro，Release 模式不连接
      onGetPackagerClientConfig: (buildMode: string) => buildMode === "DEBUG" ? {
        host: "localhost",
        port: 8081
      } : undefined,
    });
    AppStorage.setOrCreate('RNOHCoreContext', rnCoordinator.getRNOHCoreContext());
  }
}
```

### 4.2 RN 载体页 (RNPage.ets)

RN 页面容器，配置三种 Bundle 加载模式（按优先级排序）：

```typescript
import {
  RNApp, RNOHCoreContext, RNOHLogger,
  AnyJSBundleProvider, MetroJSBundleProvider,
  ResourceJSBundleProvider, TraceJSBundleProviderDecorator,
  ComponentBuilderContext,
} from '@rnoh/react-native-openharmony';
import { PushyFileJSBundleProvider } from 'pushy';

@HMRouter({ pageUrl: RouterUrl.RN_PAGE_URL })
@Component
export struct RNPage {
  @StorageLink('RNOHCoreContext') private rnohCoreContext: RNOHCoreContext | undefined = undefined

  build() {
    Column() {
      if (this.rnohCoreContext) {
        RNApp({
          rnInstanceConfig: {
            createRNPackages,
            enableNDKTextMeasuring: true,
            enableBackgroundExecutor: false,
            enableCAPIArchitecture: true,
            arkTsComponentNames: [],
          },
          appKey: "RNHybrid",
          jsBundleProvider: new TraceJSBundleProviderDecorator(
            new AnyJSBundleProvider([
              new MetroJSBundleProvider(),                                                    // 1. Metro 开发热加载
              new PushyFileJSBundleProvider(this.rnohCoreContext!.uiAbilityContext),          // 2. Pushy 热更新
              new ResourceJSBundleProvider(                                                   // 3. 内置 Bundle 兜底
                this.rnohCoreContext!.uiAbilityContext.resourceManager,
                'bundle.harmony.js'
              ),
            ]),
            this.rnohCoreContext!.logger
          ),
        })
      }
    }
  }
}
```

**Bundle 加载策略**：`AnyJSBundleProvider` 按数组顺序依次尝试，第一个成功的即停止：
- **Metro**：DEBUG 模式下连接 `localhost:8081` 热加载
- **Pushy**：从本地文件系统加载已下载的热更包
- **Resource**：从 rawfile 加载内置 `bundle.harmony.js`

### 4.3 RN Package 注册 (RNPackagesFactory.ts)

```typescript
import type { RNPackageContext, RNPackage } from "@rnoh/react-native-openharmony/ts";
import { PushyPackage } from "pushy/ts";

export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [new PushyPackage(ctx)];
}
```

### 4.4 C++ 层配置

**CMakeLists.txt**：

```cmake
project(rnapp)
cmake_minimum_required(VERSION 3.4.1)

set(OH_MODULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../oh_modules")
set(RNOH_CPP_DIR "${OH_MODULE_DIR}/@rnoh/react-native-openharmony/src/main/cpp")

add_subdirectory("${RNOH_CPP_DIR}" ./rn)

add_library(rnoh_app SHARED
    "./PackageProvider.cpp"
    "${RNOH_CPP_DIR}/RNOHAppNapiBridge.cpp"
)

# Pushy TurboModule
set(NODE_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../node_modules")
set(PUSHY_CPP_DIR "${NODE_MODULES}/react-native-update/harmony/pushy/src/main/cpp")
target_include_directories(rnoh_app PRIVATE "${PUSHY_CPP_DIR}")
target_sources(rnoh_app PRIVATE "${PUSHY_CPP_DIR}/PushyTurboModule.cpp")

target_link_libraries(rnoh_app PUBLIC rnoh)
```

**PackageProvider.cpp**：

```cpp
#include "RNOH/PackageProvider.h"
#include "PushyPackage.h"

using namespace rnoh;

std::vector<std::shared_ptr<Package>> PackageProvider::getPackages(Package::Context ctx) {
    return {
        std::make_shared<PushyPackage>(ctx)
    };
}
```

### 4.5 依赖配置

**harmony/oh-package.json5**（根配置）：

```json5
{
  "overrides": {
    "@hadss/hmrouter": "^1.2.2",
    "@rnoh/react-native-openharmony": "0.72.133"
  }
}
```

**harmony/entry/oh-package.json5**（模块配置）：

```json5
{
  "dependencies": {
    "@rnoh/react-native-openharmony": "0.72.133",
    "pushy": "file:../../node_modules/react-native-update/harmony/pushy.har",
    // ...其他依赖
  }
}
```

**harmony/hvigor/hvigor-config.json5**：

```json5
{
  "dependencies": {
    "@hadss/hmrouter-plugin": "^1.2.2",
    "pushy": "file:../../node_modules/react-native-update/harmony"
  }
}
```

**harmony/entry/hvigorfile.ts**：

```typescript
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { hapPlugin } from "@hadss/hmrouter-plugin";
import { reactNativeUpdatePlugin } from 'pushy/hvigor-plugin';

export default {
    system: hapTasks,
    plugins: [hapPlugin(), reactNativeUpdatePlugin()]
}
```

> **注意**: `reactNativeUpdatePlugin` 会在构建时自动将 `pushy_build_time` 写入 `meta.json`，Pushy 靠此字段匹配基线包和热更包。

### 4.6 前端代码 (App.js)

```javascript
import { Platform } from 'react-native';

const App = (props) => {
    const {Pushy, UpdateProvider} = require('react-native-update');
    const appKeys = {
        android: '<android appKey>',
        ios: '<ios appKey>',
        harmony: '<harmony appKey>',
    };
    const pushy = new Pushy({
        appKey: appKeys[Platform.OS],
        updateStrategy: __DEV__ ? 'alwaysAlert' : 'silentAndLater',
    });

    return (
        <UpdateProvider client={pushy}>
            <SafeAreaView style={styles.container}>
                <AppNavigator/>
            </SafeAreaView>
        </UpdateProvider>
    );
};
```

> **注意**: iOS、Android、Harmony 三个平台需要在 Pushy 后台分别创建应用，各平台 `appKey` 不同。

### 4.7 Metro 配置 (metro.config.js)

```javascript
const { createHarmonyMetroConfig } = require('@react-native-oh/react-native-harmony/metro.config');
const path = require('path');

const harmonyConfig = createHarmonyMetroConfig({
  reactNativeHarmonyPackageName: '@react-native-oh/react-native-harmony',
});

// 鸿蒙暂不支持的库需要配置 stub
const harmonyStubs = {
  'react-native-screens': path.resolve(__dirname, 'src/stubs/react-native-screens.js'),
  'react-native-safe-area-context': path.resolve(__dirname, 'src/stubs/react-native-safe-area-context.js'),
};

module.exports = mergeConfig(defaultConfig, harmonyConfig, {
  resolver: {
    extraNodeModules: harmonyStubs,
  },
});
```

## 五、Pushy 热更新操作流程

### 5.1 首次配置

```bash
# 1. 登录 Pushy
npx pushy login

# 2. 创建鸿蒙应用
npx pushy createApp --platform harmony

# 3. 选择应用（如果已在网页端创建）
npx pushy selectApp --platform harmony
```

完成后项目根目录会生成 `update.json`，包含各平台的 `appId` 和 `appKey`。

### 5.2 上传基线包

```bash
# 1. 在 DevEco Studio 中 Build App（Build → Build Hap(s)/App(s) → Build App(s)）

# 2. 上传未签名的 app 包到 Pushy
npx pushy uploadApp harmony/build/outputs/default/harmony-default-unsigned.app
```

上传后 Pushy 会记录该包的 `versionName`（来自 `harmony/AppScope/app.json5`）和 `pushy_build_time`（来自 `rawfile/meta.json`），用于后续热更新版本比对。

### 5.3 完整发布流程（从零开始）

> **核心原则**：上传到 Pushy 的包和上架应用市场的包，必须是**同一次构建产物**。因为 Pushy 通过 `pushy_build_time`（构建时自动写入 `meta.json`）来匹配基线包，重新 Build 会生成不同的时间戳导致 `buildtime-mismatch` 错误。

```bash
# 步骤1: 生成内置 JS Bundle（会更新 rawfile/bundle.harmony.js 和 meta.json）
pushy bundle --platform harmony

# 步骤2: 在 DevEco Studio 中 Build App（Build → Build Hap(s)/App(s) → Build App(s)）
# 产物在 harmony/build/outputs/default/harmony-default-unsigned.app

# 步骤3: 上传到 Pushy 服务器（记录基线版本信息）
pushy uploadApp harmony/build/outputs/default/harmony-default-unsigned.app

# 步骤4: 同一个 app 包做签名，然后上架华为应用市场
# 注意：不要重新 Build，用步骤2同一个产物去签名上架

# 步骤5: 安装到设备测试
hdc install harmony/build/outputs/default/harmony-default-unsigned.app
```

### 5.4 发布热更新

> 只修改 JS 代码时，不需要重新打原生包，直接执行以下命令即可。

```bash
# 修改 JS 代码后，打包并上传热更新
pushy bundle --platform harmony
# 按提示操作：
#   - 是否上传：Y
#   - 输入版本名称和描述
#   - 是否应用到原生包：Y
```

热更新生效后，用户的 app 无需重新安装，下次启动即可加载新版本。

### 5.5 热更新生效流程

1. 用户打开 app → Pushy JS 代码检查更新 → 下载 ppk 到本地
2. 用户**关闭 app 再重新打开** → `PushyFileJSBundleProvider` 加载已下载的 bundle → 页面更新

> 热更包下载后需要**重启 app** 才能生效。

### 5.6 发布新版原生包

当需要修改原生代码或配置时（纯 JS 修改不需要），需要发布新的原生基线包：

```bash
# 1. 修改 app.json5 中的版本号（必须改，否则 buildtime-mismatch）
#    "versionName": "1.0.0" → "1.0.1"

# 2. 重新生成 JS Bundle
pushy bundle --platform harmony

# 3. 在 DevEco Studio 中 Build App(s)

# 4. 上传新的基线包到 Pushy
pushy uploadApp harmony/build/outputs/default/harmony-default-unsigned.app

# 5. 同一个包签名后上架应用市场
```

> **每次重新打原生包必须修改 `versionName`**，这是强制要求。相同的 `versionName` 会导致编译时间戳不一致，热更新无法生效。

### 5.7 命令行安装 HAP

```bash
# hdc 工具路径
export PATH=$PATH:/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains

# 安装
hdc install <hap文件路径>

# 卸载
hdc uninstall <bundleName>

# 查看设备
hdc list targets
```

## 六、开发调试

### 6.1 Metro 开发热加载

```bash
# 启动 Metro 服务
npx react-native start

# 或直接运行
npm start
```

DEBUG 模式下 app 会自动连接 `localhost:8081`。真机调试需要端口转发：

```bash
hdc rport tcp:8081 tcp:8081
```

### 6.2 打包内置 Bundle

```bash
# 开发模式（带 sourcemap）
npm run dev

# 或手动执行
npx react-native bundle-harmony --dev
```

生成的 `bundle.harmony.js` 需要复制到 `harmony/entry/src/main/resources/rawfile/` 目录。

## 七、注意事项

1. **SDK 版本**：RNOH 0.72.133 要求 HarmonyOS SDK API 15+，低版本 SDK 会导致编译错误
2. **oh_modules 管理修改后需重新编译**：`cpp/` 和 `ets/` 下的改动需要重新 Build 才能生效
3. **版本锁定**：`harmony/oh-package.json5` 中 RNOH 版本不要用 `^`，避免自动升级到不兼容版本
4. **三个平台独立管理**：Pushy 的 iOS、Android、Harmony 应用需要分别创建，`appKey` 各不相同
5. **Build Mode**：DEBUG 模式下 Metro 优先加载，测试热更新建议使用 Release 模式
6. **`.update` 文件**：Pushy 登录凭证，不要提交到 Git
7. **`update.json`**：包含 appId 和 appKey，可以提交到 Git
8. **同一次构建原则**：上传 Pushy 的包和上架应用市场的包必须是同一次 Build 的产物，重新 Build 会导致 `pushy_build_time` 变化从而引发 `buildtime-mismatch` 错误
9. **版本号必须递增**：每次重新打原生包发布时，必须修改 `harmony/AppScope/app.json5` 中的 `versionName`，否则热更新无法生效

## 八、Harmony 平台 Stub 机制

### 8.1 为什么需要 Stub

鸿蒙端的 React Native 使用 `@rnoh/react-native-openharmony`（RNOH）作为桥接层。RNOH 目前只适配了 React Native 核心库，部分常用的第三方原生库（如 `react-native-screens`、`react-native-safe-area-context`）在鸿蒙上没有官方原生实现。

虽然社区（`react-native-oh-library`）提供了鸿蒙适配版本（如 `@react-native-oh-tpl/react-native-screens`），但这些包对 RNOH 版本有严格要求：
- `@react-native-oh-tpl/react-native-screens` 的 `.har` 依赖 `@rnoh/react-native-openharmony/generated` 模块，当前 RNOH 0.72.133 不包含此模块
- `@react-native-oh-tpl/react-native-safe-area-context` 的 TurboModule 需要通过 CMake 编译 C++ 代码，需要额外配置 CMake 构建流程

因此在当前 RNOH 版本下，采用 **JS Stub** 方案：在 Metro 打包时将这些库替换为纯 JS 实现，不依赖任何鸿蒙原生模块。

### 8.2 Stub 列表

| 原库 | Stub 文件 | 说明 |
|------|-----------|------|
| `react-native-screens` | `src/stubs/react-native-screens.js` | 简单 View 包装，提供 Screen/ScreenContainer 等空组件 |
| `react-native-safe-area-context` | `src/stubs/react-native-safe-area-context.js` | 返回 0 inset 的 SafeAreaProvider/SafeAreaView |
| `@react-navigation/native` | `src/stubs/@react-navigation-native.js` | NavigationContainer 包装为 View，提供空导航函数 |
| `@react-navigation/native-stack` | `src/stubs/@react-navigation-native-stack.js` | **自定义 JS 导航栈**（核心实现，见 8.3） |

### 8.3 自定义 JS 导航栈

`@react-navigation/native-stack` 的 Stub 实现了一个完整的 JS 端导航栈，不依赖任何原生屏幕组件：

```
StackProvider (管理 stack 状态 + BackHandler)
  └─ Navigator
       └─ Screen (根据 current.name 条件渲染)
```

**核心特性：**
- 纯 JS 状态管理（`useState`），使用数组模拟导航栈
- `navigate(name, params)` → push 新页面到栈顶
- `goBack()` → 弹出栈顶页面
- **物理返回键支持**：通过 `BackHandler` 监听 `hardwareBackPress` 事件，栈深度 > 1 时在 RN 内部返回，栈深度 = 1 时通知原生侧退出

### 8.4 Metro 配置

```javascript
// metro.config.js
const harmonyStubs = {
  'react-native-screens': path.resolve(__dirname, 'src/stubs/react-native-screens.js'),
  'react-native-safe-area-context': path.resolve(__dirname, 'src/stubs/react-native-safe-area-context.js'),
  '@react-navigation/native': path.resolve(__dirname, 'src/stubs/@react-navigation-native.js'),
  '@react-navigation/native-stack': path.resolve(__dirname, 'src/stubs/@react-navigation-native-stack.js'),
};

const originalResolveRequest = harmonyConfig.resolver.resolveRequest;
harmonyConfig.resolver.resolveRequest = (ctx, moduleName, platform) => {
  // 只在 harmony 平台使用 stub，Android/iOS 不受影响
  if (platform === 'harmony' && harmonyStubs[moduleName]) {
    return { type: 'sourceFile', filePath: harmonyStubs[moduleName] };
  }
  return originalResolveRequest(ctx, moduleName, platform);
};
```

> Stub 只在 `platform === 'harmony'` 时生效，**不影响 Android 和 iOS 平台**的原生库行为。

### 8.5 后续去掉 Stub 的条件

当满足以下条件时可以逐步移除 Stub，改用鸿蒙原生库：

1. **升级 RNOH 到支持 `generated` 模块的版本**（解决 screens 包兼容性）
2. **配置 CMake 编译 C++ TurboModule**（解决 safe-area-context 的 C++ 依赖）
3. 安装 `@react-native-oh-tpl/react-native-screens` 和 `@react-native-oh-tpl/react-native-safe-area-context` 鸿蒙适配包
4. 两个原生包可用后，`@react-navigation/native` 和 `@react-navigation/native-stack` 的 Stub 也可一并移除（标准版 react-navigation 可直接使用）

## 九、物理返回键适配

### 9.1 问题描述

鸿蒙混合开发中，物理返回键的默认行为是直接弹出整个鸿蒙页面（包含所有 RN 内容），不会经过 RN 导航栈。这导致：

- 从原生页面进入 RN 页面 → 点击按钮进入二级 RN 页面 → 按物理返回键 → **直接回到原生页面**（期望：回到 RN 一级页面）
- 在 RN 根页面按返回键 → **无反应**（期望：回到原生页面）

### 9.2 解决方案

需要鸿蒙原生侧和 RN JS 侧配合处理：

```
用户按物理返回键
    │
    ▼
┌─────────────────────────┐
│  RNPage.ets             │
│  onBackPressed 拦截     │
│  dispatchBackPress()    │─── 转发给 RN BackHandler
│  return true            │─── 拦截原生默认行为
└─────────────────────────┘
    │
    ▼
┌─────────────────────────┐
│  Stub BackHandler       │
│  hardwareBackPress 事件 │
│                         │
│  栈深度 > 1:            │
│    RN 内部 goBack()     │─── 正常返回上一页
│    return true          │
│                         │
│  栈深度 = 1（根页面）:   │
│    BackHandler.exitApp()│─── 触发 defaultBackPressHandler
│    return true          │
└─────────────────────────┘
    │ (根页面时)
    ▼
┌─────────────────────────┐
│  EntryAbility.ets       │
│  defaultBackPressHandler│
│  HMRouterMgr.pop()      │─── 弹出 RN 页面，回到原生
└─────────────────────────┘
```

### 9.3 鸿蒙原生侧改动

**EntryAbility.ets** — 设置 `defaultBackPressHandler`，在 RN 根页面时返回原生：

```typescript
import { HMRouterMgr } from '@hadss/hmrouter';

// RNInstancesCoordinator.create 的第一个参数中
defaultBackPressHandler: () => {
  HMRouterMgr.pop(); // 弹出 RN 页面，回到原生页面
},
```

**RNPage.ets** — 拦截物理返回键，转发给 RN：

```typescript
aboutToAppear(): void {
  const owner = HMRouterMgr.getCurrentLifecycleOwner();
  owner?.addObserver(HMLifecycleState.onBackPressed, () => {
    this.rnohCoreContext?.dispatchBackPress(); // 转发给 RN BackHandler
    return true; // 拦截原生默认行为，防止整个 RN 页面被弹出
  });
}
```

### 9.4 RN JS 侧改动

**Stub 导航栈**（`src/stubs/@react-navigation-native-stack.js`）中添加 BackHandler 监听：

```javascript
import { BackHandler } from 'react-native';

useEffect(() => {
  const subscription = BackHandler.addEventListener('hardwareBackPress', () => {
    let handled = false;
    setStack(prev => {
      if (prev.length > 1) {
        handled = true;
        return prev.slice(0, -1); // RN 内部返回上一页
      }
      return prev;
    });
    if (!handled) {
      // 已在根页面，通知原生侧返回
      BackHandler.exitApp();
    }
    return true; // 始终拦截
  });
  return () => subscription.remove();
}, []);
```

### 9.5 关键 API 说明

| API | 作用 |
|-----|------|
| `rnohCoreContext.dispatchBackPress()` | 原生→RN：向所有 RN 实例发送 `hardwareBackPress` 事件 |
| `BackHandler.addEventListener('hardwareBackPress', handler)` | RN JS：监听物理返回键事件，返回 `true` 表示已处理 |
| `BackHandler.exitApp()` | RN→原生：触发 `invokeDefaultBackPressHandler()` → `defaultBackPressHandler()` |
| `HMRouterMgr.pop()` | 鸿蒙路由：弹出当前页面，回到上一个原生页面 |
| `onBackPressed` 返回 `true` | 鸿蒙页面：拦截返回键，阻止默认页面弹出行为 |

### 9.6 注意事项

1. **仅 Harmony 平台受影响**：Android 的返回键由 React Navigation 自动处理，不需要额外适配
2. **`dispatchBackPress()` 是异步的**：返回值为 `void`，无法同步获取 RN 是否处理了返回事件，因此采用始终拦截 + RN 侧主动通知原生的策略
3. **Stub 场景下的实现**：如果后续去掉 Stub 改用原生 `react-native-screens`，React Navigation 会自动注册 BackHandler 处理导航栈返回，但仍需要 `RNPage.ets` 中的拦截和 `EntryAbility.ets` 中的 `defaultBackPressHandler`
