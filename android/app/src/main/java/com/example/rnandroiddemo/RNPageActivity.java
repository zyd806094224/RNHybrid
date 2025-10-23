package com.example.rnandroiddemo;

import android.os.Bundle;
import android.os.AsyncTask;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.io.File;

import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.shell.MainReactPackage;
import com.swmansion.rnscreens.RNScreensPackage;
import com.th3rdwave.safeareacontext.SafeAreaContextPackage;

public class RNPageActivity extends AppCompatActivity implements DefaultHardwareBackBtnHandler {

    private ReactRootView mReactRootView;
    private ReactInstanceManager mReactInstanceManager;
    private static final String BUNDLE_URL = "http://106.15.7.132:888/download/index.android.bundle";
    private static final String TAG = "RNPageActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 启动下载任务
//        new DownloadBundleTask().execute(BUNDLE_URL);
        initializeReactNative();
    }

    private void initializeReactNative() {
        String bundleFilePath = getApplication().getFilesDir() + "/index.android.bundle";

        mReactRootView = new ReactRootView(this);
        mReactInstanceManager = ReactInstanceManager.builder()
                .setApplication(getApplication())
                .setCurrentActivity(this)
                .setJSBundleFile(bundleFilePath) // 自定义内部存储路径 使用远程地址
                .setJSMainModulePath("index")
                .addPackage(new MainReactPackage())
                // 路由需要
                .addPackage(new RNScreensPackage())
                // 路由需要
                .addPackage(new SafeAreaContextPackage())
                .setUseDeveloperSupport(true) //是否开启调试模式
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .build();

        // 这个"RNHybrid"名字一定要和我们在index.js中注册的名字保持一致AppRegistry.registerComponent()
        mReactRootView.startReactApplication(mReactInstanceManager, "RNHybrid", null);
        setContentView(mReactRootView);
    }

    private class DownloadBundleTask extends AsyncTask<String, Void, Boolean> {
        @Override
        protected Boolean doInBackground(String... urls) {
            try {
                String bundleUrl = urls[0];
                String filePath = getApplication().getFilesDir() + "/index.android.bundle";

                URL url = new URL(bundleUrl);
                URLConnection connection = url.openConnection();
                InputStream input = connection.getInputStream();

                File file = new File(filePath);
                OutputStream output = new FileOutputStream(file);

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = input.read(buffer)) != -1) {
                    output.write(buffer, 0, bytesRead);
                }

                output.close();
                input.close();

                return true;
            } catch (Exception e) {
                Log.e(TAG, "Failed to download bundle", e);
                return false;
            }
        }

        @Override
        protected void onPostExecute(Boolean success) {
            if (success) {
                Log.d(TAG, "Bundle downloaded successfully");
                initializeReactNative();
            } else {
                Log.e(TAG, "Failed to download bundle, using default initialization");
                initializeReactNative();
            }
        }
    }

    @Override
    public void invokeDefaultOnBackPressed() {
        super.onBackPressed();
    }

    @Override
    public void onBackPressed() {
        if (mReactInstanceManager != null) {
            mReactInstanceManager.onBackPressed();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (mReactInstanceManager != null) {
            mReactInstanceManager.onHostDestroy(this);
        }
        if (mReactRootView != null) {
            mReactRootView.unmountReactApplication();
        }
    }
}
