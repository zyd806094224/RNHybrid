package com.example.rnandroiddemo.ui.home

import android.os.Bundle
import android.view.View
import com.alibaba.android.arouter.launcher.ARouter
import com.demo.framework.base.BaseFragment
import com.demo.framework.manager.AppManager
import com.example.rnandroiddemo.R
import com.example.rnandroiddemo.auth.AuthManager

class HomeFragment : BaseFragment() {

    override fun getLayoutResId(): Int = R.layout.fragment_home

    override fun initView(view: View, savedInstanceState: Bundle?) {
        applyHeaderInsets(view)

        // 小仓库 → RN 密码管理页面
        view.findViewById<View>(R.id.card_rn_page).setOnClickListener {
            ARouter.getInstance()
                .build("/rn/page")
                .withBoolean("needLogin", true)
                .withString("token", AuthManager.getToken())
                .withString("username", AuthManager.getUsername())
                .navigation()
        }
    }

    private fun applyHeaderInsets(view: View) {
        val layoutHomeHeader = view.findViewById<View>(R.id.layout_home_header_fixed)
        val height = AppManager.getStatusBarHeight() + dp(6)
        layoutHomeHeader.layoutParams = layoutHomeHeader.layoutParams.apply {
            this.height = height
        }
        layoutHomeHeader.setPadding(
            layoutHomeHeader.paddingLeft,
            AppManager.getStatusBarHeight(),
            layoutHomeHeader.paddingRight,
            dp(6)
        )
    }

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density + 0.5f).toInt()
    }
}
