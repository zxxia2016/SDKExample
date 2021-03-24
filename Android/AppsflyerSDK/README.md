# AppsflyerSDK 说明
## 1.接入参考官方地址：
- https://support.appsflyer.com/hc/en-us
- https://support.appsflyer.com/hc/en-us/articles/207032126-Android-SDK-integration-for-developers#Integration
## 2.接入步骤：
1. 添加依赖库,权限，混淆等
   1. **build.gradle**中加入以下代码
   ```
    implementation 'com.appsflyer:af-android-sdk:5.0.0@aar'
    implementation 'com.android.installreferrer:installreferrer:1.0'
   ```
   2. **AndroidManifest.xml**中加入以下代码, **AF_PRE_INSTALL_NAME**添加预安装渠道
   ```
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>

    <receiver android:name="com.appsflyer.MultipleInstallBroadcastReceiver"
      android:permission="android.permission.INSTALL_PACKAGES">
      <intent-filter>
          <action android:name="com.android.vending.INSTALL_REFERRER" />
      </intent-filter>
    </receiver>

    <meta-data android:name="AF_PRE_INSTALL_NAME" android:value="" />

   ```
   3. proguard-rules.pro文件中添加以下代码
   ```
   -keep public class com.android.installreferrer.** { *; }

   ```
2. 编码部分:
   1. Application派生类onCreate函数中添加初始化代码，并传入token和预安装渠道
    ```
    import org.games.sdk.AppsflyerHelp;
    AppsflyerHelp.getInstance().init(this, apps_flyer_key);
   ```
3. 具体实现查看AppsflyerHelp.java文件
    1. 初始化，并设置key
    ```
    public void init(Context AppContent, String key)
    ```
    2. 
    ```
    
    ```
    3. 获取渠道函数
    ```
    public String getMediaSource()
    ```
    4. 打点
    ```
    public void trackEvent(String eventType, String jsonData)
    ```
