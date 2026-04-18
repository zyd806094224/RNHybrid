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
            reactInstanceManager = ReactInstanceManager.builder()
                .setApplication(application)
                .setCurrentActivity(currentActivity)
                .setJSBundleFile(UpdateContext.getBundleUrl(application, "assets://index.android.bundle"))
                .setJSMainModulePath("index")
                .addPackage(MainReactPackage())
                .addPackage(RNScreensPackage())
                .addPackage(SafeAreaContextPackage())
                .addPackage(UpdatePackage())
                .setUseDeveloperSupport(true)
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .build()
            UpdateContext.setCustomInstanceManager(reactInstanceManager)
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
