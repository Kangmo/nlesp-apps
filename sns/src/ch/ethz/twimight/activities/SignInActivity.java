package ch.ethz.twimight.activities;

import winterwell.jtwitter.User;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import ch.ethz.twimight.R;

import com.thksoft.vicdata.VdUtil;

public class SignInActivity extends Activity implements OnClickListener {

	private static final String TAG = "SignInActivity";
	private static final String VICDATA_KEY_LOGIN_ID = "vicdata_login_id";
	private static final String VICDATA_KEY_LOGIN_PASSWORD = "vicdata_login_password";
	private static final String VICDATA_KEY_USER_ID = "vicdata_user_id";
	private static final String VICDATA_KEY_SIGNATURE = "vicdata_signature";

	public static enum Mode {
		NORMAL, SIGNIN_FAILED, SIGNUP_FAILED,
	};

	public static String memCachedUserId;
	public static String memCachedLoginId;
	public static String memCachedLoginPassword;
	public static String memCachedSignature;
	public static String memCachedClientVersion;

	// views
	private Button buttonSignIn;
	private Button buttonSignUp;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.signin);

		buttonSignIn = (Button) findViewById(R.id.buttonSignIn);
		buttonSignIn.setOnClickListener(this);
		buttonSignUp = (Button) findViewById(R.id.buttonSignUp);
		buttonSignUp.setOnClickListener(this);
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.buttonSignIn:
			String id = ((EditText) findViewById(R.id.signInId)).getText()
					.toString();
			String pwd = ((EditText) findViewById(R.id.signInPwd)).getText()
					.toString();

			if (id == null || id.isEmpty() || pwd == null || pwd.isEmpty()) {
				Toast.makeText(getBaseContext(), R.string.info_fill_all,
						Toast.LENGTH_SHORT).show();
				return;
			}

			if (!VdUtil.isValidEmail(id)) {
				Toast.makeText(getBaseContext(), R.string.info_invalid_email,
						Toast.LENGTH_SHORT).show();
				return;
			}

			cacheLoginInfo(id, pwd, getBaseContext());
			startActivity(new Intent(this, LoginActivity.class));
			finish();

			break;
		case R.id.buttonSignUp:
			startActivity(new Intent(this, SignUpActivity.class));

			break;
		}
	}

	public static String getCachedUserId(Context context) {
		return PreferenceManager.getDefaultSharedPreferences(context)
				.getString(VICDATA_KEY_USER_ID, null);
	}

	public static String getCachedLoginId(Context context) {
		return PreferenceManager.getDefaultSharedPreferences(context)
				.getString(VICDATA_KEY_LOGIN_ID, null);
	}

	public static String getCachedLoginPassword(Context context) {
		return PreferenceManager.getDefaultSharedPreferences(context)
				.getString(VICDATA_KEY_LOGIN_PASSWORD, null);
	}

	private static String getCachedSignature(Context context) {
		return PreferenceManager.getDefaultSharedPreferences(context)
				.getString(VICDATA_KEY_SIGNATURE, null);
	}

	public static void cacheLoginInfo(String id, String password,
			Context context) {
		Editor prefEdit = PreferenceManager
				.getDefaultSharedPreferences(context).edit();
		prefEdit.putString(VICDATA_KEY_LOGIN_ID, id);
		prefEdit.putString(VICDATA_KEY_LOGIN_PASSWORD, VdUtil.encryptByUsingSha1(password));
		prefEdit.commit();

		loadLoginInfoToMem(context);
	}

	public static void setAccessToken(String token, Context context) {
		SharedPreferences prefs = PreferenceManager
				.getDefaultSharedPreferences(context);
		SharedPreferences.Editor prefEditor = prefs.edit();
		prefEditor.putString(LoginActivity.TWITTER_ACCESS_TOKEN, token);
		prefEditor.commit();
	}

	public static void setAccessTokenSecret(String secret, Context context) {
		SharedPreferences prefs = PreferenceManager
				.getDefaultSharedPreferences(context);
		SharedPreferences.Editor prefEditor = prefs.edit();
		prefEditor.putString(LoginActivity.TWITTER_ACCESS_TOKEN_SECRET, secret);
		prefEditor.commit();
	}

	@Override
	public void onDestroy() {
		super.onDestroy();

		if (buttonSignIn != null) {
			buttonSignIn.setOnClickListener(null);
		}
		if (buttonSignUp != null) {
			buttonSignUp.setOnClickListener(null);
		}
	}

	public static void clearCachedLoginInfo(Context context) {
		SharedPreferences prefs = PreferenceManager
				.getDefaultSharedPreferences(context);
		SharedPreferences.Editor prefEditor = prefs.edit();
		prefEditor.remove(VICDATA_KEY_LOGIN_ID);
		prefEditor.remove(VICDATA_KEY_LOGIN_PASSWORD);
		prefEditor.remove(VICDATA_KEY_USER_ID);
		prefEditor.remove(VICDATA_KEY_SIGNATURE);

		prefEditor.commit();

		memCachedLoginId = null;
		memCachedLoginPassword = null;
	}

	@Override
	public void onBackPressed() {
		Toast.makeText(getBaseContext(),
				R.string.info_login_or_signup, Toast.LENGTH_SHORT)
				.show();
	}

	public static void loadLoginInfoToMem(Context context) {
		memCachedUserId = getCachedUserId(context);
		memCachedLoginId = getCachedLoginId(context);
		memCachedLoginPassword = getCachedLoginPassword(context);
		memCachedSignature = getCachedSignature(context);
		memCachedClientVersion = context.getString(R.string.client_version);
	}

	public static void cacheLoginUserInfo(User user, Context context) {
		Editor prefEdit = PreferenceManager
				.getDefaultSharedPreferences(context).edit();
		prefEdit.putString(VICDATA_KEY_USER_ID, Long.toString(user.getId()));
		prefEdit.putString(VICDATA_KEY_SIGNATURE, user.getSignature());
		prefEdit.commit();

		loadLoginInfoToMem(context);
	}

}
