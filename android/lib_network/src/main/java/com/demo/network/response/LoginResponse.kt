package com.demo.network.response

data class LoginResponse(
    val code: Int,
    val token: String?,
    val msg: String?
)
