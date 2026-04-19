package com.example.rnandroiddemo.ui.home

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import com.demo.framework.base.BaseFragment
import com.example.rnandroiddemo.R
import com.example.rnandroiddemo.rn.RNPageActivity

class HomeFragment : BaseFragment() {

    override fun getLayoutResId(): Int = R.layout.fragment_home

    override fun initView(view: View, savedInstanceState: Bundle?) {
        view.findViewById<Button>(R.id.btn_go_rn).setOnClickListener {
            startActivity(Intent(requireContext(), RNPageActivity::class.java))
        }
    }
}
