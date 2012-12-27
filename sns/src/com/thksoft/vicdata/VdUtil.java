package com.thksoft.vicdata;

import java.security.MessageDigest;
import java.util.Map;

import winterwell.json.JSONException;
import winterwell.json.JSONObject;
import android.content.Context;
import android.util.Log;
import android.widget.Toast;
import ch.ethz.twimight.R;
import ch.ethz.twimight.activities.SignInActivity;

public class VdUtil {
	private static final String TAG = "VKitUtil";

	public static String VD_ROOT_URL_LOCAL = "http://192.168.0.106:8080/rest/1";
//	public static String VD_ROOT_URL_LOCAL = "http://10.0.1.4:8080/rest/1";
	
	public static final String VD_ROOT_URL_PRODUCTION = "http://nhnsoft.com:8080/rest/1";
	public static final String VD_ROOT_URL = VD_ROOT_URL_PRODUCTION;
	private static String lastError;

	public static boolean isValidEmail(CharSequence target) {
		if (target == null) {
			return false;
		} else {
			return android.util.Patterns.EMAIL_ADDRESS.matcher(target)
					.matches();
		}
	}

	public static void putAccessToken(Map<String, String> vars) {
		Log.d(TAG, "putAccessToken: vars = " + (vars != null));
		if (vars != null) {
			String accessToken = SignInActivity.memCachedUserId + ":"
					+ SignInActivity.memCachedSignature;
			vars.put("access_token", accessToken);
		}
	}

	public static String getAccessToken() {
		Log.d(TAG, "appendAccessToken");
		String accessToken = SignInActivity.memCachedUserId + ":"
				+ SignInActivity.memCachedSignature;
		return "?access_token=" + accessToken;
	}

	public static void setLastError(String json) {
		lastError = json;
	}

	public static void showLastError(Context context) {
		Log.e(TAG, "Last error: " + lastError);
		if (lastError != null) {
			try {
				JSONObject obj = new JSONObject(lastError);
				VdError error = new VdError(obj);
				Toast.makeText(context, error.getLocalizedMessage(context),
						Toast.LENGTH_LONG).show();
				Log.e(TAG,
						"Localized error: "
								+ error.getLocalizedMessage(context));
			} catch (JSONException e) {
				Toast.makeText(context, R.string.error_unknown,
						Toast.LENGTH_LONG).show();
				Log.e(TAG,
						"Localized error: "
								+ context.getString(R.string.error_unknown));
			}
			lastError = null;
		}
	}

	public static String encryptByUsingSha1(String passwd) {
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-1");
			String clearPassword = passwd;
			md.update(clearPassword.getBytes());
			byte[] digestedPassword = md.digest();
			return new String(digestedPassword);
		} catch (java.security.NoSuchAlgorithmException e) {
			System.out.println("Rats, SHA-1 doesn't exist");
			System.out.println(e.toString());
			return null;
		}

	}

	public static String encryptByUsingMd5(String passwd) {
		try {
			MessageDigest sha = MessageDigest.getInstance("MD5");
			byte[] tmp = passwd.getBytes();
			sha.update(tmp);
			return new String(sha.digest());

		} catch (java.security.NoSuchAlgorithmException e) {
			System.out.println("Rats, MD5 doesn't exist");
			System.out.println(e.toString());
		}
		return null;
	}
}
