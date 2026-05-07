package com.example.rnandroiddemo.rn

import android.content.Context
import android.util.Log
import com.demo.framework.helper.AppHelper
import com.facebook.react.modules.network.OkHttpClientFactory
import com.facebook.react.modules.network.ReactCookieJarContainer
import okhttp3.OkHttpClient
import java.io.ByteArrayInputStream
import java.security.KeyStore
import java.security.SecureRandom
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.TrustManagerFactory
import javax.net.ssl.X509TrustManager

/**
 * 自定义 OkHttpClient 工厂
 * - Debug 模式：信任所有证书（方便 Charles/Fiddler 抓包）
 * - Release 模式：仅信任内置的自签名证书
 */
class CustomOkHttpClientFactory(private val context: Context) : OkHttpClientFactory {

    companion object {
        private const val TAG = "CustomOkHttp"
    }

    override fun createNewNetworkModuleClient(): OkHttpClient {
        val builder = OkHttpClient.Builder()
            .cookieJar(ReactCookieJarContainer())
            .hostnameVerifier { _, _ -> true }

        if (AppHelper.isDebug()) {
            // Debug 模式：信任所有证书，Charles 可以明文抓包
            Log.d(TAG, "Debug 模式，信任所有证书")
            val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
                override fun checkClientTrusted(chain: Array<X509Certificate>?, authType: String?) {}
                override fun checkServerTrusted(chain: Array<X509Certificate>?, authType: String?) {}
                override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
            })
            val sslContext = SSLContext.getInstance("TLS")
            sslContext.init(null, trustAllCerts, SecureRandom())
            builder.sslSocketFactory(sslContext.socketFactory, trustAllCerts[0] as X509TrustManager)
        } else {
            // Release 模式：仅信任内置自签名证书
            val trustManager = createTrustManager()
            val sslContext = SSLContext.getInstance("TLS")
            sslContext.init(null, arrayOf(trustManager), null)
            builder.sslSocketFactory(sslContext.socketFactory, trustManager)
        }

        return builder.build()
    }

    private fun createTrustManager(): X509TrustManager {
        val certFactory = CertificateFactory.getInstance("X.509")
        val certInput = context.resources.openRawResource(
            context.resources.getIdentifier("server_cert", "raw", context.packageName)
        )
        val caCert = certFactory.generateCertificate(certInput) as X509Certificate
        certInput.close()

        val keyStore = KeyStore.getInstance(KeyStore.getDefaultType())
        keyStore.load(null, null)
        keyStore.setCertificateEntry("server_cert", caCert)

        val trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm())
        trustManagerFactory.init(keyStore)

        return trustManagerFactory.trustManagers.first { it is X509TrustManager } as X509TrustManager
    }
}
