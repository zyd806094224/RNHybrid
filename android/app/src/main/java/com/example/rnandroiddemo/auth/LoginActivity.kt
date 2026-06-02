package com.example.rnandroiddemo.auth

import android.app.Activity
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.view.View
import android.view.WindowManager
import android.widget.Toast
import com.alibaba.android.arouter.facade.annotation.Route
import com.demo.framework.base.BaseMvvmActivity
import com.demo.framework.utils.StatusBarSettingHelper
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.example.rnandroiddemo.R
import com.example.rnandroiddemo.databinding.ActivityLoginBinding
import com.example.rnandroiddemo.rn.AuthModule
import com.example.rnandroiddemo.ui.login.LoginViewModel

@Route(path = "/auth/login")
class LoginActivity : BaseMvvmActivity<ActivityLoginBinding, LoginViewModel>() {

    override fun initView(savedInstanceState: Bundle?) {
        setupStatusBar()

        observeViewModel()
        setupPasswordToggle()

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

    private var passwordVisible = false

    private fun setupStatusBar() {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.statusBarColor = Color.parseColor("#E9FFF8")
        }
        WindowInsetsControllerCompat(window, window.decorView).isAppearanceLightStatusBars = true
        StatusBarSettingHelper.setRootViewFitsSystemWindows(this, false)
    }

    private fun setupPasswordToggle() {
        mBinding.ivTogglePwd.setOnClickListener {
            passwordVisible = !passwordVisible
            if (passwordVisible) {
                mBinding.etPassword.transformationMethod = HideReturnsTransformationMethod.getInstance()
                mBinding.ivTogglePwd.setImageResource(R.drawable.ic_visibility_on)
            } else {
                mBinding.etPassword.transformationMethod = PasswordTransformationMethod.getInstance()
                mBinding.ivTogglePwd.setImageResource(R.drawable.ic_visibility_off)
            }
            mBinding.etPassword.setSelection(mBinding.etPassword.text.length)
        }
    }
}
