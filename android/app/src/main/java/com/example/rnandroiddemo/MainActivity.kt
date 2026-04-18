package com.example.rnandroiddemo

import android.content.Intent
import android.os.Bundle
import com.demo.framework.base.BaseActivity
import com.example.rnandroiddemo.rn.RNPageActivity

class MainActivity : BaseActivity() {

    override fun getLayoutResId(): Int = R.layout.activity_main

    override fun initView(savedInstanceState: Bundle?) {
        findViewById<android.widget.Button>(R.id.btn).setOnClickListener {
            startActivity(Intent(this, RNPageActivity::class.java))
        }
    }
}
