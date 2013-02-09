package ch.ethz.twimight.net.twitter;

import java.util.List;

import winterwell.jtwitter.Comment;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import ch.ethz.twimight.R;
import ch.ethz.twimight.util.InternalStorageHelper;

/**
 * Cursor adapter for a cursor containing comments.
 */
public class CommentAdapter extends ArrayAdapter<Comment> {
	private static final String TAG = "CommentAdapter";

	static class ViewHolder {
		private ImageView userProfileImage;
		private TextView name;
		private TextView createdAt;
		private TextView status;
	}

	private int layout = R.layout.row;
	Context context;

	private List<Comment> arrayListHappy;

	@Override
	public int getCount() {
		return arrayListHappy.size();
	}

	/** Constructor */
	public CommentAdapter(Context context, List<Comment> commentList) {
		super(context, R.layout.row, commentList);

		this.context = context;
		arrayListHappy = commentList;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View view = null;
		ViewHolder viewHolder = null;

		if (convertView == null) {
			LayoutInflater layoutInflater = (LayoutInflater) getContext()
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			view = layoutInflater.inflate(layout, null);

			if (view != null) {
				viewHolder = new ViewHolder();
				viewHolder.userProfileImage = (ImageView) view
						.findViewById(R.id.imageView1);
				viewHolder.name = (TextView) view.findViewById(R.id.textUser);
				viewHolder.createdAt = (TextView) view
						.findViewById(R.id.tweetCreatedAt);
				viewHolder.status = (TextView) view.findViewById(R.id.textText);
				view.setTag(viewHolder);
			}
		} else {
			view = convertView;
			viewHolder = (ViewHolder) convertView.getTag();
		}

		if (viewHolder != null) {
			Comment comment = arrayListHappy.get(position);

			if (comment != null) {
				InternalStorageHelper helper = new InternalStorageHelper(
						this.context);
				byte[] imageByteArray = helper.readImage(comment.getUser()
						.getScreenName());
				if (imageByteArray != null) {
					Bitmap bm = BitmapFactory.decodeByteArray(imageByteArray,
							0, imageByteArray.length);
					viewHolder.userProfileImage.setImageBitmap(bm);
				} else {
					viewHolder.userProfileImage
							.setImageResource(R.drawable.default_profile);
				}
				viewHolder.name.setText(comment.getUser().getName());
				viewHolder.createdAt.setText(DateUtils
						.getRelativeTimeSpanString(comment.getCreatedAt()
								.getTime()));
				viewHolder.status.setText(comment.getComment());
			}
		}

		return view;
	}
}
