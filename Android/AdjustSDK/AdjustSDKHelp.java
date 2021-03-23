package org.games.sdk;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adjust.sdk.Adjust;
import com.adjust.sdk.AdjustAttribution;
import com.adjust.sdk.AdjustConfig;
import com.adjust.sdk.AdjustEvent;
import com.adjust.sdk.OnAttributionChangedListener;

//insert class

public class AdjustSDKHelp {

    //insert var

    private static Application mAppContent;
    private static AdjustSDKHelp mInstace = null;

    public static int AdJustCount = 0;
    public static String AdjustKey = "";

    public static AdjustSDKHelp getInstance() {
        if (null == mInstace) {
            mInstace = new AdjustSDKHelp();
        }
        return mInstace;
    }

    public void init(Application application, String apptoken, String preinstallKey) {
        //insert code

        mAppContent = application;
        String environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
        AdjustConfig config = new AdjustConfig(mAppContent, apptoken, environment);
        config.setUrlStrategy(AdjustConfig.URL_STRATEGY_CHINA);
        mAppContent.registerActivityLifecycleCallbacks(new AdjustSDKHelp.AdjustLifecycleCallbacks());
        config.setOnAttributionChangedListener(new OnAttributionChangedListener() {
            @Override
            public void onAttributionChanged(AdjustAttribution attribution) {
                setAdjustData(attribution);
            }
        });
        if (preinstallKey != "") {
            config.setDefaultTracker(preinstallKey);
        }
        Adjust.onCreate(config);
    }

    public void setAdjustData(AdjustAttribution attribution) {
        //insert code

        if (AdJustCount == 0) {
            AdJustCount++;
            AdjustKey = "" + attribution.trackerToken;

            if (attribution.clickLabel != null) {
                AdjustKey = "" + attribution.clickLabel;
            }
        }
    }

    public void logEvent(String eventType, String jsonData, String CurrencyType) {
        //insert code

        //String ajtoken = App.getAdJustKey();

        if (!eventType.equals("")) {
            AdjustEvent adjustEvent = new AdjustEvent(eventType);
            if (!CurrencyType.equals("")) {
                adjustEvent.setRevenue(Double.valueOf(jsonData), CurrencyType);
            }
            // adjustEvent.setOrderId("{OrderId}");
            Adjust.trackEvent(adjustEvent);
        }
    }

    public String getAdJustKey() {
        //insert code

        return AdjustKey;
    }

    private static final class AdjustLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
        @Override
        public void onActivityResumed(Activity activity) {
            //insert code

            Adjust.onResume();
        }

        @Override
        public void onActivityPaused(Activity activity) {
            //insert code

            Adjust.onPause();
        }

        @Override
        public void onActivityStopped(@NonNull Activity activity) {
            //insert code

        }

        @Override
        public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {
            //insert code

        }

        @Override
        public void onActivityDestroyed(@NonNull Activity activity) {
            //insert code

        }

        @Override
        public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
            //insert code

        }

        @Override
        public void onActivityStarted(@NonNull Activity activity) {
            //insert code

        }
        //...
    }
}
