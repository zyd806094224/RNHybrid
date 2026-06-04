package com.example.rnandroiddemo.rn

import android.app.Activity
import android.app.Application
import com.facebook.react.ReactInstanceManager
import com.facebook.react.common.LifecycleState
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler
import com.facebook.react.shell.MainReactPackage
import com.swmansion.rnscreens.RNScreensPackage
import com.th3rdwave.safeareacontext.SafeAreaContextPackage
import cn.reactnative.modules.update.UpdateContext
import cn.reactnative.modules.update.UpdatePackage

/**
 * ReactInstanceManager 单例管理器
 * 混编项目中 ReactInstanceManager 应全局共享，避免重复创建导致 native 库加载失败
 */
object ReactNativeManager {

    @Volatile
    private var reactInstanceManager: ReactInstanceManager? = null

    @Synchronized
    fun getReactInstanceManager(
        application: Application,
        currentActivity: Activity? = null
    ): ReactInstanceManager {
        if (reactInstanceManager == null) {
            val builder = ReactInstanceManager.builder()
                .setApplication(application)
                .setCurrentActivity(currentActivity)
                .setJSMainModulePath("index")
                .addPackage(MainReactPackage())
                .addPackage(RNScreensPackage())
                .addPackage(SafeAreaContextPackage())
                .addPackage(UpdatePackage())
                .addPackage(AuthPackage())
                .setUseDeveloperSupport(BuildConfig.DEBUG)
                .setInitialLifecycleState(LifecycleState.RESUMED)

            if (BuildConfig.DEBUG) {
                // Debug 模式优先连接 Metro；Metro 不可用时回退到 APK 内置 Bundle。
                // 不通过 UpdateContext 解析，避免 Debug 环境加载 Pushy 热更新文件。
                builder.setBundleAssetName("index.android.bundle")
            } else {
                // Release 模式：加载离线包或热更新包
                builder.setJSBundleFile(UpdateContext.getBundleUrl(application, "assets://index.android.bundle"))
            }

            reactInstanceManager = builder.build()

            if (!BuildConfig.DEBUG) {
                UpdateContext.setCustomInstanceManager(reactInstanceManager)
            }
        }
        return reactInstanceManager!!
    }

    fun onHostResume(activity: Activity, handler: DefaultHardwareBackBtnHandler) {
        reactInstanceManager?.onHostResume(activity, handler)
    }

    fun onHostPause(activity: Activity) {
        reactInstanceManager?.onHostPause(activity)
    }

    fun onBackPressed() {
        reactInstanceManager?.onBackPressed()
    }
}
