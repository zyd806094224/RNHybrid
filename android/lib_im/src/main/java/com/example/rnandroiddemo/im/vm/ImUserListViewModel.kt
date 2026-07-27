package com.example.rnandroiddemo.im.vm

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.demo.shared.network.Api
import com.demo.shared.repository.TokenManager
import com.demo.shared.usecase.ChatUseCase
import com.example.rnandroiddemo.im.ImSession
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * 联系人列表 ViewModel。
 *
 * 排查模式：直接调 Api 层拿原始 BaseResponse，把服务端返回的 code/msg/data 全部打日志，
 * 便于定位"联系人列表为空"的根因（网络/鉴权/空数据）。
 *
 * @author zhaoyudong
 */
class ImUserListViewModel : ViewModel() {

    private val chatUseCase = ImSession.chatUseCase()

    private val _users = MutableStateFlow<List<com.demo.shared.model.SimpleUser>>(emptyList())
    val users: StateFlow<List<com.demo.shared.model.SimpleUser>> = _users.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    fun loadUsers() {
        viewModelScope.launch {
            Log.d(TAG, "loadUsers 开始")
            // 1. 先确保握手（token + userId + WS）
            val token = com.example.rnandroiddemo.im.ImTokenProvider.get()
            Log.d(TAG, "ImTokenProvider 返回 token 长度=${token.length}")
            if (token.isNotEmpty()) {
                val ok = ImSession.ensureInited(token)
                Log.d(TAG, "ensureInited 结果=$ok, TokenManager.token长度=${TokenManager.getToken().length}")
            } else {
                Log.w(TAG, "token 为空，跳过握手")
            }

            // 2. 直接调 Api 层，拿原始响应（绕过 UseCase，定位根因）
            _error.value = null
            try {
                Log.d(TAG, "开始调 Api.getChatUsers()")
                val resp = Api.getChatUsers()
                Log.d(TAG, "getChatUsers 原始响应: code=${resp.code}, msg=${resp.msg}, total=${resp.total}, dataSize=${resp.data?.size}")
                if (resp.isFailed()) {
                    _error.value = "接口失败: code=${resp.code}, msg=${resp.msg}"
                    _users.value = emptyList()
                } else {
                    val list = resp.data ?: emptyList()
                    list.forEach { Log.d(TAG, "联系人: userId=${it.userId}, userName=${it.userName}, nickName=${it.nickName}") }
                    _users.value = list
                    _error.value = if (list.isEmpty()) "暂无其他联系人" else null
                }
            } catch (e: Exception) {
                Log.e(TAG, "getChatUsers 异常: ${e.javaClass.simpleName}: ${e.message}", e)
                _error.value = "请求异常: ${e.javaClass.simpleName}: ${e.message}"
                _users.value = emptyList()
            }
        }
    }

    companion object {
        private const val TAG = "ImUserListVM"
    }
}
