package winterwell.jtwitter;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import winterwell.json.JSONArray;
import winterwell.json.JSONException;
import winterwell.json.JSONObject;

public final class Comment {
	static List<Comment> getComments(String json) throws TwitterException {
		if (json.trim().equals(""))
			return Collections.emptyList();
		try {
			List<Comment> tweets = new ArrayList<Comment>();
			JSONArray arr = new JSONArray(json);
			for (int i = 0; i < arr.length(); i++) {
				Object ai = arr.get(i);
				if (JSONObject.NULL.equals(ai)) {
					continue;
				}
				JSONObject obj = (JSONObject) ai;
				Comment tweet = new Comment(obj, null);
				tweets.add(tweet);
			}
			return tweets;
		} catch (JSONException e) {
			throw new TwitterException.Parsing(json, e);
		}
	}

	public final Date createdAt;

	public final String comment;

	public final User user;

	Comment(JSONObject object, User user) throws TwitterException {
		try {
			// text!
			comment = InternalUtils.jsonGet("comment", object);

			// date
			String c = InternalUtils.jsonGet("created_at", object);
			createdAt = InternalUtils.parseDate(c);

			// set user
			if (user != null) {
				this.user = user;
			} else {
				JSONObject jsonUser = object.optJSONObject("user");
				if (jsonUser == null) {
					this.user = null;
				} else if (jsonUser.length() < 3) {
					BigInteger userId = new BigInteger(object.get("id")
							.toString());
					try {
						user = new Twitter().show(userId);
					} catch (Exception e) {
						// ignore
					}
					this.user = user;
				} else {
					// normal JSON case
					this.user = new User(jsonUser, null);
				}

			}
		} catch (JSONException e) {
			throw new TwitterException.Parsing(null, e);
		}
	}

	@Deprecated
	public Comment(User user, String comment, Number id, Date createdAt) {
		this.comment = comment;
		this.user = user;
		this.createdAt = createdAt;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Comment other = (Comment) obj;
		return comment.equals(other.comment) && user.equals(other.user);
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public String getComment() {
		return comment;
	}

	public User getUser() {
		return user;
	}

	@Override
	public int hashCode() {
		return user.hashCode() + comment.hashCode();
	}

	@Override
	public String toString() {
		return comment;
	}
}