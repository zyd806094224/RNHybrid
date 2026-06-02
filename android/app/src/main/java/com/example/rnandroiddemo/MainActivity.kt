package com.example.rnandroiddemo

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.navigation.NavController
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.setupWithNavController
import com.demo.framework.base.BaseActivity
import com.demo.framework.utils.StatusBarSettingHelper
import com.demo.framework.utils.StatusBarUtil
import com.example.rnandroiddemo.navigator.SelfFragmentNavigator

class MainActivity : BaseActivity() {

    private lateinit var navController: NavController

    override fun getLayoutResId(): Int = R.layout.activity_main

    override fun initView(savedInstanceState: Bundle?) {
        applyDefaultStatusBar()

        val navView = findViewById<com.google.android.material.bottomnavigation.BottomNavigationView>(R.id.nav_view)
        navController = findNavController(R.id.nav_host_fragment_activity_main)

        val navHostFragment =
            supportFragmentManager.findFragmentById(R.id.nav_host_fragment_activity_main) as NavHostFragment
        val fragmentNavigator =
            SelfFragmentNavigator(this, navHostFragment.childFragmentManager, navHostFragment.id)
        navController.navigatorProvider.addNavigator(fragmentNavigator)
        navController.setGraph(R.navigation.mobile_navigation)
        navView.setupWithNavController(navController)
        navController.addOnDestinationChangedListener { _, destination, _ ->
            when (destination.id) {
                R.id.navi_mine -> applyMineStatusBar()
                R.id.navi_home -> applyHomeStatusBar()
                else -> applyDefaultStatusBar()
            }
        }
    }

    private fun applyMineStatusBar() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        }
        StatusBarUtil.setStatusBarDarkMode(this)
        WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.parseColor("#4A9FA3")
        }
        var visibility = window.decorView.systemUiVisibility
        visibility = visibility or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            visibility = visibility and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv()
        }
        window.decorView.systemUiVisibility = visibility
        findViewById<View>(com.demo.framework.R.id.immersion_status_bar_view)?.visibility = View.GONE
        StatusBarSettingHelper.setRootViewFitsSystemWindows(this, false)
    }

    private fun applyDefaultStatusBar() {
        WindowCompat.setDecorFitsSystemWindows(window, true)
        StatusBarSettingHelper.setStatusBarTranslucent(this)
        StatusBarSettingHelper.statusBarLightMode(this, true)
        WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true
        StatusBarSettingHelper.setRootViewFitsSystemWindows(this, true)
    }

    private fun applyHomeStatusBar() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.statusBarColor = Color.parseColor("#EAF7F5")
        }
        StatusBarUtil.setStatusBarLightMode(this)
        WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true
        var visibility = window.decorView.systemUiVisibility
        visibility = visibility or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            visibility = visibility or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        }
        window.decorView.systemUiVisibility = visibility
        findViewById<View>(com.demo.framework.R.id.immersion_status_bar_view)?.visibility = View.GONE
        StatusBarSettingHelper.setRootViewFitsSystemWindows(this, false)
    }
}
