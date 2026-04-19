package com.example.rnandroiddemo.rn

import android.os.Bundle
import com.demo.framework.base.BaseActivity
import com.demo.framework.utils.StatusBarSettingHelper
import com.facebook.react.ReactInstanceManager
import com.facebook.react.ReactRootView
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler

/**
 * RN 载体页 Activity
 * 承载 ReactRootView，使用 ReactNativeManager 管理单例 ReactInstanceManager
 */
class RNPageActivity : BaseActivity(), DefaultHardwareBackBtnHandler {

    private var mReactRootView: ReactRootView? = null
    private var mReactInstanceManager: ReactInstanceManager? = null

    override fun getLayoutResId(): Int = 0

    override fun setContentLayout() {
        // 使用 ReactRootView 替代传统布局
        initializeReactNative()
    }

    override fun initView(savedInstanceState: Bundle?) {
        StatusBarSettingHelper.setStatusBarTranslucent(this)
        StatusBarSettingHelper.statusBarLightMode(this, true)
    }

    private fun initializeReactNative() {
        mReactRootView = ReactRootView(this)
        mReactInstanceManager = ReactNativeManager.getReactInstanceManager(application, this)

        val initialProps = Bundle().apply {
            putString("param1", "android")
        }

        mReactRootView?.startReactApplication(mReactInstanceManager, "RNHybrid", initialProps)
        setContentView(mReactRootView)
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
        mReactRootView?.unmountReactApplication()
        mReactRootView = null
    }
}
