package ch.ethz.twimight.activities;

import java.util.List;

import winterwell.jtwitter.Comment;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import ch.ethz.twimight.R;
import ch.ethz.twimight.net.twitter.CommentAdapter;
import ch.ethz.twimight.net.twitter.CommentListView;
import ch.ethz.twimight.net.twitter.TwitterService;

public class ShowCommentListActivity extends TwimightBaseActivity {
	private static final String TAG = "ShowCommentListActivity";

	// Views
	private static CommentListView commentListView;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.comment_list);

		commentListView = (CommentListView) findViewById(R.id.commentList);
		commentListView.setEmptyView(findViewById(R.id.commentListEmpty));
		
		Intent intent = getIntent();
		Long tweetId = intent.getLongExtra("tweet_id", -1L);
		Long tweetOwnerId = intent.getLongExtra("tweet_owner_id", -1L);
		if (tweetId != -1L && tweetOwnerId != -1L) {
			Intent i = new Intent(TwitterService.SYNCH_ACTION);
			i.putExtra("synch_request", TwitterService.SYNCH_COMMENT);
			i.putExtra("tweet_owner_id", tweetOwnerId);
			i.putExtra("tweet_id", tweetId);
			startService(i);
		}
	}

	@Override
	protected void onNewIntent(Intent intent) {
		setIntent(intent);
		
		Long tweetId = intent.getLongExtra("tweet_id", -1L);
		Long tweetOwnerId = intent.getLongExtra("tweet_owner_id", -1L);
		if (tweetId != -1L && tweetOwnerId != -1L) {
			Intent i = new Intent(TwitterService.SYNCH_ACTION);
			i.putExtra("synch_request", TwitterService.SYNCH_COMMENT);
			i.putExtra("tweet_owner_id", tweetOwnerId);
			i.putExtra("tweet_id", tweetId);
			startService(i);
		}
	}

	@Override
	public void onResume() {
		super.onResume();
	}

	@Override
	public void onDestroy() {
		super.onDestroy();

		commentListView.setAdapter(null);
		commentListView = null;
	}
	
	public static void setComments(Context context, List<Comment> commentList) {
		if (commentListView != null) {
			commentListView.setAdapter(new CommentAdapter(context, commentList));
		}
	}
}
