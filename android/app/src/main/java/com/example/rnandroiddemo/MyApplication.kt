package com.example.rnandroiddemo

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.util.Log
import com.alibaba.android.arouter.launcher.ARouter
import com.demo.framework.helper.AppHelper
import com.demo.framework.manager.ActivityManager
import com.demo.framework.manager.AppFrontBack
import com.demo.framework.manager.AppFrontBackListener
import com.demo.framework.manager.AppManager
import com.demo.framework.utils.DeviceInfoUtils
import com.example.rnandroiddemo.auth.AuthManager
import com.example.rnandroiddemo.rn.CustomOkHttpClientFactory
import com.example.rnandroiddemo.rn.RNPageActivity
import com.facebook.react.modules.network.OkHttpClientProvider

class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        // RN OkHttp 信任自签名证书
        OkHttpClientProvider.setOkHttpClientFactory(CustomOkHttpClientFactory(this))

        // 框架初始化
        AppHelper.init(this, BuildConfig.DEBUG)
        AppManager.init(this)
        AuthManager.init(this)
        DeviceInfoUtils.init(this)

        // Activity 生命周期管理
        registerActivityLifecycle()

        // App 前后台切换监听
        AppFrontBack.register(this, object : AppFrontBackListener {
            override fun onFront(activity: Activity?) {
                Log.d("MyApplication", "App 前台")
            }

            override fun onBack(activity: Activity?) {
                Log.d("MyApplication", "App 后台")
            }
        })

        // ARouter 初始化
        if (BuildConfig.DEBUG) {
            ARouter.openLog()
            ARouter.openDebug()
        }
        ARouter.init(this)

        // RN 页面 token 过期监听：清除登录态 → 关闭 RN 页面 → 跳转登录页
        RNPageActivity.tokenExpiredListener = object : RNPageActivity.OnTokenExpiredListener {
            override fun onTokenExpired() {
                AuthManager.logout()
                val topActivity = ActivityManager.top()
                if (topActivity is RNPageActivity) {
                    topActivity.finish()
                }
                ARouter.getInstance()
                    .build("/auth/login")
                    .greenChannel()
                    .navigation()
            }
        }
    }

    private fun registerActivityLifecycle() {
        registerActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                ActivityManager.push(activity)
            }

            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityResumed(activity: Activity) {}
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}

            override fun onActivityDestroyed(activity: Activity) {
                ActivityManager.pop(activity)
            }
        })
    }
}
