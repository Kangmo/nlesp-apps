package ch.ethz.twimight.activities;

import com.thksoft.vicdata.VdUtil;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Toast;
import ch.ethz.twimight.R;

public class SignUpActivity extends Activity implements OnClickListener {

	private static final String TAG = "SignUpActivity";

	private static final int RESULT_LOAD_IMAGE = 1;

	public static boolean signiningUp;
	public static String login_id;
	public static String password;
	public static String name;
	public static String status;
	public static String picturePath;

	// views
	private Button buttonCreateAccount;
	private ImageButton buttonProfileImage;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.signup);

		buttonCreateAccount = (Button) findViewById(R.id.buttonCreateAccount);
		buttonCreateAccount.setOnClickListener(this);

		buttonProfileImage = (ImageButton) findViewById(R.id.buttonProfileImage);
		buttonProfileImage.setOnClickListener(this);
	}

	private String trimText(EditText view) {
		String text = view.getText().toString();
		if (text != null) {
			text = text.trim();
		}

		return text;
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.buttonCreateAccount:
			String id = trimText((EditText) findViewById(R.id.signUpId));
			String pwd = trimText((EditText) findViewById(R.id.signUpPwd));
			String pwdRe = trimText((EditText) findViewById(R.id.signUpPwdRe));
			String name = trimText((EditText) findViewById(R.id.signUpName));
			String status = trimText((EditText) findViewById(R.id.signUpStatus));

			if (id == null || pwd == null || pwdRe == null || name == null
					|| id.isEmpty() || pwd.isEmpty() || pwdRe.isEmpty()
					|| name.isEmpty()) {

				Toast.makeText(getBaseContext(), R.string.info_fill_all,
						Toast.LENGTH_SHORT).show();
				return;
			}

			if (!VdUtil.isValidEmail(id)) {
				Toast.makeText(getBaseContext(), R.string.info_invalid_email,
						Toast.LENGTH_SHORT).show();
				return;
			}

			if (!pwd.equals(pwdRe)) {
				Toast.makeText(getBaseContext(),
						R.string.info_password_not_matched, Toast.LENGTH_SHORT)
						.show();
				return;
			}

			cacheSignUpInfo(id, pwd, name, status, picturePath,
					getBaseContext());
			SignInActivity.cacheLoginInfo(id, pwd, getBaseContext());
			startActivity(new Intent(this, LoginActivity.class));

			finish();
			break;
		case R.id.buttonProfileImage:
			Intent i = new Intent(
					Intent.ACTION_PICK,
					android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);

			startActivityForResult(i, RESULT_LOAD_IMAGE);
			break;
		}
	}

	private static void cacheSignUpInfo(String id, String pwd, String name,
			String status, String picturePath, Context context) {
		signiningUp = true;

		SignUpActivity.login_id = id;
		SignUpActivity.password = VdUtil.encryptByUsingSha1(pwd);
		SignUpActivity.name = name;
		SignUpActivity.status = status;
		SignUpActivity.picturePath = picturePath;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if (requestCode == RESULT_LOAD_IMAGE && resultCode == RESULT_OK
				&& null != data) {
			Uri selectedImage = data.getData();
			String[] filePathColumn = { MediaStore.Images.Media.DATA };

			Cursor cursor = getContentResolver().query(selectedImage,
					filePathColumn, null, null, null);
			cursor.moveToFirst();

			int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
			picturePath = cursor.getString(columnIndex);
			cursor.close();

			buttonProfileImage.setImageBitmap(BitmapFactory
					.decodeFile(picturePath));
		}
	}

	@Override
	public void onDestroy() {
		super.onDestroy();

		if (buttonCreateAccount != null) {
			buttonCreateAccount.setOnClickListener(null);
		}
	}
}
