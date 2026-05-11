package com.example.rnandroiddemo.ui.mine

import android.os.Bundle
import android.view.View
import android.widget.TextView
import com.demo.framework.base.BaseFragment
import com.example.rnandroiddemo.R
import com.example.rnandroiddemo.auth.AuthManager

class MineFragment : BaseFragment() {

    override fun getLayoutResId(): Int = R.layout.fragment_mine

    override fun initView(view: View, savedInstanceState: Bundle?) {
        view.findViewById<TextView>(R.id.tv_logout).setOnClickListener {
            AuthManager.logout()
            refreshUI(view)
        }
    }

    override fun onResume() {
        super.onResume()
        view?.let { refreshUI(it) }
    }

    private fun refreshUI(view: View) {
        val tvUserName = view.findViewById<TextView>(R.id.tv_user_name)
        val tvSubtitle = view.findViewById<TextView>(R.id.tv_user_subtitle)

        if (AuthManager.isLoggedIn()) {
            tvUserName.text = AuthManager.getUsername()
            tvSubtitle.text = "已登录"
        } else {
            tvUserName.text = "未登录"
            tvSubtitle.text = "点击去登录"
        }
    }
}
