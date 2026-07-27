package com.example.rnandroiddemo.im

/**
 * Token 提供者桥接。
 *
 * lib_im 不能反向依赖 app 模块的 AuthManager（会形成循环依赖），
 * 因此由 app 模块在 Application 初始化时把 token 读取逻辑注入进来。
 *
 * 用法（app/MyApplication）：
 * ```
 * ImTokenProvider.get = { AuthManager.getToken() }
 * ```
 *
 * @author zhaoyudong
 */
object ImTokenProvider {

    /**
     * 返回当前 RNHybrid 业务登录态的 token，未登录返回空串。
     * 默认实现返回空串，必须由 app 模块赋值。
     */
    var get: () -> String = { "" }
}
