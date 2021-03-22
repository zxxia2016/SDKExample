//
//  FacebookSDKMgr.m
//  hello_world-mobile
//
//  Created by apple on 19.03.21.
//

#import "FacebookSDKMgr.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FacebookSDKMgr() <FBSDKSharingDelegate> {
    
}

@property (nonatomic, strong) RootViewController *viewController;

@property (nonatomic, strong) FBSDKLoginManager *loginManager;

@end

@implementation FacebookSDKMgr

static FacebookSDKMgr* _instance = nil;

#pragma mark -
#pragma mark Singleton

+(instancetype) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [FacebookSDKMgr getInstance] ;
}

+(id) copyWithZone:(struct _NSZone *)zone
{
    return [FacebookSDKMgr getInstance] ;
}
/**
 结果类型
 */
typedef NS_ENUM(NSInteger, ResultType) {
    ResultTypeLoginSuccess,    //登录成功
    ResultTypeLoginCancel,    //登录取消
    ResultTypeLoginError,    //登录错误
    ResultTypeShareSuccess,    //分享成功
    ResultTypeShareCancel,    //分项取消
    ResultTypeShareError,    //分享错误
};
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return true;
}
- (void)initSdk:(RootViewController *)viewController {
    NSLog(@"%s", __FUNCTION__);
    
    self.viewController = viewController;
    
    [self initLogin];
    [self initShare];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url options:options];
    return YES;
    
}

#pragma mark - 登录

/**
 初始化登录
 */
- (void)initLogin {
    NSLog(@"%s", __FUNCTION__);
    
    self.loginManager = [[FBSDKLoginManager alloc] init];
}

/**
 登录
 */
- (void)login {
    NSLog(@"%s", __FUNCTION__);
    
    if ([self isAuthorization]) {
        //已经授权
        [self requestAuthInfo];
        return;
    }
    
    [self.loginManager logInWithPermissions:@[@"public_profile", @"email"]
                         fromViewController:self.viewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        NSLog(@"%s, FBSDKLoginManagerLoginResult, result: %@, error: %@", __FUNCTION__, result, error);
        
        if (error) {
            //登录错误
            NSLog(@"%s, FBSDKLoginManagerLoginResult error", __FUNCTION__);
            
            [self notifyToJs:ResultTypeLoginError params:[NSString stringWithFormat:@"%ld", (long)error.code]];
            return;
        }
        
        if (result) {
            if (result.isCancelled) {
                //登录取消
                NSLog(@"%s, FBSDKLoginManagerLoginResult cancel", __FUNCTION__);
                
                [self notifyToJs:ResultTypeLoginCancel params:@"login cancel"];
                return;
            }
            
            //登录成功
            NSLog(@"%s, FBSDKLoginManagerLoginResult success", __FUNCTION__);
            
            //获取授权信息
            [self requestAuthInfo];
        }
    }];
}

/**
 是否授权
 */
- (BOOL)isAuthorization {
    NSLog(@"%s", __FUNCTION__);
    
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    if (accessToken == nil) {
        return NO;
    }
    
    return !accessToken.isExpired;
}

/**
 获取授权信息
 */
- (void)requestAuthInfo {
    NSLog(@"%s", __FUNCTION__);
    
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    NSDictionary *params = @{@"fields":@"id,name,gender,email,picture"};
    FBSDKGraphRequest *graphRequest = [[FBSDKGraphRequest alloc]
                                       initWithGraphPath:accessToken.userID
                                       parameters:params];
    [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                               id result,
                                               NSError *error) {
        NSLog(@"%s, FBSDKGraphRequestConnection, result: %@, error: %@", __FUNCTION__, result, error);
        
        if (error) {
            //授权错误
            NSLog(@"%s, FBSDKGraphRequestConnection error", __FUNCTION__);
            
            [self notifyToJs:ResultTypeLoginError params:[NSString stringWithFormat:@"%ld", (long)error.code]];
            return;
        }
        
        if (result) {
            //授权成功
            NSLog(@"%s, FBSDKGraphRequestConnection success", __FUNCTION__);
            
            NSString *NSid = [result objectForKey:@"id"];
            NSString *name = [result objectForKey:@"name"];
            NSString *gender = [result objectForKey:@"gender"];
            NSString *email = [result objectForKey:@"email"];
            NSString *picture = @"";
            NSDictionary *objPicture = [result objectForKey:@"picture"];
            if (objPicture) {
                NSDictionary *objPictureData = [objPicture objectForKey:@"data"];
                if (objPictureData) {
                    NSString *NSpictureDataUrl = [objPictureData objectForKey:@"url"];
                    if (NSpictureDataUrl) {
                        picture = NSpictureDataUrl;
                    }
                }
            }
            NSString *avatar = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", NSid];
            NSString *authInfo = [NSString stringWithFormat:@"{\"id\":\"%@\",\"name\":\"%@\",\"gender\":\"%@\",\"email\":\"%@\",\"picture\":\"%@\",\"avatar\":\"%@\"}",
                                 NSid, name, gender, email, picture, avatar];
            
            [self notifyToJs:ResultTypeLoginSuccess params:authInfo];
        }
    }];
}

