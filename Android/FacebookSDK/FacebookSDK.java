package org.games.sdk;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;


import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.LoggingBehavior;
import com.facebook.LoginStatusCallback;
import com.facebook.appevents.AppEventsConstants;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;


import android.content.SharedPreferences;

import java.math.BigDecimal;
import java.util.Calendar;

import org.cocos2dx.javascript.AppActivity;
import org.cocos2dx.lib.Cocos2dxJavascriptJavaBridge;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.Currency;

//insert class

public class FacebookSDK {

    //insert var

    private FacebookSDK() {
        super();
    }

    private static FacebookSDK instance;

    private static String NotifyEvent = "facebookLoginResult";

    private AppEventsLogger logger;
    private SharedPreferences preferences;
    private SharedPreferences.Editor editor;

    public static FacebookSDK getInstance() {
        if (instance == null) {
            instance = new FacebookSDK();
        }
        return instance;
    }

    private CallbackManager callbackManager;
    private static ShareDialog shareDialog;

    private static String Tag = "FacebookSDK";

    public void init(final AppActivity activity) {
        //insert code

        Log.e(FacebookSDK.Tag, "facebook init");

        AppEventsLogger.activateApp(activity.getApplication());

        logger = AppEventsLogger.newLogger(activity);
        //调用标准事件
        logUnlockAchievementEvent("OpenApplication");
        FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS);
        // 次流检测
        GetTime(activity);

        callbackManager = CallbackManager.Factory.create();

        shareDialog = new ShareDialog(activity);

        LoginManager.getInstance().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        //insert code

