# HarmonyOS 集成 React Native

本文说明轻匣 HarmonyOS 原生宿主接入 React Native 的当前实现。项目整体架构与三端差异见 [技术架构说明](technical-architecture.md)，HarmonyOS 平台概览见 [HarmonyOS 平台说明](../harmony/README.md)。

## 1. 集成范围

HarmonyOS 使用 ArkTS/ArkUI 实现启动页、主页、我的和登录，通过 RNOH `RNApp` 承载账号、备忘等 React Native 共享业务页面。

核心依赖：

| 依赖 | 当前版本或配置 |
|------|----------------|
| React Native | 0.72.5 |
| `@rnoh/react-native-openharmony` | 0.72.133 |
| `@react-native-oh/react-native-harmony` | ^0.72.53-1 |
| `react-native-update` | ^10.39.1 |
| 兼容 SDK | 5.0.4(16) |
| 目标 SDK | 6.0.0(20) |

RNOH 版本在 `harmony/oh-package.json5` 中锁定，升级时需要同步验证 ArkTS、C++ Package、第三方原生模块和 RN 页面。

## 2. 相关结构

```text
harmony/
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/EntryAbility.ets
│       │   ├── pages/RNPage.ets
│       │   └── RNPackagesFactory.ets
│       ├── cpp/
│       │   ├── CMakeLists.txt
│       │   └── PackageProvider.cpp
│       └── resources/rawfile/
│           ├── bundle.harmony.js
│           └── meta.json
├── common/
│   ├── component/          # AuthManager、路由、公共组件
│   ├── network/            # HarmonyOS 原生网络层
│   └── lib_rn/             # AuthTurboModule 等 RN 公共能力
└── features/               # 原生业务特性模块
```

## 3. RNOH 初始化

`EntryAbility.ets` 在应用启动时完成以下工作：

- 创建 `RNInstancesCoordinator` 并保存 `RNOHCoreContext`。
- Debug 模式配置 Metro `localhost:8081`。
- 配置 RN 根页面返回到原生 HMRouter 的默认处理。
- 初始化原生登录态管理器。
- 将自签名服务证书复制到应用沙箱，供原生请求和 RN 请求使用。

RNOH 上下文通过 `AppStorage` 提供给 `RNPage`。RN 实例由协调器统一管理，避免页面重复创建底层运行环境。

## 4. RN 容器

`harmony/entry/src/main/ets/pages/RNPage.ets` 使用 RNOH `RNApp` 创建共享业务页面：

```typescript
RNApp({
  rnInstanceConfig: {
    createRNPackages,
    enableNDKTextMeasuring: true,
    enableBackgroundExecutor: false,
    enableCAPIArchitecture: true,
    arkTsComponentNames: [],
    caPathProvider: url => {
      return url.includes('configured-host')
        ? AppStorage.get<string>('serverCertPath') ?? ''
        : ''
    },
  },
  appKey: 'RNHybrid',
  initialProps: {
    param1: 'harmony',
    token: this.authManager.getToken(),
    username: this.authManager.getUsername(),
  },
  jsBundleProvider: bundleProvider,
})
```

`initialProps` 中的 Token 和用户名由原生 `AuthManager` 提供。RN 只在当前容器生命周期内使用这些数据，不负责持久化。

## 5. Bundle 加载策略

`RNPage` 使用 `BuildProfile.DEBUG` 区分加载策略：

```typescript
if (BuildProfile.DEBUG) {
  return new AnyJSBundleProvider([
    new MetroJSBundleProvider(),
    new ResourceJSBundleProvider(resourceManager, 'bundle.harmony.js'),
  ])
}

return new AnyJSBundleProvider([
  new PushyFileJSBundleProvider(context),
  new ResourceJSBundleProvider(resourceManager, 'bundle.harmony.js'),
])
```

| 构建模式 | 加载顺序 |
|----------|----------|
| Debug | Metro → rawfile 内置 Bundle |
| Release | Pushy 已下载更新包 → rawfile 内置 Bundle |

Debug 下 Metro 无法连接时，`AnyJSBundleProvider` 会加载 rawfile 内置 Bundle，且不会读取 Pushy 热更新文件。Metro 已连接但返回 Bundle 编译错误时，RNOH 会展示开发错误，不会回退旧 Bundle。Release 发布前必须确认内置 `bundle.harmony.js` 可用，确保热更新包不存在或加载失败时仍能进入业务页面。

刷新 Debug 兜底 Bundle：

```bash
npm run bundle:harmony:debug-fallback
```

生成 Release 内置 Bundle：

```bash
npm run bundle:harmony:release
```

