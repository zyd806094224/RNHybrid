package com.example.rnandroiddemo.ui.mine

import android.os.Bundle
import android.view.View
import com.demo.framework.base.BaseFragment
import com.example.rnandroiddemo.R

class MineFragment : BaseFragment() {

    override fun getLayoutResId(): Int = R.layout.fragment_mine

    override fun initView(view: View, savedInstanceState: Bundle?) {
        // 个人信息展示，当前使用假数据，后续可接入真实数据
    }
}
