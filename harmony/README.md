# HarmonyOS 平台说明

HarmonyOS 工程是轻匣的 ArkTS/ArkUI 原生宿主，通过 RNOH 承载 React Native 共享业务页面。原生层负责启动页、主页、我的、登录、HMRouter 导航、登录态持久化和 RN 生命周期。

## 模块结构

```text
harmony/
├── AppScope/             # 应用级配置、名称和图标资源
├── entry/                # 应用入口、启动页、主页面、登录页、RNPage
├── common/
│   ├── component/        # 公共组件、路由、AuthManager
│   ├── network/          # 原生网络层
│   └── lib_rn/           # RN 公共能力和 AuthTurboModule
├── features/             # 原生业务特性模块
├── build-profile.json5   # 产品、SDK 和模块配置
└── oh-package.json5      # HarmonyOS 依赖
```

当前产品配置兼容 SDK 为 `5.0.4(16)`，目标 SDK 为 `6.0.0(20)`；RNOH 版本锁定为 `0.72.133`。

## 页面流程

```text
EntryAbility
  → 初始化 HMRouter、RNOH、AuthManager 和证书路径
  → Launcher
  → Main
      ├─ 主页特性模块
      └─ 我的特性模块

受保护入口
  → 未登录时进入 LoginPage
  → 登录成功后进入 RNPage
```

`RNPage` 使用 RNOH `RNApp` 承载共享业务页面，并通过 `initialProps` 注入 Token 和用户名。系统返回事件先转发给 RN 导航栈，RN 到达根页面后再由 HMRouter 返回原生页面。

## 鉴权实现

- `AuthManager` 使用 ArkData Preferences `auth_prefs` 持久化 Token 和用户名。
- `AuthTurboModule` 接收 RN 的 Token 失效通知。
- RN 收到 401 后，原生层退出登录、弹出 RN 页面并进入登录页。

Preferences 属于通用持久化方案。生产环境如需更高安全等级，应迁移到 HarmonyOS 安全凭据能力或增加系统密钥保护的加密层。

## RN Bundle

`RNPage` 根据 `BuildProfile.DEBUG` 选择 Bundle：

- Debug：`MetroJSBundleProvider` → `ResourceJSBundleProvider`。
- Release：`PushyFileJSBundleProvider` → `ResourceJSBundleProvider`。

Debug 下 Metro 无法连接时，会回退到 `entry/src/main/resources/rawfile/bundle.harmony.js`，且不会读取 Pushy 热更新文件。Metro 已连接但返回 Bundle 编译错误时，会保留开发错误页面，不会回退旧 Bundle。

详细集成、Stub 机制和返回键处理见 [HarmonyOS 集成 React Native](../docs/harmony-rn-integration.md)。

## 构建与调试

1. 使用 DevEco Studio 打开 `harmony/`。
2. 等待依赖同步，选择 `entry` 模块和目标设备。
3. 运行 Debug 或 Release 构建。

启动 Metro：

```bash
npm start
```

真机连接 Metro 时配置端口转发：

```bash
hdc rport tcp:8081 tcp:8081
```

刷新 Debug 模式的 HAP 内置 RN 兜底 Bundle：

```bash
npm run bundle:harmony:debug-fallback
```

发布 Release 前生成生产模式内置 Bundle：

```bash
npm run bundle:harmony:release
```

两个命令都会覆盖同一个 `entry/src/main/resources/rawfile/bundle.harmony.js`，构建 HAP 前应执行与目标构建模式对应的命令。

## 应用名称、图标与启动页

- 应用显示名称：`轻匣`
- 应用名称资源：`harmony/AppScope/resources/base/element/string.json`
- 应用图标资源：`harmony/AppScope/resources/base/media/`
- 原生启动页：`harmony/entry/src/main/ets/pages/Launcher.ets`

## 关键文件

| 文件 | 作用 |
|------|------|
| `entry/src/main/ets/entryability/EntryAbility.ets` | 应用与 RNOH 初始化 |
| `entry/src/main/ets/pages/Launcher.ets` | 原生启动页 |
| `entry/src/main/ets/pages/Main.ets` | 原生主页面 |
| `entry/src/main/ets/pages/LoginPage.ets` | 原生登录页 |
| `entry/src/main/ets/pages/RNPage.ets` | RN 容器和 Bundle Provider |
| `common/component/src/main/ets/auth/AuthManager.ets` | 登录态持久化 |
| `common/lib_rn/src/main/ets/rn/AuthTurboModule.ets` | RN 到原生鉴权桥 |
