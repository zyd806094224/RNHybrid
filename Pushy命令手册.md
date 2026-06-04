# Pushy 常用命令手册

本项目使用 `react-native-update` 提供 React Native Bundle 更新能力。Android、iOS、HarmonyOS 需要分别创建和绑定 Pushy 应用，各平台 App Key 独立。

> App ID、App Key、登录凭据和签名材料属于部署配置。真实值不在文档中记录，提交仓库前应按团队安全策略检查 `update.json` 和本地配置。

## 1. 账号与应用

```bash
npx pushy login
npx pushy logout
npx pushy me

npx pushy apps
npx pushy createApp --platform <android|ios|harmony>
npx pushy selectApp <appId> --platform <android|ios|harmony>
```

应用绑定信息由 CLI 写入根目录 `update.json`。三端应分别选择正确的平台应用，避免将热更新绑定到错误原生包。

## 2. 上传原生基线包

| 平台 | 命令 |
|------|------|
| Android APK | `npx pushy uploadApk <apk-file>` |
| Android AAB | `npx pushy uploadAab <aab-file>` |
| iOS IPA | `npx pushy uploadIpa <ipa-file>` |
| HarmonyOS APP | `npx pushy uploadApp <app-file>` |

可使用 `--note` 添加基线包备注：

```bash
npx pushy uploadApk <apk-file> --note "1.0.0 production"
```

上传的基线包和实际发布包应来自同一次构建，尤其是 HarmonyOS，重新构建会改变 `pushy_build_time`。

## 3. 生成与发布热更新

交互式生成和发布：

```bash
npx pushy bundle --platform android
npx pushy bundle --platform ios
npx pushy bundle --platform harmony
```

常用参数：

| 参数 | 说明 |
|------|------|
| `--platform` | `android`、`ios` 或 `harmony` |
| `--entryFile` | RN 入口文件 |
| `--output` | PPK 输出路径 |
| `--dev` | 生成开发 Bundle |
| `--sourcemap` | 生成 sourcemap |
| `--name` | 更新版本名称 |
| `--description` | 更新说明 |
| `--packageVersion` | 绑定目标原生包版本 |
| `--rollout` | 灰度发布比例 |

分步发布：

```bash
npx pushy bundle --platform android --output <output.ppk>
npx pushy publish <output.ppk> \
  --platform android \
  --name "1.0.1" \
  --description "修复登录问题"
npx pushy update \
  --platform android \
  --versionId <version-id> \
  --packageVersion "1.0.0"
```

打包、发布和绑定也可一次完成：

```bash
npx pushy bundle \
  --platform android \
  --name "1.0.1" \
  --description "修复登录问题" \
  --packageVersion "1.0.0"
```

## 4. 查询与维护

```bash
npx pushy versions
npx pushy packages
npx pushy updateVersionInfo
npx pushy deleteVersion
npx pushy deletePackage
```

删除应用、原生包或热更新版本会影响已发布客户端，执行前应确认平台、版本和回退方案。

## 5. 文件解析与差分

```bash
npx pushy parseApk <apk-file>
npx pushy parseIpa <ipa-file>
npx pushy parseApp <app-file>

npx pushy diff <origin.ppk> <next.ppk>
npx pushy hdiff <origin.ppk> <next.ppk>
```

使用 Pushy 服务发布时，通常不需要手动生成差分包。

## 6. 三端加载现状

| 平台 | 当前原生 Bundle 加载方式 |
|------|--------------------------|
| Android | Debug 使用 Metro 或 APK 内置兜底；Release 使用 `UpdateContext` 选择 Pushy 更新包或内置 Bundle |
| iOS | Debug 使用 Metro 或 App 内置兜底；Release 使用 `RNViewController` 自定义下载包或 App 内置 Bundle |
| HarmonyOS | Debug 使用 Metro 或 rawfile 内置兜底；Release 使用 `PushyFileJSBundleProvider` 或 rawfile 内置 Bundle |

`App.js` 已接入 `Pushy` 客户端和 `UpdateProvider`，但三端原生容器的 Release 加载方式并不完全一致。每次发布前需要分别验证基线包、更新下载、生效时机和回退行为。

## 7. 发布检查

- 仅 RN 业务代码变化才评估使用热更新。
- 原生代码、权限、依赖、资源或 SDK 变化必须发布新原生包。
- 三个平台分别选择正确 Pushy 应用和基线包。
- 发布前验证登录、401、冷启动、系统返回和离线 Bundle。
- 使用灰度发布控制风险，并保留可回退版本。
- 遵守各应用商店关于动态更新的政策。

## 参考

- [Pushy CLI](https://pushy.reactnative.cn/docs/cli)
- [Pushy 代码集成](https://pushy.reactnative.cn/docs/integration)
- [react-native-update](https://github.com/reactnativecn/react-native-update)
