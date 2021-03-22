/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2016 Chukong Technologies Inc.
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "AppController.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SDKWrapper.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "AdjustSDKHelp.h"
#import "FacebookSDKMgr.h"

using namespace cocos2d;

@implementation AppController

Application* app = nullptr;
static RootViewController* s_viewController = nullptr;
@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

// Objective-C // // 将下列代码添加到文件的头文件中，例如：在 ViewController.m 中 // 在 #import "ViewController.h" 之后 #import <FBSDKCoreKit/FBSDKCoreKit.h> #import <FBSDKLoginKit/FBSDKLoginKit.h> // 将下列代码添加到正文：@implementation ViewController - (void)viewDidLoad { [super viewDidLoad]; FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init]; // Optional: Place the button in the center of your view. loginButton.center = self.view.center; [self.view addSubview:loginButton]; } @end

// Objective-C - (void)viewDidLoad { [super viewDidLoad]; if ([FBSDKAccessToken currentAccessToken]) { // User is logged in, do work such as go to next view controller. } }

// Objective-C // // 展开 6a 中的代码示例。将 Facebook 登录功能添加到代码中 // 将下列代码添加到 viewDidLoad 方法中：loginButton.readPermissions = @[@"public_profile", @"email"];
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [[FacebookSDKMgr getInstance] application:application openURL:url options:options];
    return YES;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[SDKWrapper getInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[FacebookSDKMgr getInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Add the view controller's view to the window and display.
    float scale = [[UIScreen mainScreen] scale];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame: bounds];
    
    // cocos2d application instance
    app = new AppDelegate(bounds.size.width * scale, bounds.size.height * scale);
    app->setMultitouch(true);
    
    // Use RootViewController to manage CCEAGLView
    _viewController = [[RootViewController alloc]init];
#ifdef NSFoundationVersionNumber_iOS_7_0
    _viewController.automaticallyAdjustsScrollViewInsets = NO;
    _viewController.extendedLayoutIncludesOpaqueBars = NO;
    _viewController.edgesForExtendedLayout = UIRectEdgeAll;
#else
    _viewController.wantsFullScreenLayout = YES;
#endif
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:_viewController];
    }
    s_viewController = _viewController;
    [window makeKeyAndVisible];
    
    [[AdjustSDKHelp getInstance] init: self];
    [[FacebookSDKMgr getInstance] initSdk:_viewController];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(statusBarOrientationChanged:)
        name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    //run the cocos2d-x game scene
    app->start();
    
    return YES;
}
+(void)logEvent: (NSString *)eventType andData: (NSString *)data andType: (NSString *)currencyType {
//    [[AdjustSDKHelp getInstance] logEvent: eventType andData: data andType: currencyType];
    [[FacebookSDKMgr getInstance] share:@""];
}
- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    [[AdjustSDKHelp getInstance] adjustAttributionChanged: attribution];
}
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    [[AdjustSDKHelp getInstance] adjustEventTrackingSucceeded: eventSuccessResponseData];
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    [[AdjustSDKHelp getInstance] adjustEventTrackingFailed: eventFailureResponseData];
}

- (void)statusBarOrientationChanged:(NSNotification *)notification {
    CGRect bounds = [UIScreen mainScreen].bounds;
    float scale = [[UIScreen mainScreen] scale];
    float width = bounds.size.width * scale;
    float height = bounds.size.height * scale;
    Application::getInstance()->updateViewSize(width, height);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [[SDKWrapper getInstance] applicationWillResignActive:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[SDKWrapper getInstance] applicationDidBecomeActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [[SDKWrapper getInstance] applicationDidEnterBackground:application];
    app->applicationDidEnterBackground();
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [[SDKWrapper getInstance] applicationWillEnterForeground:application];
    app->applicationWillEnterForeground();
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SDKWrapper getInstance] applicationWillTerminate:application];
    delete app;
    app = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end
