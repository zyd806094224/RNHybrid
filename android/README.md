# Android 平台说明

Android 工程是轻匣的 Kotlin 原生宿主，负责启动页、主页、我的、登录、原生导航、登录态持久化和 React Native 容器。

## 模块结构

```text
android/
├── app/             # 应用入口、主页、我的、登录与路由
├── lib_rn/          # RN 容器、实例管理、原生桥与网络适配
├── lib_network/     # Retrofit/OkHttp 网络基础能力
└── lib_framework/   # 通用 Activity、Fragment、组件和工具
```

## 页面与路由

```text
SplashActivity
  → MainActivity
      ├─ HomeFragment
      └─ MineFragment

受保护入口
  → LoginInterceptor 判断登录态
  → 未登录时打开 LoginActivity
  → 登录成功后恢复目标路由
  → RNPageActivity 承载共享业务页
```

原生路由使用 ARouter，主页与我的使用 Android Navigation 组织。`RNPageActivity` 创建 `ReactRootView`，并复用 `ReactNativeManager` 管理的全局 `ReactInstanceManager`。

## 鉴权实现

- `AuthManager` 使用 MMKV 持久化 `auth_token` 和 `auth_username`。
- 进入 RN 页面时，通过初始属性注入 Token 和用户名。
- RN 接口收到 401 后调用 `AuthModule.onTokenExpired()`。
- 原生侧清除登录态、关闭 RN 页面并打开登录页。
- `AuthModule` 使用防重入状态，避免多个并发 401 重复跳转登录。

MMKV 是通用持久化方案，不等同于系统安全凭据存储。生产环境如需更高安全等级，应增加 Android Keystore 保护的加密存储。

## RN Bundle

- Debug：连接 Metro，不指定本地 Bundle。
- Release：通过 `UpdateContext.getBundleUrl()` 加载 Pushy 更新包，未命中时回退到 `app/src/main/assets/index.android.bundle`。

## 构建与运行

在项目根目录执行：

```bash
npm install
npm start
npm run android
```

构建 Debug APK：

```bash
cd android
./gradlew assembleDebug
```

## 应用名称、图标与启动页

- 应用显示名称：`轻匣`
- 应用名称资源：`app/src/main/res/values/strings.xml`
- 应用图标：`app/src/main/res/mipmap-*/ic_qingxia_launcher*`
- 原生启动页：`app/src/main/java/com/example/rnandroiddemo/SplashActivity.kt`
- 启动页布局：`app/src/main/res/layout/activity_splash.xml`
- 启动页品牌图片：`app/src/main/res/drawable-nodpi/img_splash_qingxia.png`

Release 签名信息应通过本地配置或 CI 注入，不应提交生产凭据。

## 关键文件

| 文件 | 作用 |
|------|------|
| `app/src/main/java/com/example/rnandroiddemo/MyApplication.kt` | 应用初始化 |
| `app/src/main/java/com/example/rnandroiddemo/auth/AuthManager.kt` | 登录态持久化 |
| `app/src/main/java/com/example/rnandroiddemo/auth/LoginInterceptor.kt` | 受保护路由拦截 |
| `lib_rn/src/main/java/com/example/rnandroiddemo/rn/RNPageActivity.kt` | RN 容器页面 |
| `lib_rn/src/main/java/com/example/rnandroiddemo/rn/ReactNativeManager.kt` | RN 实例和 Bundle 管理 |
| `lib_rn/src/main/java/com/example/rnandroiddemo/rn/AuthModule.kt` | RN 到原生鉴权桥 |
