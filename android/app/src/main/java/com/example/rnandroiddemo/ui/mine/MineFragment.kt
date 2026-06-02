package com.example.rnandroiddemo.ui.mine

import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.TextView
import com.alibaba.android.arouter.launcher.ARouter
import com.demo.framework.base.BaseFragment
import com.example.rnandroiddemo.R
import com.example.rnandroiddemo.auth.AuthManager

class MineFragment : BaseFragment() {

    override fun getLayoutResId(): Int = R.layout.fragment_mine

    override fun initView(view: View, savedInstanceState: Bundle?) {
        refreshUI(view)
    }

    override fun onResume() {
        super.onResume()
        view?.let { refreshUI(it) }
    }

    private fun refreshUI(view: View) {
        val tvUserName = view.findViewById<TextView>(R.id.tv_user_name)
        val tvSubtitle = view.findViewById<TextView>(R.id.tv_user_subtitle)
        val tvLogout = view.findViewById<TextView>(R.id.tv_logout)
        val layoutUserHeader = view.findViewById<View>(R.id.layout_user_header)

        if (AuthManager.isLoggedIn()) {
            tvUserName.text = AuthManager.getUsername()
            tvSubtitle.text = "已登录"
            tvLogout.text = "退出登录"
            tvLogout.setTextColor(resources.getColor(R.color.red, null))
            layoutUserHeader.setOnClickListener(null)
            tvLogout.setOnClickListener {
                AlertDialog.Builder(requireContext())
                    .setTitle("提示")
                    .setMessage("确定要退出登录吗？")
                    .setPositiveButton("确定") { _, _ ->
                        AuthManager.logout()
                        refreshUI(view)
                    }
                    .setNegativeButton("取消", null)
                    .show()
            }
        } else {
            tvUserName.text = "未登录"
            tvSubtitle.text = "点击去登录"
            tvLogout.text = "登录"
            tvLogout.setTextColor(resources.getColor(R.color.purple_500, null))
            layoutUserHeader.setOnClickListener { goLogin() }
            tvLogout.setOnClickListener { goLogin() }
        }
    }

    private fun goLogin() {
        ARouter.getInstance()
            .build("/auth/login")
            .greenChannel()
            .navigation()
    }
}
