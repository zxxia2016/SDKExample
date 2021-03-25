# AjustSDK 说明
## 1.接入参考官方地址：
- https://github.com/adjust/ios_sdk
## 2.接入步骤：
1. 下载SDK：通过[Adjust GitHub](https://github.com/adjust/ios_sdk/releases) 下载文件名为 **AdjustSdkImDynamic.framework.zip** 的压缩包
2. 将SDK添加到Xcode工程，添加方式，直接将文件夹拉到Xcode工程中，如图：![image](https://raw.githubusercontent.com/zxxia2016/SDKExample/main/Ios/AdjustSDK/Image/1.jpg)
3. 发布ipa报错：**IPA processing failed**
   1. 原因：SDK 不包含某些cpu架构问题导致的
   2. 解决方案：https://www.jianshu.com/p/42c3a7cbdb3f
4. 编码部分:
   1. AppController.h中添加头文件,并添加以下代码
    ```
    #import <AdjustSdk/Adjust.h>
   @interface AppController : NSObject <UIApplicationDelegate, AdjustDelegate>
   ```
   1. AppController.mm中注册函数回调，添加以下代码       
    ``` 
    - (void)adjustAttributionChanged:(ADJAttribution *)attribution
    - (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData
    - (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData
    ```
    1. didFinishLaunchingWithOptions函数中调用初始化函数,添加以下代码
    ```
    [[AdjustSDKHelp getInstance] init: self];
    ```
5. 具体实现查看AdjustSDKHelp.m文件
    1. 初始化
    ```
    -(void) init: (id)observer
    ```
    1. 设置Debug模式
    ```
    static bool Debug = true;
    ```
    1. 设置AppToken
    ```
    NSString *yourAppToken = Debug ? @"yourAppToken" : key;
    ```
    1. 获取渠道变量
    ```
    static NSString* AdjustKey = @"";
    ```
    1. 打点
    ```
    -(void)logEvent: (NSString *)eventType andData: (NSString *)data 
    ```