两个命令都会覆盖同一个 `bundle.harmony.js`，构建 HAP 前应执行与目标构建模式对应的命令。生成命令同时更新 `rawfile/assets/`，这些静态资源需要与 Bundle 一起提交。

## 6. Package 注册

ArkTS Package 在 `RNPackagesFactory.ets` 中注册：

```typescript
export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [
    new PushyPackage(ctx),
    new AuthPackage(ctx),
  ]
}
```

C++ Package 在 `PackageProvider.cpp` 中注册。新增带 C++ 实现的 TurboModule 时，需要同时更新 CMake、Package Provider 和 ArkTS Package Factory，并重新构建原生应用。

## 7. 鉴权桥接

### 登录态注入

HarmonyOS `AuthManager` 使用 ArkData Preferences `auth_prefs` 持久化 Token 和用户名。进入 `RNPage` 时，原生层通过 `initialProps` 将登录态注入 RN。

### Token 失效

```text
RN 请求返回 401
  → RN 调用 AuthModule.onTokenExpired()
  → AuthTurboModule.tokenExpiredCallback
  → 原生 AuthManager.logout()
  → HMRouter 弹出 RNPage
  → HMRouter 打开 LoginPage
```

`AuthTurboModule` 需要防止多个并发 401 重复触发登录跳转，并在 `RNPage` 消失时清理回调状态。

## 8. 返回键处理

HarmonyOS 原生返回事件需要先交给 RN 页面内导航处理：

```text
系统返回键
  → RNPage 拦截 onBackPressed
  → RNOH dispatchBackPress()
  → RN BackHandler
      ├─ RN 栈深度 > 1：RN 内部返回
      └─ RN 根页面：触发原生默认返回
  → HMRouter 弹出 RNPage
```

`RNPage` 始终拦截当前返回事件，RN 在到达根页面后主动通知原生返回，避免直接退出整个 RN 容器。

## 9. HarmonyOS Stub

当前 RNOH 版本下，部分 React Navigation 依赖没有直接可用的 HarmonyOS 原生实现，因此 `metro.config.js` 仅针对 `platform === 'harmony'` 替换为 JS Stub：

| 原模块 | Stub |
|--------|------|
| `react-native-screens` | `src/stubs/react-native-screens.js` |
| `react-native-safe-area-context` | `src/stubs/react-native-safe-area-context.js` |
| `@react-navigation/native` | `src/stubs/@react-navigation-native.js` |
| `@react-navigation/native-stack` | `src/stubs/@react-navigation-native-stack.js` |

自定义导航栈使用 JS 状态管理页面栈，并通过 `BackHandler` 配合原生返回处理。Stub 不影响 Android 和 iOS。

移除 Stub 前需要：

1. 升级并验证支持目标第三方模块的 RNOH 版本。
2. 完成相关 TurboModule/C++ 构建配置。
3. 验证安全区、页面动画、返回键和内存释放。
4. 分别验证 Debug Metro 和 Release Bundle。

## 10. 开发调试

启动 Metro：

```bash
npm start
```

真机端口转发：

```bash
hdc rport tcp:8081 tcp:8081
```

使用 DevEco Studio 打开 `harmony/`，选择 `entry` 模块运行。ArkTS、C++、依赖或资源变化后，需要重新构建应用。

## 11. Pushy 发布要点

首次绑定 HarmonyOS 应用：

```bash
npx pushy login
npx pushy createApp --platform harmony
# 或
npx pushy selectApp --platform harmony
```

生成 Bundle 并上传基线包：

```bash
npx pushy bundle --platform harmony
npx pushy uploadApp <同一次构建生成的-app-文件>
```

发布热更新：

```bash
npx pushy bundle --platform harmony
```

发布时遵守以下约束：

- 上传 Pushy 的基线包与提交应用市场的包必须来自同一次构建。
- 原生代码、权限、依赖或资源变化必须发布新的原生包。
- 新原生包发布时递增版本号，并重新验证 `pushy_build_time` 匹配。
- 热更新下载后需要重新启动应用，`PushyFileJSBundleProvider` 才会加载新 Bundle。
- `update.json`、登录凭据、App Key 和签名材料按敏感部署配置管理，不在文档中记录真实值。

更多命令见 [Pushy 命令手册](../Pushy命令手册.md)。

## 12. 验证清单

- 原生启动页可正常进入主页。
- 未登录访问受保护入口时进入登录页。
- 登录成功后 RN 页面收到 Token 和用户名。
- RN 请求可访问目标 HTTPS 服务。
- 401 后仅打开一次登录页并清除登录态。
- RN 二级页面返回到 RN 上一级，RN 根页面返回原生页。
- Release 模式可从内置 Bundle 启动。
- Pushy 更新包可下载，并在重启后生效。
