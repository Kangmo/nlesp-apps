package com.thksoft.vicdata;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import winterwell.json.JSONObject;
import android.content.Context;
import android.util.Log;
import ch.ethz.twimight.R;

public class VdError {

	private int code;
	private String message;
	private int detailedCode;
	private String detailedMessageFormat;
	private List<String> detailedMessageArgs = new ArrayList<String>();

	static Map<Integer, Integer> codeToResIdMap = new HashMap<Integer, Integer>();

	static {
		Log.e("VKitError", "" + R.string.VKErrorDetailEmailNotFound);
		codeToResIdMap.put(1001, R.string.VKErrorDetailUserNotFound);
		codeToResIdMap.put(1002,
				R.string.VKErrorDetailInvalidUserIdentifierFormat);
		codeToResIdMap.put(1003, R.string.VKErrorDetailFriendIsRequester);
		codeToResIdMap.put(1004, R.string.VKErrorDetailEmailNotFound);
		codeToResIdMap.put(1005, R.string.VKErrorDetailInvalidPassword);
		codeToResIdMap.put(1006, R.string.VKErrorDetailEmptyEmailOnUserProfile);
		codeToResIdMap.put(1007,
				R.string.VKErrorDetailEmptyPasswordOnUserProfile);
		codeToResIdMap.put(1008,
				R.string.VKErrorDetailEmptyUserIdentifierOnUserProfile);
		codeToResIdMap.put(1009, R.string.VKErrorDetailEmailAlreadyExists);
		codeToResIdMap.put(1010,
				R.string.VKErrorDetailUnableToUpdateOtherUserProfile);
		codeToResIdMap.put(1011, R.string.VKErrorDetailUnableToChangeEmail);
		codeToResIdMap
				.put(1012, R.string.VKErrorDetailInvalidContextIdentifier);
		codeToResIdMap.put(1013, R.string.VKErrorDetailContextNotFound);
		codeToResIdMap.put(1014, R.string.VKErrorDetailExceedMaxUsers);
		codeToResIdMap.put(1015, R.string.VKErrorDetailTooLowClientVersion);
	}

	public VdError(JSONObject obj) {
		code = obj.getInt("code");
		message = obj.getString("message");
		detailedCode = obj.optInt("detailed_code", -1);
		detailedMessageFormat = obj.optString("detailed_message_format");
		String args = obj.optString("detailed_message_args");

		Log.d("VKitError", "code = " + code + ", message = " + message
				+ ", d_code = " + detailedCode + ", d_msg_format = "
				+ detailedMessageFormat + ", args = " + args);
		if (args != null) {
			StringTokenizer tokens = new StringTokenizer(args, ",");
			while (tokens.hasMoreTokens()) {
				detailedMessageArgs.add(tokens.nextToken());
			}
		}
	}

	public String getLocalizedMessage(Context context) {
		Log.d("VKitError", "code = " + code + ", message = " + message
				+ ", d_code = " + detailedCode + ", d_msg_format = "
				+ detailedMessageFormat);
		String message = this.message;
		if (detailedCode != -1) {
			message = context.getString(codeToResIdMap.get(detailedCode));

			Log.d("VKitError", "r_id = " + codeToResIdMap.get(detailedCode)
					+ ", message = " + message + ", args_size = "
					+ detailedMessageArgs.size());

			switch (detailedMessageArgs.size()) {
			case 1:
				message = String.format(message, detailedMessageArgs.get(0));
				break;
			case 2:
				message = String.format(message, detailedMessageArgs.get(0));
				break;
			case 3:
				message = String.format(message, detailedMessageArgs.get(0));
				break;
			case 4:
				message = String.format(message, detailedMessageArgs.get(0));
				break;
			case 5:
				message = String.format(message, detailedMessageArgs.get(0));
				break;
			case 6:
				message = String.format(message, detailedMessageArgs.get(0));
				break;
			case 0: // fall through
			default:
				break;
			}
		}
		return message;
	}
}
