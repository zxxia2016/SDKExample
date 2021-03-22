//
//  FacebookSDKHelp.h
//  hello_world-mobile
//
//  Created by apple on 19.03.21.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FacebookSDKMgr : NSObject
+ (instancetype) getInstance;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)initSdk:(RootViewController *)viewController;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

- (void)login;

- (void)logout;

- (void)share:(NSString *)shareInfo;

@end

NS_ASSUME_NONNULL_END
