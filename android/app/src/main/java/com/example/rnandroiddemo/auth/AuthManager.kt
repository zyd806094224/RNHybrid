package com.example.rnandroiddemo.auth

import android.app.Application
import com.tencent.mmkv.MMKV

/**
 * 登录态管理器
 * 使用 MMKV 持久化存储 token/username，三端各平台独立实现，通过 initialProps 统一注入 RN
 */
object AuthManager {

    private const val KEY_TOKEN = "auth_token"
    private const val KEY_USERNAME = "auth_username"

    private var mmkv: MMKV? = null

    fun init(application: Application) {
        MMKV.initialize(application)
        mmkv = MMKV.defaultMMKV()
    }

    fun saveLogin(token: String, username: String) {
        mmkv?.encode(KEY_TOKEN, token)
        mmkv?.encode(KEY_USERNAME, username)
    }

    fun getToken(): String = mmkv?.decodeString(KEY_TOKEN, "") ?: ""

    fun getUsername(): String = mmkv?.decodeString(KEY_USERNAME, "") ?: ""

    fun isLoggedIn(): Boolean = !getToken().isNullOrEmpty()

    fun logout() {
        mmkv?.removeValueForKey(KEY_TOKEN)
        mmkv?.removeValueForKey(KEY_USERNAME)
    }
}
