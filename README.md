# Personal Manager - 移动端

个人管理系统的移动端工程，基于 React Native 构建，支持 Android、iOS、Harmony 三端运行。当前主要用于账号密码管理，后续将持续扩展其他个人管理功能。

**相关工程：**
- 前端：[Vue3SeedProject](https://github.com/zyd806094224/Vue3SeedProject)
- 后端服务：[SpringBootServiceSeedProject](https://github.com/zyd806094224/SpringBootServiceSeedProject)

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | React Native | 0.72.5 |
| 语言 | React | 18.2 |
| 语言 | TypeScript | 5.9 |
| 导航 | React Navigation | 6.x |
| 热更新 | react-native-update (Pushy) | 10.39 |
| 平台 | Android / iOS / Harmony OS | - |

## 功能特性

- **账号密码管理**：按分类（社交、工作、金融、其他）管理账号信息
- **多平台支持**：Android、iOS、Harmony OS 三端适配
- **热更新**：集成 Pushy 热更新方案，支持三端 OTA 更新
- **原生鉴权**：Android 原生层 Token 管理与 RN 层无缝共享

## 项目结构

```
├── android/                    # Android 原生工程
│   └── app/src/main/
│       ├── java/               # 原生代码（鉴权模块、RN 桥接等）
│       └── res/                # 资源文件
├── ios/                        # iOS 原生工程
│   └── Podfile                 # CocoaPods 依赖
├── harmony/                    # Harmony OS 适配
├── src/
│   ├── components/             # 可复用组件
│   ├── navigation/             # 导航路由配置
│   └── screens/                # 页面组件
│       ├── HomeScreen          # 首页
│       ├── AccountListScreen   # 账号列表
│       └── AccountEditScreen   # 账号编辑
├── App.js                      # 根组件
├── index.js                    # 入口文件
└── package.json                # 依赖配置
```

## 快速开始

### 环境要求

- Node.js >= 16
- JDK 17
- Android Studio + Android SDK（Android 开发）
- Xcode（iOS 开发）
- DevEco Studio（Harmony OS 开发）

### 安装与运行

```bash
# 安装依赖
npm install

# Android
npx react-native run-android

# iOS
cd ios && pod install && cd ..
npx react-native run-ios

# Harmony
npx react-native bundle-harmony --dev
```

### 热更新

项目集成了 Pushy 热更新平台，支持三端 OTA 更新，无需重新发布应用即可更新业务逻辑。

## 开发注意事项

- 修改原生代码后需要重新编译对应平台工程
- RN 代码修改通过 Metro 热重载即时生效
- 新增页面需在 `src/navigation/` 中注册路由

## License

MIT
