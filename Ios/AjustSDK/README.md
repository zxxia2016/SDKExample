# AjustSDK 说明
1、接入参考地址：https://github.com/adjust/ios_sdk
2、通过这里（https://github.com/adjust/ios_sdk/releases）下载SDK，文件名为（AdjustSdkImDynamic.framework.zip
）
3、将SDK添加到Xcode工程，添加方式，直接将文件夹拉到Xcode工程中
4、开始编码部分:
    AppController.h中
        添加#import <AdjustSdk/Adjust.h>
        @interface AppController : NSObject <UIApplicationDelegate, AdjustDelegate>
    AppController.mm中
    - (void)adjustAttributionChanged:(ADJAttribution *)attribution
    - (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData
    - (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData
    didFinishLaunchingWithOptions函数中调用初始化函数[[AdjustSDKHelp getInstance] init: self];
5、具体实现查看AdjustSDKHelp.m文件
    该文件实现了初始化，打点、获取渠道这3个功能，只要配置yourAppToken，并设置Debug模式就可以运行
