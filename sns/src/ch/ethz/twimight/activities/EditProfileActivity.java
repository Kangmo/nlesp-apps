package ch.ethz.twimight.activities;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Toast;
import ch.ethz.twimight.R;
import ch.ethz.twimight.net.twitter.TwitterService;
import ch.ethz.twimight.net.twitter.TwitterUsers;
import ch.ethz.twimight.util.InternalStorageHelper;

public class EditProfileActivity extends Activity implements OnClickListener {

	private static final String TAG = "EditProfileActivity";
	private static final int RESULT_LOAD_IMAGE = 1;

	// views
	private Button buttonUpdate;
	private ImageButton buttonProfileImage;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.edit_profile);

		buttonUpdate = (Button) findViewById(R.id.buttonUpdateProfile);
		buttonUpdate.setOnClickListener(this);

		buttonProfileImage = (ImageButton) findViewById(R.id.buttonProfileImage);
		buttonProfileImage.setOnClickListener(this);

		EditText name = (EditText) findViewById(R.id.signUpName);
		EditText statusMessage = (EditText) findViewById(R.id.signUpStatus);

		Uri uri;
		Cursor c;
		long rowId;

		if (getIntent().hasExtra("rowId")) {
			rowId = (long) getIntent().getIntExtra("rowId", 0);

			// get data from local DB
			uri = Uri.parse("content://" + TwitterUsers.TWITTERUSERS_AUTHORITY
					+ "/" + TwitterUsers.TWITTERUSERS + "/" + rowId);
			c = getContentResolver().query(uri, null, null, null, null);
			startManagingCursor(c);

			if (c.getCount() == 0)
				finish();

			c.moveToFirst();
		} else {
			Log.w(TAG, "VKIT: WHICH USER??");
			finish();
			return;
		}

		// do we have a profile image?
		if (!c.isNull(c.getColumnIndex(TwitterUsers.COL_SCREENNAME))) {
			InternalStorageHelper helper = new InternalStorageHelper(this);
			String screenName = c.getString(c
					.getColumnIndex(TwitterUsers.COL_SCREENNAME));
			byte[] imageByteArray = helper.readImage(screenName);
			if (imageByteArray != null) {
				// is = context.getContentResolver().openInputStream(uri);
				SignUpActivity.picturePath = this.getFilesDir() + "/" + screenName;
				Bitmap bm = BitmapFactory.decodeByteArray(imageByteArray, 0,
						imageByteArray.length);
				buttonProfileImage.setImageBitmap(bm);
			} else
				buttonProfileImage.setImageResource(R.drawable.default_profile);
		}
		name.setText(c.getString(c.getColumnIndex(TwitterUsers.COL_NAME)));

		if (c.getColumnIndex(TwitterUsers.COL_DESCRIPTION) >= 0) {
			String tmp = c.getString(c
					.getColumnIndex(TwitterUsers.COL_DESCRIPTION));
			statusMessage.setText(tmp);
		}
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
		Intent i = null;
		switch (view.getId()) {
		case R.id.buttonUpdateProfile:
			SignUpActivity.name = trimText((EditText) findViewById(R.id.signUpName));
			SignUpActivity.status = trimText((EditText) findViewById(R.id.signUpStatus));

			if (SignUpActivity.name == null || SignUpActivity.name.isEmpty()) {
				Toast.makeText(getBaseContext(), R.string.info_fill_all,
						Toast.LENGTH_SHORT).show();
				return;
			}

			// cacheSignUpInfo(id, pwd, name, status, getBaseContext());
			// SignInActivity.cacheLoginInfo(id, pwd, getBaseContext());
			// startActivity(new Intent(this, LoginActivity.class));

			i = new Intent(TwitterService.SYNCH_ACTION);
			i.putExtra("synch_request", TwitterService.SYNCH_UPDATE_PROFILE);
			startService(i);

			finish();
			break;
		case R.id.buttonProfileImage:
			i = new Intent(
					Intent.ACTION_PICK,
					android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);

			startActivityForResult(i, RESULT_LOAD_IMAGE);
			break;
		}
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
			SignUpActivity.picturePath = cursor.getString(columnIndex);
			cursor.close();

			buttonProfileImage.setImageBitmap(BitmapFactory
					.decodeFile(SignUpActivity.picturePath));

			// String urlString = "/account/update_profile.json";
			//
			// //절대경로를 획득한다!!! 중요~
			// Cursor c =
			// getContentResolver().query(Uri.parse(selectedImage.toString()),
			// null,null,null,null);
			// c.moveToNext();
			// String absolutePath =
			// c.getString(c.getColumnIndex(MediaStore.MediaColumns.DATA));
			//
			// // start uploading.
			// VKitUtil.httpFileUpload(urlString, absolutePath);
		}

	}

	@Override
	public void onDestroy() {

		super.onDestroy();

		if (buttonUpdate != null) {
			buttonUpdate.setOnClickListener(null);
		}
	}
	//
	// public static void executeMultipartPost(String path, String restaurantId,
	// String itemId) throws Exception {
	// try {
	//
	// Bitmap bm = BitmapFactory.decodeFile(path);
	// String URL = "", imageId = "";
	//
	// URL = "your server's URL to handle multipart data ";
	// ByteArrayOutputStream bos = new ByteArrayOutputStream();
	// bm.compress(CompressFormat.JPEG, 75, bos);
	// byte[] data = bos.toByteArray();
	// HttpClient httpClient = new DefaultHttpClient();
	// HttpPost postRequest = new HttpPost(URL);
	// ByteArrayBody bab = new ByteArrayBody(data, imageId + ".jpg");
	// MultipartEntity reqEntity = new MultipartEntity(
	// HttpMultipartMode.BROWSER_COMPATIBLE);
	// reqEntity.addPart("uploaded", bab);
	// reqEntity.addPart("photoCaption", new StringBody("sfsdfsdf"));
	// postRequest.setEntity(reqEntity);
	// HttpResponse response = httpClient.execute(postRequest);
	// BufferedReader reader = new BufferedReader(new InputStreamReader(
	// response.getEntity().getContent(), "UTF-8"));
	// String sResponse;
	// StringBuilder s = new StringBuilder();
	//
	// while ((sResponse = reader.readLine()) != null) {
	// s = s.append(sResponse);
	// }
	// System.out.println("Response: " + s);
	// } catch (Exception e) {
	// // handle exception here
	// Log.e(e.getClass().getName(), e.getMessage());
	// }
	// }
}
