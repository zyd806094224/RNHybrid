package com.demo.network.api

import com.demo.network.interceptor.NetworkRetryInterceptor
import com.demo.network.request.LoginRequest
import com.demo.network.response.BaseResponse
import com.demo.network.response.LoginResponse
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Headers
import retrofit2.http.POST

/**
 * @Description:
 * @Date: 2024/8/29 17:09
 * @author:  zhaoyudong
 * @version: 1.0
 */
interface ApiInterface {

    @GET("/dataList")
    suspend fun getDataList(): BaseResponse<MutableList<String>>?

    @Headers(NetworkRetryInterceptor.RETRY_TIME_HEADER)
    @GET("http://192.168.213.9:8060/user/test")
    suspend fun testRequest(): BaseResponse<String>?


    @GET("http://192.168.213.9:8060/user/test2")
    suspend fun test2Request(): BaseResponse<String>?

    @POST("https://106.15.7.132:8443/login")
    suspend fun login(@Body params: LoginRequest): LoginResponse

}