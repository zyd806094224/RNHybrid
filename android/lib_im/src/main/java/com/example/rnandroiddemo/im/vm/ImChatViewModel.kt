package com.example.rnandroiddemo.im.vm

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.demo.shared.model.ImMessage
import com.demo.shared.repository.TokenManager
import com.example.rnandroiddemo.im.ImSession
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * 聊天页 ViewModel。
 *
 * 负责：握手 → 确保会话存在 → 拉取历史消息 → 发送消息 / 接收实时消息。
 *
 * @author zhaoyudong
 */
class ImChatViewModel : ViewModel() {

    private val chatUseCase = ImSession.chatUseCase()

    private val _messages = MutableStateFlow<List<ImMessage>>(emptyList())
    val messages: StateFlow<List<ImMessage>> = _messages.asStateFlow()

    /** 当前用户ID（由 Activity 从 TokenManager 传入，气泡左右区分用） */
    var currentUserId: Long = 0L

    /**
     * 初始化：握手 + 确保 conversationId 存在 + 拉取历史消息。
     *
     * @param token RNHybrid 业务 token
     * @param conversationId 会话ID（从会话列表进入时有值，新发起聊天时为 0）
     * @param targetId 对方用户ID
     */
    fun init(token: String, conversationId: Long, targetId: Long) {
        viewModelScope.launch {
            // 确保 WS 已连接（幂等）
            ImSession.ensureInited(token)

            // 确保 conversationId 存在（从会话列表进入时已有值，新发起聊天时为 0）
            val realConvId = if (conversationId > 0) {
                conversationId
            } else {
                chatUseCase.getOrCreateConversation(targetId)?.conversationId ?: 0L
            }

            // 拉取历史消息（按 conversation_id 查）
            if (realConvId > 0) {
                val result = chatUseCase.loadHistory(realConvId)
                when (result) {
                    is com.demo.shared.usecase.ChatUseCase.ListResult.Success -> {
                        val list = result.data
                        // 如果 currentUserId 未取到，从历史消息推断
                        if (currentUserId == 0L && list.isNotEmpty()) {
                            val first = list.first()
                            currentUserId = if (first.senderId == targetId) first.receiverId else first.senderId
                        }
                        // 服务端按 msg_id DESC 返回（最新在前），反转为正序（最早在前、最新在后）
                        _messages.value = list.reversed()
                    }
                    is com.demo.shared.usecase.ChatUseCase.ListResult.Fail -> _messages.value = emptyList()
                }
            }
        }
    }

    /**
     * 发送文本消息。
     */
    fun sendMessage(targetId: Long, content: String, onResult: (Boolean, String) -> Unit) {
        viewModelScope.launch {
            val result = chatUseCase.sendMessage(targetId, 1, content)
            when (result) {
                is com.demo.shared.usecase.ChatUseCase.SendResult.Success -> {
                    val msg = ImMessage(
                        msgId = result.msgId,
                        senderId = currentUserId,
                        receiverId = targetId,
                        msgType = 1,
                        content = content
                    )
                    _messages.value = _messages.value + msg
                    onResult(true, "")
                }
                is com.demo.shared.usecase.ChatUseCase.SendResult.Fail -> onResult(false, result.errMsg)
            }
        }
    }

    /**
     * 接收实时消息（由 Activity 的 WS 订阅回调）。
     *
     * 去重逻辑：服务端会把发送方的消息推回给所有在线端（多端同步），
     * 如果消息已存在（相同 msgId），不重复追加。
     */
    fun onReceiveMessage(message: ImMessage) {
        val current = _messages.value
        if (message.msgId != 0L && current.any { it.msgId == message.msgId }) {
            return
        }
        _messages.value = current + message
    }

    override fun onCleared() {
        super.onCleared()
        // userId 读一次即可，不在这里断 WS（WS 由全局 ImSession 管理，会话页退出保持连接）
        TokenManager.getUserId()
    }
}
