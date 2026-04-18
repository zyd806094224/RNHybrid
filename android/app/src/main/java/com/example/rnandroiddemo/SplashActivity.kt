package com.example.rnandroiddemo

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import com.demo.framework.base.BaseActivity

class SplashActivity : BaseActivity() {

    override fun getLayoutResId(): Int = R.layout.activity_splash

    override fun initView(savedInstanceState: Bundle?) {
        // 防止从后台恢复时重复显示闪屏
        if (!isTaskRoot) {
            finish()
            return
        }

        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, 1500)
    }
}
