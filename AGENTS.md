# Repository Guidelines

## Project Structure & Module Organization
本仓库是一个 React Native 混合移动工程，原生宿主覆盖 Android、iOS 和 HarmonyOS。共享 RN 代码位于 `src/`：页面在 `src/screens/`，导航在 `src/navigation/`，接口封装在 `src/api/`，全局状态在 `src/context/`，复用组件在 `src/components/`。平台工程分别位于 `android/`、`ios/` 和 `harmony/`。Android 包含 `app`、`lib_rn`、`lib_network`、`lib_framework` 等模块；Harmony 使用 `entry/`、`common/`、`features/` 的模块化结构。RN 离线包、证书等资源放在各平台资源目录，例如 `android/app/src/main/assets/` 和 `harmony/entry/src/main/resources/rawfile/`。

## Build, Test, and Development Commands
执行 `npm install` 安装 JS 依赖。使用 `npm start` 启动 Metro。使用 `npm run android` 或 `npm run ios` 运行对应原生 RN 目标。使用 `npm run dev` 通过 `react-native bundle-harmony --dev` 构建 Harmony RN bundle。Android 调试包可通过 `cd android && ./gradlew assembleDebug` 构建。Harmony 应用构建和调试建议使用 DevEco Studio。

## Coding Style & Naming Conventions
JavaScript 和 TypeScript 遵循 `.eslintrc.js` 中的 React Native ESLint 配置，以及 `.prettierrc.js` 中的 Prettier 规则：单引号、对象括号内无空格、保留尾随逗号、单参数箭头函数省略括号。React 组件和页面使用 PascalCase，例如 `AccountListScreen.js`。接口模块按业务域使用小写命名，例如 `src/api/account.js`。

## Testing Guidelines
Jest 已配置 React Native preset，JS 测试通过 `npm test` 运行。测试发现范围应限制在项目代码内，避免扫描 `node_modules` 或 Harmony `oh_modules` 等生成依赖。Android 单元测试和仪器测试分别位于 `src/test` 与 `src/androidTest`；Harmony 测试位于各模块的 `src/test` 和 `src/ohosTest`。

## Commit & Pull Request Guidelines
Git 历史使用简短中文提交说明，例如 `备忘录页面调整个人信息显示位置`、`RN项目结构工程化`。提交应聚焦单一变更，并清楚描述目的。Pull Request 需要包含变更摘要、影响平台、测试结果；涉及 UI 的改动应附截图或录屏。有关联 issue 时在描述中注明。

## Security & Configuration Tips
不要向源码仓库新增密钥、签名凭据或生产 token。服务地址、app key、证书和 release 签名信息应优先通过环境配置或 CI 注入，避免硬编码到业务代码或构建脚本中。
