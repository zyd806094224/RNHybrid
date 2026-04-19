package com.example.rnandroiddemo

import android.os.Bundle
import androidx.navigation.NavController
import androidx.navigation.findNavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.setupWithNavController
import com.demo.framework.base.BaseActivity
import com.demo.framework.utils.StatusBarSettingHelper
import com.example.rnandroiddemo.navigator.SelfFragmentNavigator

class MainActivity : BaseActivity() {

    private lateinit var navController: NavController

    override fun getLayoutResId(): Int = R.layout.activity_main

    override fun initView(savedInstanceState: Bundle?) {
        StatusBarSettingHelper.setStatusBarTranslucent(this)
        StatusBarSettingHelper.statusBarLightMode(this, true)
        StatusBarSettingHelper.setRootViewFitsSystemWindows(this, true)

        val navView = findViewById<com.google.android.material.bottomnavigation.BottomNavigationView>(R.id.nav_view)
        navController = findNavController(R.id.nav_host_fragment_activity_main)

        val navHostFragment =
            supportFragmentManager.findFragmentById(R.id.nav_host_fragment_activity_main) as NavHostFragment
        val fragmentNavigator =
            SelfFragmentNavigator(this, navHostFragment.childFragmentManager, navHostFragment.id)
        navController.navigatorProvider.addNavigator(fragmentNavigator)
        navController.setGraph(R.navigation.mobile_navigation)
        navView.setupWithNavController(navController)
    }
}
