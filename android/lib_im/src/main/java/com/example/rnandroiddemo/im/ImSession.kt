package com.example.rnandroiddemo.im

import android.util.Log
import com.demo.shared.network.Api
import com.demo.shared.repository.TokenManager
import com.demo.shared.usecase.ChatUseCase

/**
 * IM 会话握手初始化器（核心）。
 *
 * RNHybrid 业务侧通过 [ImTokenProvider] 提供的 token 复用进 KMP IM，
 * 无需 IM 独立登录。本类负责完成「token 注入 → 拉取 userId → 建立 WebSocket」三步握手。
 *
 * @author zhaoyudong
 */
object ImSession {

    private const val TAG = "ImSession"

    private val chatUseCase = ChatUseCase()

    @Volatile
    private var initedToken: String = ""

    /**
     * 用 RNHybrid 已有 token 初始化 IM 会话。幂等。
     *
     * @param token RNHybrid 业务登录 token
     * @return true 握手成功；false 握手失败
     */
    suspend fun ensureInited(token: String): Boolean {
        Log.d(TAG, "ensureInited start: token=${maskToken(token)}, 已握手token=${maskToken(initedToken)}")
        if (token.isEmpty()) {
            Log.w(TAG, "ensureInited: token 为空，跳过握手")
            return false
        }
        if (initedToken == token) {
            Log.d(TAG, "ensureInited: token 未变化，跳过（幂等）")
            return true
        }

        return try {
            // 1. token 注入 KMP
            TokenManager.saveToken(token)
            Log.d(TAG, "步骤1 token 已写入 TokenManager")

            // 2. 拉取 userId
            var userIdGot = false
            try {
                Log.d(TAG, "步骤2 开始调 Api.getUserInfo()")
                val userInfo = Api.getUserInfo()
                val user = userInfo.user
                Log.d(TAG, "getUserInfo 返回: code=${userInfo.code}, msg=${userInfo.msg}, user=${user}")
                if (!userInfo.isFailed() && user != null) {
                    TokenManager.saveUserId(user.userId.toString())
                    userIdGot = true
                    Log.d(TAG, "userId 已写入 TokenManager: ${user.userId}")
                }
            } catch (e: Exception) {
                Log.w(TAG, "拉取 userId 失败（不阻塞握手）: ${e.javaClass.simpleName}: ${e.message}", e)
            }

            // 3. 建立 WebSocket
            Log.d(TAG, "步骤3 开始建 WebSocket，token=${maskToken(token)}")
            chatUseCase.start(token)
            Log.d(TAG, "WebSocket 建连调用完成")

            initedToken = token
            Log.d(TAG, "IM 握手成功，userIdGot=$userIdGot, 当前userId=${TokenManager.getUserId()}")
            true
        } catch (e: Exception) {
            Log.e(TAG, "IM 握手失败: ${e.javaClass.simpleName}: ${e.message}", e)
            initedToken = ""
            false
        }
    }

    fun reset() {
        try {
            chatUseCase.stop()
        } catch (e: Exception) {
            Log.w(TAG, "断开 WebSocket 失败: ${e.message}")
        }
        initedToken = ""
        TokenManager.clearToken()
    }

    fun chatUseCase(): ChatUseCase = chatUseCase

    /** token 脱敏，只打前6后4 */
    private fun maskToken(token: String): String {
        if (token.length <= 10) return "len=${token.length}"
        return "${token.take(6)}...${token.takeLast(4)}(len=${token.length})"
    }
}
