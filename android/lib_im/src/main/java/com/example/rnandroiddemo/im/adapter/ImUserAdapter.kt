package com.example.rnandroiddemo.im.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.demo.shared.model.SimpleUser
import com.example.rnandroiddemo.im.databinding.ItemImUserBinding

/**
 * 联系人列表 Adapter。
 *
 * @author zhaoyudong
 */
class ImUserAdapter(
    private val onItemClick: (SimpleUser) -> Unit
) : ListAdapter<SimpleUser, ImUserAdapter.VH>(DIFF) {

    inner class VH(val binding: ItemImUserBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val binding = ItemImUserBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return VH(binding)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = getItem(position)
        with(holder.binding) {
            tvName.text = if (item.nickName.isNotEmpty()) item.nickName else item.userName
            root.setOnClickListener { onItemClick(item) }
        }
    }

    companion object {
        private val DIFF = object : DiffUtil.ItemCallback<SimpleUser>() {
            override fun areItemsTheSame(oldItem: SimpleUser, newItem: SimpleUser): Boolean =
                oldItem.userId == newItem.userId

            override fun areContentsTheSame(oldItem: SimpleUser, newItem: SimpleUser): Boolean =
                oldItem == newItem
        }
    }
}
