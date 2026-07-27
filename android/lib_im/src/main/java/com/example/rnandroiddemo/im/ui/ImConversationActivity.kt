package com.example.rnandroiddemo.im.ui

import android.content.Context
import android.os.Bundle
import android.widget.Toast
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Route
import com.demo.framework.base.BaseMvvmActivity
import com.example.rnandroiddemo.im.ImTokenProvider
import com.example.rnandroiddemo.im.adapter.ImConversationAdapter
import com.example.rnandroiddemo.im.constant.ImRouterPath
import com.example.rnandroiddemo.im.databinding.ActivityImConversationBinding
import com.example.rnandroiddemo.im.vm.ImConversationViewModel
import kotlinx.coroutines.launch

/**
 * IM 会话列表页（IM 功能入口）。
 *
 * 进入时完成 [com.example.rnandroiddemo.im.ImSession] 握手（token 注入 + 拉 userId + 建 WS），
 * 然后拉取会话列表并订阅实时消息刷新。
 *
 * @author zhaoyudong
 */
@Route(path = ImRouterPath.IM_CONVERSATION_ACTIVITY)
class ImConversationActivity :
    BaseMvvmActivity<ActivityImConversationBinding, ImConversationViewModel>() {

    private val adapter = ImConversationAdapter { item ->
        // 点击会话进入聊天页
        ImChatActivity.start(this, item.conversationId, item.targetId, item.targetName)
    }

    override fun initView(savedInstanceState: Bundle?) {
        mBinding.recyclerView.layoutManager = LinearLayoutManager(this)
        mBinding.recyclerView.adapter = adapter

        // 发起新聊天 → 跳转到联系人选择页
        mBinding.tvNewChat.setOnClickListener {
            ImUserListActivity.start(this)
        }

        // 观察握手结果
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                mViewModel.initResult.collect { ok ->
                    if (ok == false) {
                        Toast.makeText(this@ImConversationActivity, "IM 初始化失败，请重新登录", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }

        // 观察会话列表
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                mViewModel.conversations.collect { list ->
                    adapter.submitList(list)
                }
            }
        }
    }

    override fun initData() {
        // 握手 + 拉取会话列表（token 由 app 模块注入的 ImTokenProvider 提供）
        val token = ImTokenProvider.get()
        mViewModel.init(token)
    }

    override fun onResume() {
        super.onResume()
        // 从聊天页返回时刷新会话列表
        mViewModel.loadConversations()
    }

    companion object {
        fun start(context: Context) {
            com.alibaba.android.arouter.launcher.ARouter.getInstance()
                .build(ImRouterPath.IM_CONVERSATION_ACTIVITY)
                .navigation(context)
        }
    }
}
