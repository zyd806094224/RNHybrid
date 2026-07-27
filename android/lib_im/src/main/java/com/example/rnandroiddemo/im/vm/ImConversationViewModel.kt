package com.example.rnandroiddemo.im.vm

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.demo.shared.model.ImConversation
import com.demo.shared.model.ImMessage
import com.demo.shared.model.MsgType
import com.demo.shared.repository.TokenManager
import com.example.rnandroiddemo.im.ImSession
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * 会话列表 ViewModel。
 *
 * 负责：握手（[ImSession.ensureInited]）→ 拉取会话列表 → 订阅实时消息刷新列表。
 *
 * @author zhaoyudong
 */
class ImConversationViewModel : ViewModel() {

    private val chatUseCase = ImSession.chatUseCase()

    private val _conversations = MutableStateFlow<List<ImConversation>>(emptyList())
    val conversations: StateFlow<List<ImConversation>> = _conversations.asStateFlow()

    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean> = _loading.asStateFlow()

    /** 握手结果（true 成功 / false 失败，UI 据此提示） */
    private val _initResult = MutableStateFlow<Boolean?>(null)
    val initResult: StateFlow<Boolean?> = _initResult.asStateFlow()

    private var observingMessages = false

    /**
     * 初始化：握手 + 订阅消息流 + 拉取会话列表。
     *
     * @param token RNHybrid 业务 token
     */
    fun init(token: String) {
        viewModelScope.launch {
            val ok = ImSession.ensureInited(token)
            _initResult.value = ok
            if (!ok) return@launch
            observeMessages()
            loadConversations()
        }
    }

    /**
     * 订阅 WebSocket 消息流，收到消息时实时更新会话列表。
     */
    private fun observeMessages() {
        if (observingMessages) return
        observingMessages = true
        viewModelScope.launch {
            chatUseCase.observeMessages().collect { msg ->
                updateConversationForMessage(msg)
            }
        }
    }

    /**
     * 收到实时消息后，更新对应会话的最后消息摘要和未读数。
     */
    private fun updateConversationForMessage(msg: ImMessage) {
        val summary = if (MsgType.of(msg.msgType) == MsgType.IMAGE) "[图片]" else msg.content.take(100)
        val list = _conversations.value.toMutableList()
        var changed = false

        for (i in list.indices) {
            val conv = list[i]
            // 这条消息属于当前会话（对方是 senderId 或 receiverId 之一 == conv.targetId）
            if (conv.targetId == msg.senderId || conv.targetId == msg.receiverId) {
                val isReceived = msg.senderId == conv.targetId
                list[i] = conv.copy(
                    lastMsgContent = summary,
                    lastMsgTime = msg.sendTime,
                    unreadCount = if (isReceived) conv.unreadCount + 1 else conv.unreadCount
                )
                changed = true
                break
            }
        }

        // 会话不在列表里（对方首次发消息），尝试新建
        if (!changed) {
            val currentUserId = TokenManager.getUserId().toLongOrNull()
            if (currentUserId != null) {
                val isReceiver = msg.receiverId == currentUserId
                val targetId = if (msg.senderId == currentUserId) msg.receiverId else msg.senderId
                list.add(
                    ImConversation(
                        conversationId = msg.conversationId,
                        targetId = targetId,
                        targetName = "用户$targetId",
                        lastMsgContent = summary,
                        lastMsgTime = msg.sendTime,
                        unreadCount = if (isReceiver) 1 else 0
                    )
                )
                changed = true
            }
        }

        if (changed) {
            list.sortByDescending { it.lastMsgTime }
            _conversations.value = list
        }
    }

    fun loadConversations() {
        viewModelScope.launch {
            _loading.value = true
            val result = chatUseCase.getConversations()
            _loading.value = false
            when (result) {
                is com.demo.shared.usecase.ChatUseCase.ListResult.Success -> _conversations.value = result.data
                is com.demo.shared.usecase.ChatUseCase.ListResult.Fail -> _conversations.value = emptyList()
            }
        }
    }
}
