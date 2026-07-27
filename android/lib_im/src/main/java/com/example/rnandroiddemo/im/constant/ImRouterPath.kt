package com.example.rnandroiddemo.im.constant

/**
 * IM 模块 ARouter 路由路径与参数常量。
 *
 * @author zhaoyudong
 */
object ImRouterPath {

    //********************** Activity 路由 **********************

    /** 会话列表页 */
    const val IM_CONVERSATION_ACTIVITY = "/im/conversation/activity"

    /** 聊天页 */
    const val IM_CHAT_ACTIVITY = "/im/chat/activity"

    /** 联系人选择页 */
    const val IM_USER_LIST_ACTIVITY = "/im/userlist/activity"

    //********************** 路由参数 **********************

    /** 会话 ID */
    const val PARAM_CONVERSATION_ID = "conversationId"

    /** 对方用户 ID */
    const val PARAM_USER_ID = "userId"

    /** 对方昵称 */
    const val PARAM_TARGET_NAME = "targetName"
}
