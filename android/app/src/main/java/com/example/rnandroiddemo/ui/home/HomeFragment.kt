package com.example.rnandroiddemo.ui.home

import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.alibaba.android.arouter.launcher.ARouter
import com.demo.framework.base.BaseFragment
import com.example.rnandroiddemo.R
import com.example.rnandroiddemo.auth.AuthManager

class HomeFragment : BaseFragment() {

    override fun getLayoutResId(): Int = R.layout.fragment_home

    override fun initView(view: View, savedInstanceState: Bundle?) {
        // 小仓库 → RN 密码管理页面
        view.findViewById<View>(R.id.card_rn_page).setOnClickListener {
            ARouter.getInstance()
                .build("/rn/page")
                .withBoolean("needLogin", true)
                .withString("token", AuthManager.getToken())
                .withString("username", AuthManager.getUsername())
                .navigation()
        }

        // 其他卡片暂未开放
        val placeholderCards = intArrayOf()
        // 后续新增入口在此添加点击事件
    }
}
