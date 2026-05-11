package com.example.rnandroiddemo.auth

import android.app.Activity
import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.alibaba.android.arouter.facade.annotation.Route
import com.demo.framework.base.BaseMvvmActivity
import com.demo.framework.utils.StatusBarSettingHelper
import com.example.rnandroiddemo.databinding.ActivityLoginBinding
import com.example.rnandroiddemo.rn.AuthModule
import com.example.rnandroiddemo.ui.login.LoginViewModel

@Route(path = "/auth/login")
class LoginActivity : BaseMvvmActivity<ActivityLoginBinding, LoginViewModel>() {

    override fun initView(savedInstanceState: Bundle?) {
        StatusBarSettingHelper.setStatusBarTranslucent(this)
        StatusBarSettingHelper.statusBarLightMode(this, true)
        StatusBarSettingHelper.setRootViewFitsSystemWindows(this, true)

        observeViewModel()

        mBinding.btnLogin.setOnClickListener {
            val username = mBinding.etUsername.text.toString().trim()
            val password = mBinding.etPassword.text.toString().trim()

            if (username.isEmpty()) {
                Toast.makeText(this, "请输入用户名", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            if (password.isEmpty()) {
                Toast.makeText(this, "请输入密码", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            setLoading(true)
            mViewModel.login(username, password)
        }
    }

    private fun observeViewModel() {
        mViewModel.loginResult.observe(this) { response ->
            setLoading(false)
            if (response != null && response.code == 200 && !response.token.isNullOrEmpty()) {
                AuthManager.saveLogin(
                    response.token!!,
                    mBinding.etUsername.text.toString().trim()
                )
                setResult(Activity.RESULT_OK)
                finish()

                // 重置 token 过期防重入标志
                AuthModule.isHandling = false

                // 如果有被拦截器中断的待跳转路由，自动恢复
                PendingRoute.continueRoute()
            } else {
                Toast.makeText(this, response?.msg ?: "登录失败", Toast.LENGTH_SHORT).show()
            }
        }

        mViewModel.errorMessage.observe(this) { msg ->
            setLoading(false)
            Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
        }
    }

    private fun setLoading(loading: Boolean) {
        mBinding.progressBar.visibility = if (loading) View.VISIBLE else View.GONE
        mBinding.btnLogin.visibility = if (loading) View.GONE else View.VISIBLE
        mBinding.etUsername.isEnabled = !loading
        mBinding.etPassword.isEnabled = !loading
    }
}
