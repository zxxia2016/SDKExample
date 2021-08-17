package org.cocos2dx.javascript.sdk;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.Task;

import org.cocos2dx.javascript.ConfigManager;
import org.cocos2dx.javascript.SDKManager;
import org.json.JSONObject;

public class GoogleSDK {
    private static final String TAG = "GoogleSDK";
    private static final boolean IS_DEBUG = true;
    public  static int RC_SIGN_IN = 9001;
    private GoogleSignInClient mGoogleSignInClient;

    private static String NotifyEvent = "googleLoginResult";


    private static final GoogleSDK mGoogleSDK = new GoogleSDK();

    private Activity mContext = null;

    private GoogleSDK() {
    }

    public static GoogleSDK getInstance() {
        return mGoogleSDK;
    }

    public boolean init(Activity context) {
        mContext = context;
        String id = context.getString(ConfigManager.getStringResourseIdByName("server_client_id"));
        String log = String.format("server_client_id: %s", id);
        this.log(log);
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestIdToken(id).requestEmail().build();
        mGoogleSignInClient = GoogleSignIn.getClient(mContext, gso);
        return true;
    }
    public void signIn() {
        Intent signInIntent = mGoogleSignInClient.getSignInIntent();
        mContext.startActivityForResult(signInIntent, RC_SIGN_IN);
    }
    public void signOut() {
        GoogleSignInAccount lastSignedInAccount = GoogleSignIn.getLastSignedInAccount(mContext);
        if (lastSignedInAccount != null) {
            mGoogleSignInClient.signOut();
        }
    }
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        if (requestCode == RC_SIGN_IN) {
            // The Task returned from this call is always completed, no need to attach
            // a listener.
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            handleSignInResult(task);
        }
    }
    private void handleSignInResult(Task<GoogleSignInAccount> completedTask) {
        try {
            GoogleSignInAccount account = completedTask.getResult(ApiException.class);
            String personName = account.getDisplayName();
            String personEmail = account.getEmail();
            String uid = account.getId();
            String token = account.getIdToken();
            Uri uri = account.getPhotoUrl();
            String url = uri.toString();
            String string = String.format("id: %s,token: %s, name: %s, email: %s, url: %s", uid, token, personName, personEmail, url);
            this.log(string);
            try {
                JSONObject mJsonobjData = new JSONObject();
                mJsonobjData.put("uid", uid);
                mJsonobjData.put("name", personName);
                mJsonobjData.put("url", url);
                mJsonobjData.put("email", personEmail);
                mJsonobjData.put("token", token);
                mJsonobjData.put("code", 0);
                String dataStr = mJsonobjData.toString();
                SDKManager.NotifyToJS(NotifyEvent, dataStr);
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
            }
        } catch (ApiException e) {
            int code = e.getStatusCode();
            String log = String.format("signInResult:failed, code: %d", code);
            Log.e(TAG, log);
            this.loginResult(code, log);
        }
    }
    public void loginResult(int code, String msg) {
        try {
            JSONObject mJsonobjData = new JSONObject();
            mJsonobjData.put("code", code);
            mJsonobjData.put("msg", msg);
            String dataStr = mJsonobjData.toString();
            SDKManager.NotifyToJS(NotifyEvent, dataStr);

        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
        }
    }

    private static void log(String msg) {
        if (IS_DEBUG) {
            Log.e(TAG, msg);
        } else {
            Log.i(TAG, msg);
        }
    }
}
