package com.example.rnandroiddemo.rn

import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import com.alibaba.android.arouter.facade.annotation.Route
import com.demo.framework.base.BaseActivity
import com.demo.framework.utils.StatusBarSettingHelper
import com.facebook.react.ReactInstanceEventListener
import com.facebook.react.ReactInstanceManager
import com.facebook.react.ReactRootView
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler
import com.example.rnandroiddemo.rn.R

/**
 * RN 载体页 Activity
 * 承载 ReactRootView，使用 ReactNativeManager 管理单例 ReactInstanceManager
 */
@Route(path = "/rn/page")
class RNPageActivity : BaseActivity(), DefaultHardwareBackBtnHandler {

    private var mReactRootView: ReactRootView? = null
    private var mReactInstanceManager: ReactInstanceManager? = null
    private var mRootContainer: FrameLayout? = null
    private var mLoadingContainer: View? = null
    private var mRnContentLoaded = false

    override fun getLayoutResId(): Int = R.layout.activity_rn_page

    override fun initView(savedInstanceState: Bundle?) {
        StatusBarSettingHelper.setStatusBarTranslucent(this)
        StatusBarSettingHelper.statusBarLightMode(this, true)

        mRootContainer = findViewById(R.id.root_container)
        mLoadingContainer = findViewById(R.id.loading_container)

        // RN 侧 token 过期回调
        AuthModule.tokenExpiredCallback = {
            tokenExpiredListener?.onTokenExpired()
        }

        initializeReactNative()
    }

    /**
     * token 过期监听接口，由外部（app 模块）设置
     * 避免 lib_rn 直接依赖 app 模块的 AuthManager 和 ARouter
     */
    interface OnTokenExpiredListener {
        fun onTokenExpired()
    }

    companion object {
        var tokenExpiredListener: OnTokenExpiredListener? = null
    }

    private fun initializeReactNative() {
        mReactRootView = ReactRootView(this)
        mReactInstanceManager = ReactNativeManager.getReactInstanceManager(application, this)

        // 监听 ReactContext 初始化完成，移除 loading
        mReactInstanceManager?.addReactInstanceEventListener(object : ReactInstanceEventListener {
            override fun onReactContextInitialized(context: com.facebook.react.bridge.ReactContext) {
                runOnUiThread {
                    removeLoading()
                }
            }
        })

        // 如果 ReactContext 已经存在（非首次加载），直接移除 loading
        if (mReactInstanceManager?.currentReactContext != null) {
            removeLoading()
        }

        val initialProps = Bundle().apply {
            putString("param1", "android")
            putString("token", intent.getStringExtra("token") ?: "")
            putString("username", intent.getStringExtra("username") ?: "")
        }

        mReactRootView?.startReactApplication(mReactInstanceManager, "RNHybrid", initialProps)
    }

    private fun removeLoading() {
        if (mRnContentLoaded) return
        mRnContentLoaded = true

        // 将 ReactRootView 添加到容器
        mReactRootView?.let { rv ->
            mRootContainer?.addView(
                rv,
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }

        // 移除 loading
        mLoadingContainer?.let { loading ->
            loading.animate()
                .alpha(0f)
                .setDuration(200)
                .withEndAction {
                    mRootContainer?.removeView(loading)
                }
                .start()
        }
    }

    override fun invokeDefaultOnBackPressed() {
        super.onBackPressed()
    }

    override fun onBackPressed() {
        if (mReactInstanceManager != null) {
            mReactInstanceManager!!.onBackPressed()
        } else {
            super.onBackPressed()
        }
    }

    override fun onResume() {
        super.onResume()
        mReactInstanceManager?.let {
            ReactNativeManager.onHostResume(this, this)
        }
    }

    override fun onPause() {
        super.onPause()
        mReactInstanceManager?.let {
            ReactNativeManager.onHostPause(this)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        AuthModule.isHandling = false
        AuthModule.tokenExpiredCallback = null
        mReactRootView?.unmountReactApplication()
        mReactRootView = null
        mRootContainer?.removeAllViews()
        mRootContainer = null
        mLoadingContainer = null
    }
}
