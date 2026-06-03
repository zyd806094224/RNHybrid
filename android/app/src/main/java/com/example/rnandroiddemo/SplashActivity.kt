package com.example.rnandroiddemo

import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.demo.framework.base.BaseActivity
import com.demo.framework.utils.StatusBarSettingHelper

class SplashActivity : BaseActivity() {

    override fun getLayoutResId(): Int = R.layout.activity_splash

    override fun initView(savedInstanceState: Bundle?) {
        setupStatusBar()
        // 防止从后台恢复时重复显示闪屏
        if (!isTaskRoot) {
            finish()
            return
        }

        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
            finish()
        }, 1200)
    }

    private fun setupStatusBar() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.statusBarColor = Color.parseColor("#E9FFF8")
            window.navigationBarColor = Color.parseColor("#F7FAFC")
        }
        WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true
        StatusBarSettingHelper.setRootViewFitsSystemWindows(this, false)
    }
}
