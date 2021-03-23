# facebook SDK 说明
## 1.接入参考官方地址：
- https://developers.facebook.com/docs
## 2.facebook登录接入步骤：
1. 项目设置，参考官网，已经说明的很清楚了 https://developers.facebook.com/docs/facebook-login/
2. 编码部分:
    1. AppActivity.java **onCreate**和**onActivityResult** 中添加以下代码    
    ``` 
    import org.games.sdk.FacebookSDK;

    FacebookSDK.getInstance().init(AppActivity.g_this);

    FacebookSDK.getInstance().onActivityResult(AppActivity.g_this, requestCode, resultCode, data);
    ```
3. FacebookSDK.java文件
    1. 初始化
    ```
    public void init(final AppActivity activity)
    ```
    2. 登录
    ```
    public void login(final Activity activity)
    ```
    3. 分享
    ```
    public void shareUrl(String Url)
    ```
    4. 打点
    ```
    public void logEvent(String eventName, String description)
    ```
