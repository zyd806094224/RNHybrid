package com.example.rnandroiddemo.auth

import android.content.Context
import android.os.Bundle
import com.alibaba.android.arouter.facade.Postcard
import com.alibaba.android.arouter.facade.annotation.Interceptor
import com.alibaba.android.arouter.facade.callback.InterceptorCallback
import com.alibaba.android.arouter.facade.template.IInterceptor
import com.alibaba.android.arouter.launcher.ARouter

/**
 * ARouter 登录拦截器
 * 拦截所有标记 needLogin = true 的路由，未登录时保存目标路由并跳转登录页
 * 登录成功后通过 PendingRoute.continueRoute() 自动恢复原路由
 */
@Interceptor(name = "login", priority = 1)
class LoginInterceptor : IInterceptor {

    override fun process(postcard: Postcard, callback: InterceptorCallback) {
        val needLogin = postcard.extras?.getBoolean("needLogin", false) ?: false

        if (needLogin && !AuthManager.isLoggedIn()) {
            // 保存原始路由信息
            PendingRoute.save(postcard.path, postcard.extras)

            // 跳转登录页（走绿色通道，避免被自己拦截）
            ARouter.getInstance()
                .build("/auth/login")
                .greenChannel()
                .navigation()

            // 中断当前路由
            callback.onInterrupt(null)
        } else {
            callback.onContinue(postcard)
        }
    }

    override fun init(context: Context) {}
}

/**
 * 保存被登录拦截器中断的路由信息，登录成功后可恢复
 */
object PendingRoute {

    private var path: String? = null
    private var extras: Bundle? = null

    fun save(path: String, extras: Bundle?) {
        this.path = path
        this.extras = extras
    }

    /**
     * 登录成功后调用，恢复之前被拦截的路由
     * @return true 表示有待恢复的路由
     */
    fun continueRoute(): Boolean {
        val targetPath = path ?: return false
        val targetExtras = Bundle().apply {
            extras?.let { putAll(it) }
            if (targetPath == "/rn/page" || getBoolean("needLogin", false)) {
                putString("token", AuthManager.getToken())
                putString("username", AuthManager.getUsername())
            }
        }

        clear()

        ARouter.getInstance()
            .build(targetPath)
            .with(targetExtras)
            .greenChannel() // 已登录，直接走绿色通道
            .navigation()

        return true
    }

    fun clear() {
        path = null
        extras = null
    }
}
