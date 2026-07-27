package com.example.rnandroiddemo.im.ui

import android.content.Context
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.recyclerview.widget.LinearLayoutManager
import com.alibaba.android.arouter.facade.annotation.Route
import com.demo.framework.base.BaseMvvmActivity
import com.example.rnandroiddemo.im.adapter.ImUserAdapter
import com.example.rnandroiddemo.im.constant.ImRouterPath
import com.example.rnandroiddemo.im.databinding.ActivityImUserListBinding
import com.example.rnandroiddemo.im.vm.ImUserListViewModel
import kotlinx.coroutines.launch

/**
 * IM 联系人选择页（发起新聊天）。
 *
 * @author zhaoyudong
 */
@Route(path = ImRouterPath.IM_USER_LIST_ACTIVITY)
class ImUserListActivity :
    BaseMvvmActivity<ActivityImUserListBinding, ImUserListViewModel>() {

    private val adapter = ImUserAdapter { item ->
        val name = if (item.nickName.isNotEmpty()) item.nickName else item.userName
        ImChatActivity.start(this, 0L, item.userId, name)
    }

    override fun initView(savedInstanceState: Bundle?) {
        mBinding.recyclerView.layoutManager = LinearLayoutManager(this)
        mBinding.recyclerView.adapter = adapter

        mBinding.ivBack.setOnClickListener { finish() }

        // 观察用户列表
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                mViewModel.users.collect { list ->
                    adapter.submitList(list)
                    // 列表为空时显示空态提示，否则隐藏
                    mBinding.tvEmpty.visibility = if (list.isEmpty()) View.VISIBLE else View.GONE
                }
            }
        }

        // 观察错误提示
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                mViewModel.error.collect { msg ->
                    if (!msg.isNullOrEmpty()) {
                        mBinding.tvEmpty.text = msg
                        mBinding.tvEmpty.visibility = View.VISIBLE
                    }
                }
            }
        }
    }

    override fun initData() {
        mViewModel.loadUsers()
    }

    companion object {
        fun start(context: Context) {
            com.alibaba.android.arouter.launcher.ARouter.getInstance()
                .build(ImRouterPath.IM_USER_LIST_ACTIVITY)
                .navigation(context)
        }
    }
}
