package com.example.rnandroiddemo.rn

import android.content.Context
import com.facebook.react.modules.network.OkHttpClientFactory
import com.facebook.react.modules.network.ReactCookieJarContainer
import okhttp3.OkHttpClient
import java.io.ByteArrayInputStream
import java.security.KeyStore
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManagerFactory

/**
 * 自定义 OkHttpClient 工厂，仅信任内置的自签名证书
 */
class CustomOkHttpClientFactory(private val context: Context) : OkHttpClientFactory {

    override fun createNewNetworkModuleClient(): OkHttpClient {
        val trustManager = createTrustManager()
        val sslContext = SSLContext.getInstance("TLS")
        sslContext.init(null, arrayOf(trustManager), null)

        return OkHttpClient.Builder()
            .cookieJar(ReactCookieJarContainer())
            .sslSocketFactory(sslContext.socketFactory, trustManager)
            .hostnameVerifier { _, _ -> true }
            .build()
    }

    private fun createTrustManager(): javax.net.ssl.X509TrustManager {
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

        return trustManagerFactory.trustManagers.first { it is javax.net.ssl.X509TrustManager }
                as javax.net.ssl.X509TrustManager
    }
}
