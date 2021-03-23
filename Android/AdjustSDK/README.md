# AjustSDK 说明
## 1.接入参考官方地址：
- https://github.com/adjust/android_sdk
## 2.接入步骤：
1. 添加依赖库,权限，混淆等
   1. **build.gradle**中加入以下代码
   ```
    implementation 'com.adjust.sdk:adjust-android:4.27.0'
    implementation 'com.android.installreferrer:installreferrer:2.2'
   ```
   2. **AndroidManifest.xml**中加入以下代码
   ```
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>

    <receiver
    android:name="com.adjust.sdk.AdjustReferrerReceiver"
    android:permission="android.permission.INSTALL_PACKAGES"
    android:exported="true" >
    <intent-filter>
        <action android:name="com.android.vending.INSTALL_REFERRER" />
    </intent-filter>
    </receiver>
   ```
   3. proguard-rules.pro文件中添加以下代码
   ```
   -keep class com.adjust.sdk.** { *; }
    -keep class com.google.android.gms.common.ConnectionResult {
        int SUCCESS;
    }
    -keep class com.google.android.gms.ads.identifier.AdvertisingIdClient {
        com.google.android.gms.ads.identifier.AdvertisingIdClient$Info getAdvertisingIdInfo(android.content.Context);
    }
    -keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info {
        java.lang.String getId();
        boolean isLimitAdTrackingEnabled();
    }
    -keep public class com.android.installreferrer.** { *; }

   ```
2. 编码部分:
   1. Application派生类onCreate函数中添加初始化代码，并传入token和预安装渠道
    ```
    import org.games.sdk.AdjustSDKHelp;
    AdjustSDKHelp.getInstance().init(this, apptoken, preinstallKey);
   ```
3. 具体实现查看AdjustSDKHelp.java文件
    1. 初始化，并设置apptoken，预安装渠道非必须
    ```
    public void init(Application application, String apptoken, String preinstallKey) 
    ```
    2. 设置生产模式
    ```
    String environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
    ```
    3. 获取渠道函数
    ```
    public String getAdJustKey()
    ```
    4. 打点
    ```
    public void logEvent(String eventType, String jsonData, String CurrencyType)
    ```