                        Log.e(FacebookSDK.Tag, "facebook loginResult");
                        // App code
                        FacebookSDK.getInstance().reqUserInfo(activity, loginResult.getAccessToken());
                    }

                    @Override
                    public void onCancel() {
                        //insert code

                        // App code
                        String msg = "facebook onCancel";
                        Log.e(FacebookSDK.Tag, msg);
                        FacebookSDK.getInstance().loginResult(2, msg);
                    }

                    @Override
                    public void onError(FacebookException exception) {
                        //insert code

                        // App code
                        String strMsg = exception.toString();
                        String msg = "facebook error: " + strMsg;
                        Log.e(FacebookSDK.Tag, msg);
                        FacebookSDK.getInstance().loginResult(3, strMsg);

                        if (exception instanceof FacebookException) {
                            FacebookSDK.getInstance().logout();
                        }
                    }
                });
    }

    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        //insert code

        callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    public void login(final Activity activity) {
        //insert code

        if (this.isLogon()) {
            Log.e(FacebookSDK.Tag, "facebook retry login");
            LoginManager.getInstance().retrieveLoginStatus(activity, new LoginStatusCallback() {
                @Override
                public void onCompleted(AccessToken accessToken) {
                    Log.e(FacebookSDK.Tag, "retrieveLoginStatus success");
                    FacebookSDK.getInstance().reqUserInfo(activity, accessToken);
                }

                @Override
                public void onFailure() {
                    String strMsg = "retrieveLoginStatus onFailure";
                    Log.e(FacebookSDK.Tag, strMsg);
                    FacebookSDK.getInstance().loginResult(4, strMsg);
                }

                @Override
                public void onError(Exception exception) {
                    String strMsg = "retrieveLoginStatus onError";
                    Log.e(FacebookSDK.Tag, strMsg);
                    FacebookSDK.getInstance().loginResult(5, strMsg);
                }
            });

        } else {
            Log.e(FacebookSDK.Tag, "facebook login");
            LoginManager.getInstance().setLoginBehavior(LoginBehavior.NATIVE_WITH_FALLBACK);
            LoginManager.getInstance().logInWithReadPermissions(activity, Arrays.asList("public_profile"));
        }
    }

    public void reqUserInfo(final Activity activity, AccessToken accessToken) {
        //insert code

        GraphRequest request = GraphRequest.newMeRequest(accessToken, new GraphRequest.GraphJSONObjectCallback() {
            @Override
            public void onCompleted(JSONObject object, GraphResponse response) {
                if (object != null) {
                    Log.e(FacebookSDK.Tag, "GraphRequest onCompleted: " + object.toString());

                    //获取用户头像
                    JSONObject object_pic = object.optJSONObject("picture");
                    JSONObject object_data = object_pic.optJSONObject("data");
                    final String url = object_data.optString("url");
                    final String name = object.optString("name");
                    final String  uid = object.optString("id");
                    try {
                        JSONObject mJsonobjData = new JSONObject();
                        mJsonobjData.put("uid", uid);
                        mJsonobjData.put("name", name);
                        mJsonobjData.put("url", url);
                        mJsonobjData.put("code", 0);
                        String dataStr = mJsonobjData.toString();

                        AppActivity.g_this.runOnGLThread(new Runnable() {
                            @Override
                            public void run() {
                                Cocos2dxJavascriptJavaBridge.evalString("cc.mg.native_class.loginFaceBookSuccess(\""+uid+"\",\""+name+"\",\""+url+"\")");
                            }
                        });
                    } catch (Exception e) {
                        // TODO: handle exception
                        e.printStackTrace();
                    }
                } else {
                    String strMsg = response.toString();
                    String msg = "facebook loginResult error: " + strMsg;
                    Log.e(FacebookSDK.Tag, msg);
                    FacebookSDK.getInstance().loginResult(1, strMsg);
                }
            }
        });
        Bundle parameters = new Bundle();
        parameters.putString("fields", "id,name,link,gender,birthday,email,picture,locale,updated_time,timezone,age_range,first_name,last_name");
        request.setParameters(parameters);
        request.executeAsync();
    }

    public void loginResult(int code, String msg) {
        //insert code

        try {
            JSONObject mJsonobjData = new JSONObject();
            mJsonobjData.put("code", code);
            mJsonobjData.put("msg", msg);
            String dataStr = mJsonobjData.toString();
            Toast.makeText(AppActivity.getContext(), msg, Toast.LENGTH_LONG).show();

        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
        }
    }

    public void logout() {
        //insert code

        LoginManager.getInstance().logOut();
    }

    public boolean isLogon() {
        //insert code

        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if (accessToken != null && accessToken.isExpired()) {
            return true;
        }
        return false;
    }

    public void shareUrl(String Url) {
        //insert code

        if (Url != null) {
            if (ShareDialog.canShow(ShareLinkContent.class)) {
                ShareLinkContent linkContent = new ShareLinkContent.Builder()
                        .setContentUrl(Uri.parse(Url))
                        .build();
                shareDialog.show(linkContent);
            }
        }
    }

    public void logEvent(String eventName, String description) {
        //insert code

        Bundle params = new Bundle();
        params.putString("description", description);
        logger.logEvent(eventName, params);
    }

    public void FbLogEvent(String eventName, double n_number, String CurrencyType){

        if (eventName.equals("AppRecharge")) {
            logger.logPurchase(BigDecimal.valueOf(n_number), Currency.getInstance(CurrencyType));
        }else{
            Bundle params = new Bundle();
            params.putDouble(AppEventsConstants.EVENT_PARAM_NUM_ITEMS, n_number);
            params.putDouble(AppEventsConstants.EVENT_PARAM_VALUE_TO_SUM, n_number);
            if(!CurrencyType.equals("")){
                params.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, CurrencyType);
            }
            params.putDouble("Num", n_number);
            logger.logEvent(eventName, params);
        }

    }

    public void logUnlockAchievementEvent(String description) {
        //insert code

        Bundle params = new Bundle();
        params.putString(AppEventsConstants.EVENT_PARAM_DESCRIPTION, description);
        logger.logEvent(AppEventsConstants.EVENT_NAME_UNLOCKED_ACHIEVEMENT, params);
    }

    // 第二天登录
    private void logLoginNextDayEvent(String description) {
        //insert code

        Bundle params = new Bundle();
        params.putString("description", description);
        logger.logEvent("LoginNextDay", params);
    }

    //判断是否是昨天

    /**
     * 将时间戳转换成描述性时间（昨天、今天、明天）
     *
     * @param timestamp 时间戳
     * @return 描述性日期
     */
    private void descriptiveData(long timestamp) {
        //insert code

        String descriptiveText = null;
        String format = "yyyy-MM-dd HH:mm:ss";
        //当前时间
        Calendar currentTime = Calendar.getInstance();
        currentTime.setTimeInMillis(System.currentTimeMillis());
        //要转换的时间
        Calendar time = Calendar.getInstance();
        time.setTimeInMillis(timestamp);
        //年相同
        if (currentTime.get(Calendar.YEAR) == time.get(Calendar.YEAR)) {
            //获取一年中的第几天并相减，取差值
            switch (currentTime.get(Calendar.DAY_OF_YEAR) - time.get(Calendar.DAY_OF_YEAR)) {
                case 1://当前比目标多一天，那么目标就是昨天
                    descriptiveText = "昨天";
                    format = "HH:mm:ss";
                    logLoginNextDayEvent("LoginNextDay");
                    SaveTime();
                    break;
                case 0://当前和目标是同一天，就是今天
                    descriptiveText = "今天";
                    format = "HH:mm:ss";
                    break;
                default:
                    descriptiveText = null;
                    format = "yyyy-MM-dd HH:mm:ss";
                    SaveTime();
                    break;
            }
        }
    }

    private void GetTime(AppActivity activity) {
        //insert code

        preferences = activity.getSharedPreferences("IpAndPort", AppActivity.MODE_PRIVATE);
        editor = preferences.edit();
        long lastTime = preferences.getLong("TIME", 00000000);
        if (lastTime == 00000000) {
            SaveTime();
            return;
        } else {
            descriptiveData(lastTime);
        }
    }

    private void SaveTime() {
        //insert code

        long nowTime = System.currentTimeMillis();
        editor.putLong("TIME", nowTime);
        editor.commit();//写入
    }
}
