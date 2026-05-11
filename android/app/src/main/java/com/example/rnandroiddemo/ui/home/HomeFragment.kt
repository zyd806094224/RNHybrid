package com.example.rnandroiddemo.ui.home

import android.os.Bundle
import android.view.View
import android.widget.Button
import com.alibaba.android.arouter.launcher.ARouter
import com.demo.framework.base.BaseFragment
import com.example.rnandroiddemo.R

class HomeFragment : BaseFragment() {

    override fun getLayoutResId(): Int = R.layout.fragment_home

    override fun initView(view: View, savedInstanceState: Bundle?) {
        view.findViewById<Button>(R.id.btn_go_rn).setOnClickListener {
            ARouter.getInstance()
                .build("/rn/page")
                .withBoolean("needLogin", true)
                .withString("token", com.example.rnandroiddemo.auth.AuthManager.getToken())
                .withString("username", com.example.rnandroiddemo.auth.AuthManager.getUsername())
                .navigation()
        }
    }
}
