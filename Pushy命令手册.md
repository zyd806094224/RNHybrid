# Pushy (react-native-update) 常用命令手册

**项目信息**: RNHybrid / react-native-update v10.39.1 / CLI v2.9.7

---

## 1. 账号管理

| 命令 | 说明 |
|------|------|
| `pushy login [email] [pwd]` | 登录热更新开放平台 |
| `pushy logout` | 登出并清除本地登录信息 |
| `pushy me` | 查看当前登录状态和用户信息 |

---

## 2. 应用管理

| 命令 | 说明 |
|------|------|
| `pushy createApp` | 创建应用并绑定到当前工程 |
| `pushy deleteApp [appId]` | 删除已有应用（含所有包和热更版本） |
| `pushy apps` | 查看已创建的全部应用 |
| `pushy selectApp [appId]` | 绑定应用到当前工程 |

`createApp` 可选参数：`--platform` (ios/android/harmony)、`--name`、`--downloadUrl`

---

## 3. 原生包管理

| 命令 | 说明 |
|------|------|
| `pushy uploadIpa [ipaFile]` | 上传 iOS ipa 文件 |
| `pushy uploadApk [apkFile]` | 上传 Android apk 文件 |
| `pushy uploadAab [aabFile]` | 上传 Android aab 文件 |
| `pushy uploadApp [appFile]` | 上传 Harmony app 文件 |
| `pushy packages` | 查看已上传的原生包 |

上传时可加 `--note` 添加备注。

---

## 4. 热更新打包与发布（核心流程）

### 4.1 生成热更包

```bash
pushy bundle --platform android
```

**常用参数：**

| 参数 | 说明 |
|------|------|
| `--platform` | ios / android / harmony |
| `--entryFile` | 入口脚本文件 |
| `--output` | ppk 文件输出路径 |
| `--dev` | 是否打包开发版本 |
| `--sourcemap` | 是否生成 sourcemap |
| `--rncli` | 指定使用 RN 官方命令行打包 |
| `--expo` | 指定使用 Expo 命令行打包 |

### 4.2 发布热更新

```bash
pushy publish [ppkFile] --platform android --name "1.0.1" --description "修复xxx"
```

**可选参数：**

| 参数 | 说明 |
|------|------|
| `--name` | 热更新版本名 |
| `--description` | 版本描述，可展示给用户 |
| `--metaInfo` | 元信息，保存额外数据 |

### 4.3 绑定热更新到原生包

```bash
pushy update --platform android --versionId <id> --packageVersion "1.0.0"
```

**绑定方式（多选一）：**

| 参数 | 说明 |
|------|------|
| `--packageId` | 按原生包 ID 绑定 |
| `--packageVersion` | 按原生包版本名绑定 |
| `--minPackageVersion` | 绑定 >= 此版本的原生包 |
| `--maxPackageVersion` | 绑定 <= 此版本的原生包 |
| `--packageVersionRange` | 按 semver 范围绑定 |
| `--rollout` | 灰度百分比 (1-100)，默认 100 |
| `--dryRun` | 仅预览，不实际绑定 |

---

## 5. 一键打包发布（推荐）

从 CLI v1.44.2 起，`pushy bundle` 可直接带发布参数，省去分步操作：

```bash
# 打包 + 发布 + 绑定，一步完成
pushy bundle --platform android \
  --name "1.0.1" \
  --description "修复登录bug" \
  --packageVersion "1.0.0"
```

---

## 6. 版本查询

| 命令 | 说明 |
|------|------|
| `pushy versions` | 分页查看热更新版本列表 |
| `pushy packages` | 查看原生包列表 |
| `pushy updateVersionInfo` | 更新版本信息 |
| `pushy deleteVersion` | 删除热更新版本 |
| `pushy deletePackage` | 删除原生包 |

---

## 7. 差分包生成

| 命令 | 说明 |
|------|------|
| `pushy diff [origin] [next]` | 两个 ppk 文件生成差异包 |
| `pushy hdiff [origin] [next]` | 同上（hdiff 算法） |
| `pushy diffFromApk [apk] [next]` | apk -> ppk 差异包 |
| `pushy diffFromIpa [ipa] [next]` | ipa -> ppk 差异包 |

> 使用热更新开放平台时通常无需手动执行差异包命令，平台会自动生成。

---

## 8. 文件解析

| 命令 | 说明 |
|------|------|
| `pushy parseApk [apkFile]` | 解析 apk 信息（版本号、时间戳等） |
| `pushy parseIpa [ipaFile]` | 解析 ipa 信息 |
| `pushy parseApp [appFile]` | 解析 Harmony app 信息 |

---

## 9. 工作流命令（CLI v2.x）

| 命令 | 说明 |
|------|------|
| `pushy workflow incremental-build` | 增量构建工作流 |
| `pushy workflow setup-app` | 新应用初始化配置 |
| `pushy workflow manage-apps` | 多应用管理工作流 |
| `pushy workflow auth-check` | 认证状态检查 |
| `pushy workflow login-flow` | 完整登录流程 |

---

## 10. 典型操作流程

```bash
# 1. 登录
npx pushy login

# 2. 创建/选择应用
npx pushy createApp --platform android --name RNHybrid
npx pushy selectApp <appId> --platform android

# 3. 上传原生包（首次或版本升级时）
npx pushy uploadApk app-release.apk --note "v1.0.0正式版"

# 4. 打包热更新
npx pushy bundle --platform android

# 5. 发布热更新并绑定
npx pushy publish <output>.ppk --platform android --name "1.0.1"
npx pushy update --platform android --versionId <id> --packageVersion "1.0.0"

# 或使用一键命令（步骤4+5合并）
npx pushy bundle --platform android --name "1.0.1" --packageVersion "1.0.0"
```

---

## 本项目配置

- `update.json`: appId=32422, appKey=`iE2tRmGMuFRkLnbsmpApZLHV`
- `App.js`: 已集成 `Pushy` 客户端 + `UpdateProvider`

---

## 参考链接

- [命令行工具（内置） - Pushy 极速热更新](https://pushy.reactnative.cn/docs/cli)
- [代码集成 - Pushy 极速热更新](https://pushy.reactnative.cn/docs/integration)
- [reactnativecn/react-native-update (GitHub)](https://github.com/reactnativecn/react-native-update)
