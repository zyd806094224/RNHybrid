# RNHybrid - React Native Hybrid Application 示例项目

这是一个展示如何在现有 Android 原生应用中集成 React Native 的混合开发示例项目。该项目演示了如何在一个 Android 应用中嵌入 React Native 页面，并实现原生与 RN 页面之间的导航跳转。

## 项目概述

本项目基于 React Native 0.66.2 版本构建，集成了 React Navigation 作为页面路由管理框架。通过该项目可以学习如何在现有 Android 项目中集成 React Native 模块，以及如何进行原生与 RN 之间的通信和页面跳转。

### 核心技术栈

- React Native: 0.66.2
- React: 17.0.2
- React Navigation: 6.x
- Android SDK

## 项目结构

```
.
├── android/                    # Android 原生代码目录
│   ├── app/                    # Android 应用主模块
│   │   ├── src/                # Java 源码目录
│   │   │   ├── main/           # 主代码目录
│   │   │   │   ├── java/       # Java/Kotlin 源文件
│   │   │   │   └── res/        # 资源文件
│   │   │   └── AndroidManifest.xml  # Android 配置文件
├── src/                        # React Native 源码目录
│   ├── components/             # 可复用的 UI 组件
│   ├── navigation/             # 导航路由配置
│   ├── screens/                # 页面组件
├── App.js                      # React Native 根组件
├── index.js                    # React Native 入口文件
└── package.json                # Node.js 项目配置文件

```

## 功能特性

1. React Native 与 Android 原生混合开发完整示例
2. 工程化的代码结构，按功能模块清晰划分
3. 集成 React Navigation 路由框架实现页面导航
4. 展示原生页面与 React Native 页面间的相互跳转
5. 支持 Android 原生生命周期管理与 React Native 生命周期的整合

## React Navigation 路由配置

项目使用 React Navigation 6.x 实现页面路由功能，当前包含以下页面：

- HomeScreen: 主页，展示基础导航功能
- DetailsScreen: 详情页示例
- ProfileScreen: 个人中心页示例

导航结构通过 [AppNavigator.js](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/src/navigation/AppNavigator.js) 文件配置，采用 Stack Navigator 实现页面堆栈式导航。

## 项目依赖说明

### 核心依赖

```json
"dependencies": {
  "react": "17.0.2",
  "react-native": "0.66.2",
  "@react-navigation/native": "^6.1.18",
  "@react-navigation/native-stack": "^6.11.0",
  "react-native-safe-area-context": "3.4.1",
  "react-native-screens": "3.13.1"
}
```

### 开发依赖

```json
"devDependencies": {
  "@babel/core": "^7.12.9",
  "@babel/runtime": "^7.12.5",
  "@react-native-community/eslint-config": "^2.0.0",
  "babel-jest": "^26.6.3",
  "eslint": "7.14.0",
  "jest": "^26.6.3",
  "metro-react-native-babel-preset": "^0.64.0",
  "react-test-renderer": "17.0.2"
}
```

## 运行项目

### 环境要求

- Node.js = 16.x
- Java JDK 11 或以上
- Android Studio 和 Android SDK
- React Native CLI

### 安装步骤

1. 克隆项目后，进入项目根目录并安装 JS 依赖:
   ```bash
   npm install
   ```

2. 启动 Metro Server:
   ```bash
   npx react-native start
   ```

3. 在另一个终端窗口中运行 Android 应用:
   ```bash
   npx react-native run-android
   ```

或者直接构建 Android 项目:

```bash
cd android && ./gradlew assembleDebug
```

### 安装 APK 到设备

构建完成后，可以通过以下命令安装 APK 到连接的设备:

```bash
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

## 代码结构说明

- [src/components](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/src/components): 存放可复用的 UI 组件，如按钮、输入框等
- [src/navigation](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/src/navigation): 存放路由配置相关代码，管理整个应用的页面导航
- [src/screens](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/src/screens): 存放页面级组件，每个页面作为一个独立组件
- [App.js](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/App.js): React Native 应用的根组件
- [index.js](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/index.js): 应用的注册入口文件

## 混合开发关键点

### Android 集成 RN 页面

项目中的 `RNPageActivity.java` 是一个完整的 React Native 页面 Activity 实现，展示了如何在 Android 原生应用中加载和显示 React Native 页面。

关键代码包括:

1. 创建 ReactRootView 和 ReactInstanceManager
2. 配置 React Native 包和依赖
3. 正确处理生命周期事件（onResume, onPause, onDestroy）
4. 处理返回键事件以支持 React Native 页面导航

### 页面导航

页面间导航通过 React Navigation 提供的 navigation prop 实现:

```javascript
// 跳转到指定页面
navigation.navigate('Details')

// 返回上一页
navigation.goBack()
```

## 开发注意事项

1. 当修改原生代码后，需要重新编译 Android 项目
2. React Native 代码修改后，可通过摇晃设备或执行 `npx react-native start` 重启开发服务器来刷新
3. 注意正确处理 Android 和 React Native 的生命周期，避免内存泄漏
4. 如需添加新的 React Navigation 页面，需要在 [AppNavigator.js](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/src/navigation/AppNavigator.js) 中注册相应路由
