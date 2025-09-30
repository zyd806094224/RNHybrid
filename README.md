# RNHybrid

基础的React Native页面嵌入Android应用内部的混合开发Demo。

## 项目简介

本项目演示了如何将React Native页面集成到原生Android应用中，实现混合开发模式。通过这种方式，可以在现有的原生Android应用中使用React Native技术来构建部分功能界面，兼具原生应用的性能和React Native的开发效率。

## 项目结构

```
.
├── android/                 # 原生Android项目代码
│   ├── app/src/main/java/com/example/rnandroiddemo/
│   │   ├── MainActivity.java      # 主Activity，包含跳转到RN页面的按钮
│   │   └── RNPageActivity.java    # 专门用于加载React Native页面的Activity
├── App.js                   # React Native主页面组件
├── index.js                 # React Native入口文件
├── app.json                 # React Native应用配置
└── package.json             # 项目依赖配置
```

## 工作原理

1. 原生Android应用作为主体框架运行
2. 在需要的地方（如按钮点击）启动专门的[RNPageActivity](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/android/app/src/main/java/com/example/rnandroiddemo/RNPageActivity.java#L13-L69)来加载React Native页面
3. [RNPageActivity](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/android/app/src/main/java/com/example/rnandroiddemo/RNPageActivity.java#L13-L69)使用ReactInstanceManager初始化React Native环境并加载JS bundle
4. React Native页面在原生应用的Activity中渲染显示

## 核心代码解析

### Android端集成

1. [MainActivity.java](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/android/app/src/main/java/com/example/rnandroiddemo/MainActivity.java)中添加按钮点击事件，跳转到[RNPageActivity](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/android/app/src/main/java/com/example/rnandroiddemo/RNPageActivity.java#L13-L69)

```java
findViewById(R.id.btn).setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        startActivity(new Intent(MainActivity.this, RNPageActivity.class));
    }
});
```

2. [RNPageActivity](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/android/app/src/main/java/com/example/rnandroiddemo/RNPageActivity.java#L13-L69)负责初始化React Native环境并加载页面

### React Native端

1. [App.js](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/App.js)为React Native页面组件
2. [index.js](file:///Users/zhaoyudong/IdeaProjects/RNHybrid/index.js)为入口文件，注册组件

```javascript
AppRegistry.registerComponent('RNHybrid', () => App);
```

## 运行项目

1. 安装依赖：
```
npm install
```

2. 构建Android项目：
```
# 在android目录下执行
./gradlew assembleDebug
```

3. 安装APK到设备或模拟器

4. 点击主界面按钮进入React Native页面

## 集成要点

1. 在Android项目中添加React Native依赖
2. 配置网络权限等必要权限
3. 创建专门的Activity加载React Native页面
4. 正确处理生命周期方法
5. 处理返回键等系统按键事件

# 更多集成细节参考地址
https://mp.weixin.qq.com/s/kUWLF-GCl60_mZ6aPH962A

