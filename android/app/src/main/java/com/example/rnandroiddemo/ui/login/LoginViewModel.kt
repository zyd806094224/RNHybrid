package com.example.rnandroiddemo.ui.login

import androidx.lifecycle.MutableLiveData
import com.demo.network.api.ApiInterface
import com.demo.network.manager.HttpManager
import com.demo.network.request.LoginRequest
import com.demo.network.response.LoginResponse
import com.demo.network.viewmodel.BaseViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class LoginViewModel : BaseViewModel() {

    val loginResult = MutableLiveData<LoginResponse?>()
    val errorMessage = MutableLiveData<String>()

    private val api: ApiInterface by lazy { HttpManager.create(ApiInterface::class.java) }

    fun login(username: String, password: String) {
        launchUI(
            errorBlock = { _, msg ->
                errorMessage.value = msg ?: "登录失败"
            },
            responseBlock = {
                val response = withContext(Dispatchers.IO) {
                    api.login(LoginRequest(username, password))
                }
                loginResult.value = response
            }
        )
    }
}
