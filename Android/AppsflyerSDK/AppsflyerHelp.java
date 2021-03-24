package org.games.sdk;

import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;
import com.appsflyer.AppsFlyerLibCore;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import android.content.Context;
import android.util.Log;

import org.cocos2dx.javascript.App;
import org.json.JSONException;
import org.json.JSONObject;

//insert class

public class AppsflyerHelp {

    //insert var

    private static String AF_DEV_KEY = "";
    Context mAppContent;
    private static AppsflyerHelp mInstace = null;
    public static AppsflyerHelp getInstance() {
        if (null == mInstace){
            mInstace = new AppsflyerHelp();
        }
        return mInstace;
    }

    public void init(Context AppContent, String key){
        //insert code

        mAppContent = AppContent;
        AF_DEV_KEY = key;

        Log.d(AppsFlyerLibCore.LOG_TAG, "init,AF_DEV_KEY = " + AF_DEV_KEY);

        /**  Set Up Conversion Listener to get attribution data **/

        AppsFlyerConversionListener conversionListener = new AppsFlyerConversionListener() {

            /* Returns the attribution data. Note - the same conversion data is returned every time per install */
            @Override
            public void onConversionDataSuccess(Map<String, Object> conversionData) {
                //insert code

                Log.d(AppsFlyerLibCore.LOG_TAG, "onConversionDataSuccess");
                for (String attrName : conversionData.keySet()) {
                    Log.d(AppsFlyerLibCore.LOG_TAG, "attribute: " + attrName + " = " + conversionData.get(attrName));
                }
                setInstallData(conversionData);
            }

            @Override
            public void onConversionDataFail(String errorMessage) {
                //insert code

                Log.e(AppsFlyerLibCore.LOG_TAG, "error getting conversion data: " + errorMessage);
            }

            /* Called only when a Deep Link is opened */
            @Override
            public void onAppOpenAttribution(Map<String, String> conversionData) {
                //insert code

                Log.d(AppsFlyerLibCore.LOG_TAG, "onAppOpenAttribution");
                for (String attrName : conversionData.keySet()) {
                    Log.d(AppsFlyerLibCore.LOG_TAG, "attribute: " + attrName + " = " + conversionData.get(attrName));
                }
            }

            @Override
            public void onAttributionFailure(String errorMessage) {
                //insert code

                Log.e(AppsFlyerLibCore.LOG_TAG, "error onAttributionFailure : " + errorMessage);
            }
        };


        /* This API enables AppsFlyer to detect installations, sessions, and updates. */

//        AppsFlyerLib.getInstance().init(AF_DEV_KEY , conversionListener , mAppContent.getApplicationContext());
        AppsFlyerLib.getInstance().startTracking((App)mAppContent);


        /* Set to true to see the debug logs. Comment out or set to false to stop the function */

        AppsFlyerLib.getInstance().setDebugLog(true);
    }

    /* IGNORE - USED TO DISPLAY INSTALL DATA */
    public static String InstallConversionData = "";
    public static int sessionCount = 0;
    public static String MediaSource = "";
    public void setInstallData(Map<String, Object> conversionData){
        //insert code

        Log.d(AppsFlyerLibCore.LOG_TAG, "sessionCount:" + sessionCount);
        if(sessionCount == 0){
            final String install_type = "Install Type: " + conversionData.get("af_status") + "\n";
            final String media_source = "Media Source: " + conversionData.get("media_source") + "\n";
            final String install_time = "Install Time(GMT): " + conversionData.get("install_time") + "\n";
            final String click_time = "Click Time(GMT): " + conversionData.get("click_time") + "\n";
            final String is_first_launch = "Is First Launch: " + conversionData.get("is_first_launch") + "\n";
            InstallConversionData += install_type + media_source + install_time + click_time + is_first_launch;
            sessionCount++;
            MediaSource = "" + conversionData.get("media_source");
            if(conversionData.get("af_bindsuperior") != null){
                MediaSource = "" + conversionData.get("af_bindsuperior");
            }
        }
    }

    public void trackEvent(String eventType, String jsonData){
        //insert code

        Log.d(AppsFlyerLibCore.LOG_TAG, "trackEvent");

//        String res = "{\"result\": \"success\",\"msg\": \"登陆成功\"}";

        try {
            JSONObject jsonInfo = new JSONObject(jsonData);
            Iterator<String> it = jsonInfo.keys();
            Map<String,Object> eventData = new HashMap<>();

            while(it.hasNext()){
                String key = it.next();
                String value = jsonInfo.getString(key);
                eventData.put(key,value);
                Log.d(AppsFlyerLibCore.LOG_TAG, "key: "+key+",value:"+value);
            }
//            eventData.put(AFInAppEventParameterName.CURRENCY,"rupee");
//            eventData.put(AFInAppEventParameterName.REVENUE,1);

            AppsFlyerLib.getInstance().trackEvent(mAppContent.getApplicationContext(), eventType,eventData);

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public String getMediaSource() {
        //insert code

        return MediaSource;
    }
}
