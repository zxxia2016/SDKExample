# facebook SDK 说明
## 1.接入参考官方地址：
- https://developers.facebook.com/docs
## 2.接入步骤：
1. 下载SDK：通过[facebook GitHub](https://github.com/facebook/facebook-ios-sdk/releases) 下载文件名为 **FacebookSDK_Dynamic.framework.zip** 的压缩包
2. 将**FBSDKCoreKit.framework** **FBSDKLoginKit.framework** **FBSDKShareKit.framework**添加到Xcode工程，添加方式，直接将文件夹拉到Xcode工程中，如图：![image](https://raw.githubusercontent.com/zxxia2016/SDKExample/main/Ios/FacebookSDK/Image/1.jpg)，注意图中箭头的部分；如果是oc的项目，务必把图中的选项设置成Yes，![image](https://raw.githubusercontent.com/zxxia2016/SDKExample/main/Ios/FacebookSDK/Image/2.jpg)
3. Info.plist中添加如下代码,xxxx部分对应填写
   ```
   <key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>fbxxxx</string>
			</array>
		</dict>
	</array>
    <key>FacebookAppID</key>
	<string>xxxxx</string>
	<key>FacebookAppSecret</key>
	<string>xxxx</string>
	<key>FacebookDisplayName</key>
	<string>xxxx</string>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>fbapi</string>
		<string>fbapi20130214</string>
		<string>fbapi20130410</string>
		<string>fbapi20130702</string>
		<string>fbapi20131010</string>
		<string>fbapi20131219</string>
		<string>fbapi20140410</string>
		<string>fbapi20140116</string>
		<string>fbapi20150313</string>
		<string>fbapi20150629</string>
		<string>fbapi20160328</string>
		<string>fbauth</string>
		<string>fb-messenger-share-api</string>
		<string>fbauth2</string>
		<string>fbshareextension</string>
	</array>
   ```
4. 编码部分:
    1. AppController.mm中引入文件头     
    ``` 
    #import "FacebookSDKMgr.h"
    ```
    2. didFinishLaunchingWithOptions函数中调用初始化函数,添加以下代码
    ```
    [[FacebookSDKMgr getInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    [[FacebookSDKMgr getInstance] initSdk:_viewController];
    ```
    3. 添加如下代码
    ```
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
       [[FacebookSDKMgr getInstance] application:application openURL:url options:options];
       return YES;
       
    }
    ```
5. FacebookSDKMgr.m文件
    1. 初始化
    ```
    - (void)initSdk:(RootViewController *)viewController
    ```
    2. 登录
    ```
    - (void)login
    ```
    3. 登出
    ```
    - (void)logout
    ```
    4. 分享
    ```
    - (void)share:(NSString *)shareInfo
    ```
    
    5. 打点
    ```
    -(void)logEvent:(NSString*) eventName number:(NSNumber *)number currencyType:(NSString*) currencyType
    ```
