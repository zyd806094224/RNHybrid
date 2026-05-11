package com.example.rnandroiddemo.rn

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

/**
 * RN → 原生 Auth 通信模块
 * RN 侧检测到 token 过期（401）时调用 onTokenExpired()，由原生侧处理登录态清理和页面跳转
 */
class AuthModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName() = "AuthModule"

    @ReactMethod
    fun onTokenExpired() {
        currentActivity?.runOnUiThread {
            if (isHandling) return@runOnUiThread
            isHandling = true
            tokenExpiredCallback?.invoke()
        }
    }

    companion object {
        /**
         * token 过期回调，由 RNPageActivity 设置
         * 实现：清除登录态 → 关闭 RN 页面 → 跳转原生登录页
         */
        var tokenExpiredCallback: (() -> Unit)? = null

        /**
         * 刷新 token 回调，登录成功后由原生侧调用
         * RN 侧收到新 token 后更新 JS 端 auth store
         */
        var refreshTokenCallback: ((token: String, username: String) -> Unit)? = null

        /**
         * 防重入标志，避免多个接口同时 401 时重复打开登录页
         * 登录成功后或 RNPageActivity 销毁时重置
         */
        var isHandling = false
    }
}
