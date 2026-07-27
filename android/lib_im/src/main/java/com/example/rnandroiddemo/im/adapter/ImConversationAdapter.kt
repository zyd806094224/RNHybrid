package com.example.rnandroiddemo.im.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.demo.shared.model.ImConversation
import com.example.rnandroiddemo.im.databinding.ItemImConversationBinding

/**
 * 会话列表 Adapter。
 *
 * 自实现（RNHybrid 的 lib_framework 没有 BaseRecyclerViewAdapter），
 * 基于 [ListAdapter] + DataBinding。
 *
 * @author zhaoyudong
 */
class ImConversationAdapter(
    private val onItemClick: (ImConversation) -> Unit
) : ListAdapter<ImConversation, ImConversationAdapter.VH>(DIFF) {

    inner class VH(val binding: ItemImConversationBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val binding = ItemImConversationBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return VH(binding)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = getItem(position)
        with(holder.binding) {
            tvName.text = if (item.targetName.isNotEmpty()) item.targetName else "用户${item.targetId}"
            tvLastMsg.text = item.lastMsgContent
            tvTime.text = formatTime(item.lastMsgTime)

            if (item.unreadCount > 0) {
                tvUnread.visibility = android.view.View.VISIBLE
                tvUnread.text = if (item.unreadCount > 99) "99+" else item.unreadCount.toString()
            } else {
                tvUnread.visibility = android.view.View.GONE
            }

            root.setOnClickListener { onItemClick(item) }
        }
    }

    private fun formatTime(timeStr: String): String {
        // 服务端返回 "yyyy-MM-dd HH:mm:ss"，只显示 HH:mm
        return try {
            if (timeStr.length >= 19) timeStr.substring(11, 16) else timeStr
        } catch (e: Exception) {
            timeStr
        }
    }

    companion object {
        private val DIFF = object : DiffUtil.ItemCallback<ImConversation>() {
            override fun areItemsTheSame(oldItem: ImConversation, newItem: ImConversation): Boolean =
                oldItem.conversationId == newItem.conversationId

            override fun areContentsTheSame(oldItem: ImConversation, newItem: ImConversation): Boolean =
                oldItem == newItem
        }
    }
}
