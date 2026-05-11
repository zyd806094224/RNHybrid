package com.example.rnandroiddemo.rn

import android.view.View
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ReactShadowNode
import com.facebook.react.uimanager.ViewManager

class AuthPackage : ReactPackage {

    override fun createNativeModules(reactContext: ReactApplicationContext) =
        listOf(AuthModule(reactContext))

    override fun createViewManagers(reactContext: ReactApplicationContext) =
        emptyList<ViewManager<View, ReactShadowNode<*>>>()
}
