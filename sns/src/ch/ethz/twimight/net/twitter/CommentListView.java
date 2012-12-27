package ch.ethz.twimight.net.twitter;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ListView;

public class CommentListView extends ListView {
	private final String TAG = "CommentListView";
	private Context context;

	public CommentListView(Context context) {
		super(context);
		this.context = context;
	}

	public CommentListView(Context context, AttributeSet attrs) {
		super(context, attrs);
		setOverScrollMode(OVER_SCROLL_ALWAYS);
		this.context = context;
	}
}