/**
 登出
 */
- (void)logout {
    NSLog(@"%s", __FUNCTION__);
    
    [self.loginManager logOut];
}

#pragma mark - 分享

/**
 初始化分享
 */
- (void)initShare {
    NSLog(@"%s", __FUNCTION__);
}

/**
 分享
 @param shareInfo 分享信息
 */
- (void)share:(NSString *)shareInfo {
    NSLog(@"%s, shareInfo: %@", __FUNCTION__, shareInfo);
    
    NSData *data = [shareInfo dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSNumber *shareType = [dictionary objectForKey:@"shareType"];
    NSString *shareUrl = [dictionary objectForKey:@"shareUrl"];
    NSString *imgPath = [dictionary objectForKey:@"imgPath"];
    
    if ([shareType intValue] == 0) {
        //链接
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:shareUrl];
        
        [FBSDKShareDialog showFromViewController:self.viewController
                                     withContent:content
                                        delegate:self];
    } else if ([shareType intValue] == 1) {
        //图片
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imgPath];
        
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = image;
        photo.userGenerated = YES;
        
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        
        [FBSDKShareDialog showFromViewController:self.viewController
                                     withContent:content
                                        delegate:self];
    }
}

#pragma mark - FBSDKSharingDelegate

/**
  Sent to the delegate when the share completes without error or cancellation.
 @param sharer The FBSDKSharing that completed.
 @param results The results from the sharer.  This may be nil or empty.
 */
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary<NSString *, id> *)results {
    NSLog(@"%s, results: %@", __FUNCTION__, results);
    
    [self notifyToJs:ResultTypeShareSuccess params:@"share success"];
}

/**
  Sent to the delegate when the sharer encounters an error.
 @param sharer The FBSDKSharing that completed.
 @param error The error.
 */
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [self notifyToJs:ResultTypeShareError params:[NSString stringWithFormat:@"%ld", (long)error.code]];
}
/**
  Sent to the delegate when the sharer is cancelled.
 @param sharer The FBSDKSharing that completed.
 */
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"%s", __FUNCTION__);
    
    [self notifyToJs:ResultTypeShareCancel params:@"share cancel"];
}

#pragma mark - 通知js

/**
 通知js
 @param resultType 类型
 @param params 透传参数
 */
- (void)notifyToJs:(ResultType)resultType params:(NSString *)params {
    NSLog(@"%s, resultType: %ld, params: %@", __FUNCTION__, (long)resultType, params);
    
    NSString *funcName = @"";
    switch (resultType) {
        case ResultTypeLoginSuccess:
            funcName = @"cc.onFacebookLoginSuccess";
            break;
        case ResultTypeLoginCancel:
            funcName = @"cc.onFacebookLoginCancel";
            break;
        case ResultTypeLoginError:
            funcName = @"cc.onFacebookLoginError";
            break;
        case ResultTypeShareSuccess:
            funcName = @"cc.onFacebookShareSuccess";
            break;
        case ResultTypeShareCancel:
            funcName = @"cc.onFacebookShareCancel";
            break;
        case ResultTypeShareError:
            funcName = @"cc.onFacebookShareError";
            break;
        default:
            funcName = nil;
            break;
    }
    
    if (funcName == nil) {
        NSLog(@"%s, error: %@", __FUNCTION__, @"funcName is nil");
        return;
    }
    
    if (params == nil) {
        params = @"";
    }
    
    NSString *eval = [NSString stringWithFormat:@"%@('%@')", funcName, params];
    const char *c_eval = [eval UTF8String];
//    se::ScriptEngine::getInstance()->evalString(c_eval);
}
    
@end
