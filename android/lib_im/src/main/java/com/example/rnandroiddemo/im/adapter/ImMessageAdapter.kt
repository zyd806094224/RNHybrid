package com.example.rnandroiddemo.im.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.demo.shared.model.ImMessage
import com.demo.shared.model.MsgType
import com.example.rnandroiddemo.im.databinding.ItemImMessageBinding

/**
 * 聊天消息列表 Adapter（区分自己/对方气泡）。
 *
 * @author zhaoyudong
 */
class ImMessageAdapter(
    var currentUserId: Long
) : ListAdapter<ImMessage, ImMessageAdapter.VH>(DIFF) {

    inner class VH(val binding: ItemImMessageBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val binding = ItemImMessageBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return VH(binding)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = getItem(position)
        val isMe = item.senderId == currentUserId
        with(holder.binding) {
            if (isMe) {
                layoutLeft.visibility = View.GONE
                layoutRight.visibility = View.VISIBLE
                tvMsgRight.text = formatContent(item)
            } else {
                layoutRight.visibility = View.GONE
                layoutLeft.visibility = View.VISIBLE
                tvMsgLeft.text = formatContent(item)
            }
        }
    }

    private fun formatContent(item: ImMessage): String {
        return when (MsgType.of(item.msgType)) {
            MsgType.IMAGE -> "[图片]"
            MsgType.TEXT -> item.content
        }
    }

    companion object {
        private val DIFF = object : DiffUtil.ItemCallback<ImMessage>() {
            override fun areItemsTheSame(oldItem: ImMessage, newItem: ImMessage): Boolean =
                oldItem.msgId == newItem.msgId && oldItem.msgId != 0L

            override fun areContentsTheSame(oldItem: ImMessage, newItem: ImMessage): Boolean =
                oldItem == newItem
        }
    }
}
