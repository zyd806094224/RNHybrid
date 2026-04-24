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
# 1. 在 DevEco 中 Build HAP（Build → Build Hap(s)）

# 2. 将 HAP 改后缀为 .app 并上传
cp harmony/entry/build/default/outputs/default/entry-default-signed.hap /tmp/entry-default-signed.app
npx pushy uploadApp /tmp/entry-default-signed.app
```

> Pushy CLI 要求鸿蒙基线包后缀为 `.app`，HAP 本质是 zip，直接改后缀即可。上传时会解析里面的 `rawfile/bundle.harmony.js` 和 `rawfile/meta.json`。

### 5.3 发布热更新

```bash
# 1. 打包热更 bundle
npx pushy bundle --platform harmony

# 2. 上传并发布（按提示操作）
#    - 是否上传：Y
#    - 输入版本名称和描述
#    - 是否应用到原生包：Y
#    - 输入原生包 id（上传基线包时获得的 id）

# 或分开操作
npx pushy uploadApp <ppk文件路径>
npx pushy publish --platform harmony
```

### 5.4 热更新生效流程

1. 用户打开 app → Pushy JS 代码检查更新 → 下载 ppk 到本地
2. 用户**关闭 app 再重新打开** → `PushyFileJSBundleProvider` 加载已下载的 bundle → 页面更新

> 热更包下载后需要**重启 app** 才能生效。

### 5.5 命令行安装 HAP

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
