package com.thksoft.vicdata;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import android.util.Log;

public class VdHttpConnect {
	private static String cookies = "";
	private static boolean session = false;
	private static long sessionLimitTime = 360000;
	private static long sessionTime = 0; // ������ ���� �ð�

	private static String request;

	// �ּ�, �޼ҵ�Ÿ��("GET" or "POST"), map(������, ��) �� �־��ָ� ��
	public static String request(URL url, String method,
			Map<String, Object> params) throws IOException {
		// ���� �ð��� �Ѿ���� �ʾҴ��� Ȯ���Ѵ�.
		checkSession();

		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		// �޼ҵ� Ÿ���� ���� "GET"�� "POST"�� �־�� �ϰ���~_~?
		connection.setRequestMethod(method);

		// ���ڵ� ���� HTTP������� �����Ҷ��� urlencoded������� ���ڵ��ؼ� �����ؾ��Ѵ�.
		connection.setRequestProperty("Content-Type",
				"application/x-www-form-urlencoded");
		// ��ǲ��Ʈ�� ���Ŷ�� ����
		connection.setDoInput(true);

		connection.setInstanceFollowRedirects(false); // ������ ����Ϸ��� false�� �����ص־���

		// ���� �����صа� ������ ����� �����ؼ� ���� ���� �����ߴ� �༮�̶�� �˷��ش�.
		if (session) {
			connection.setRequestProperty("cookie", cookies);
		}
		// ����Ʈ����� ���
//		if (method.equals("POST")) {
//			// �����͸� �ּҿ� ������ �����Ѵ�.
//			connection.setDoOutput(true);
//
//			String paramstr = buildParams(params);
//			OutputStream out = connection.getOutputStream();
//			out.write(paramstr.getBytes("UTF-8"));
//			out.flush();
//			out.close();
//			Log.d("-- gsLog ---", "post succes");
//		}

		return getRequest(connection);
	}

	// ���� �����Ҷ� �� ���ڿ���
	private static final String LINE_END = "\r\n";
	private static final String TWO_HYPHENS = "--";
	private static final String BOUNDARY = "*****";
	private static final String TAG = "VKitHttpConnect";

	// / ������ ���ε��ϸ鼭 ���� �����ϰ� ������Ʈ �޴� �Լ��Խ���
	public static String uploadAndRequest(String urlString,
			Map<String, String> params, Map<String, String> files)
			throws IOException {
		// ���� �ð��� �Ѿ���� �ʾҴ��� üũ
		checkSession();

		// generate body.
		byte[] body = buildBody(params, files);

		// create connection and config.
		HttpURLConnection connection = (HttpURLConnection) new URL(urlString)
				.openConnection();
		connection.setDoInput(true);
		connection.setDoOutput(true);
		connection.setUseCaches(false);
		connection.setRequestMethod("POST");
		connection.setInstanceFollowRedirects(false);

		// ���� �����صа� ������ ����� �����ؼ� ���� ���� �����ߴ� �༮�̶�� �˷��ش�.
		if (session) {
			connection.setRequestProperty("cookie", cookies);
		}

		// write body info.
		connection.setRequestProperty("Connection", "Keep-Alive");
		connection.setRequestProperty("Content-Type",
				"multipart/form-data; charset=UTF-8; boundary=" + BOUNDARY);
		connection.setRequestProperty("Content-Length",
				Integer.toString(body.length));

		Log.d(TAG, "VICDATA: content-length = " + body.length);

		OutputStream dos = connection.getOutputStream();
		dos.write(body);
		dos.flush();

		String response = getRequest(connection);
		System.out.println("Response: " + response);
		return response;
	}

	private static byte[] buildBody(Map<String, String> params,
			Map<String, String> files) throws IOException {
		ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(byteOut);
		// Ű�� ���� �������� ������
		for (Iterator<String> i = params.keySet().iterator(); i.hasNext();) {
			String key = (String) i.next();
			// ���� �����غ��� ���� ���� �ʴ°�?
			// --*****\r\n
			// Content-Disposition: form-data; name=\"������1\"\r\n������1\r\n
			// --*****\r\n
			// Content-Disposition: form-data; name=\"������2\"\r\n������2\r\n

			dos.writeBytes(TWO_HYPHENS + BOUNDARY + LINE_END); // �ʵ� ������ ����
			dos.writeBytes("content-disposition: form-data; name=\"" + key
					+ "\"" + LINE_END);
			dos.writeBytes(LINE_END);

			dos.writeUTF(String.valueOf(params.get(key)));

			dos.writeBytes(LINE_END);
		}

		Log.d(TAG, "VICDATA (params): + " + new String(byteOut.toByteArray()));
		// /////////////////////////////////////////////////////////////////////
		// ���� ����
		// /////////////////////////////////////////////////////////////////////

		// Ű�� ���� �������� ������
		for (Iterator<String> i = files.keySet().iterator(); i.hasNext();) {
			String key = (String) i.next();
			String fileName = String.valueOf(files.get(key));
			Log.d(TAG, "VICDATA: writing file: " + TWO_HYPHENS + BOUNDARY
					+ LINE_END + "content-disposition: form-data; name=\""
					+ key + "\"; filename=\"" + fileName + "\"" + LINE_END
					+ "Content-Type: image/png" + LINE_END
					+ "Content-Transfer-Encoding: binary" + LINE_END);

			// ������ ������ ���뿡�� ������ ��� ������ ���� �͸� �ٸ��ϱ� ���̻��� ������ �����Ѵ�.
			dos.writeBytes(TWO_HYPHENS + BOUNDARY + LINE_END);
			dos.writeBytes("content-disposition: form-data; name=\"" + key
					+ "\"; filename=\"" + fileName + "\"" + LINE_END);
			dos.writeBytes("Content-Type: image/png" + LINE_END);
			dos.writeBytes("Content-Transfer-Encoding: binary" + LINE_END);
			dos.writeBytes(LINE_END);

			writeFile(dos, fileName);

			dos.writeBytes(LINE_END);
			// ���� �ϳ�(�����ϳ�) ���� ��
		}

		dos.writeBytes(TWO_HYPHENS + BOUNDARY + TWO_HYPHENS + LINE_END);

		return byteOut.toByteArray();
	}

	public static void writeFile(DataOutputStream dos, String fileName)
			throws FileNotFoundException, IOException {
		FileInputStream fileIn = new FileInputStream(fileName);
		int bytesAvailable = fileIn.available();
		Log.d(TAG, "VICDATA: file size: " + bytesAvailable);
		int maxBufferSize = 1024 * 256;
		int bufferSize = Math.min(bytesAvailable, maxBufferSize);

		int totalBytes = 0;
		byte[] buffer = new byte[bufferSize];
		int bytesRead = fileIn.read(buffer, 0, bufferSize);
		totalBytes += bytesRead;
		// �׸����� �о ������ ���ش�.
		while (bytesRead > 0) {
			dos.write(buffer, 0, bufferSize);
			bytesAvailable = fileIn.available();
			bufferSize = Math.min(bytesAvailable, maxBufferSize);
			bytesRead = fileIn.read(buffer, 0, bufferSize);
			totalBytes += bytesRead;
		}
		fileIn.close();
		Log.d(TAG, "VICDATA: wrote in total " + totalBytes + " bytes.");
	}

	private static String getRequest(HttpURLConnection connection)
			throws UnsupportedEncodingException, IOException {
		InputStream in = null;

		// �޾ƿ� �����͸� �������� ��Ʈ��
		ByteArrayOutputStream bos = new ByteArrayOutputStream();

		// ������Ʈ �����͸� ������ ����
		byte[] buf = new byte[2048];
		try {
			// int k = 0; // / ���� ���μ�

			long ti = System.currentTimeMillis(); // / == �ð� üũ�� == ������ ���� ������Ʈ
													// ���� �ð��� �ſ� �����ɸ�

			in = connection.getInputStream(); // / ��ǲ��Ʈ�� ����

			// == �ð� üũ�� == inputstream��� ��⼭ �ð� 10���̻� �Ѿ�� ū�ϳ�
			// ������ S���� ����� WebView����� Http��ſ��� 15���ΰ� �Ѿ�� ���� �����
			// ������ �� �� ���� ��쵵 �־��� �ٸ���� �� �ߵǴµ� ������ ������ S��!!! �׷��� ���� �ٶ���
			Log.d("---recTime---", "" + (System.currentTimeMillis() - ti));
			// ������ ���鼭 ������Ʈ�� ���������� �����Ѵ�.
			while (true) {
				int readlen = in.read(buf);
				if (readlen < 1)
					break;
				// k += readlen;
				bos.write(buf, 0, readlen);
			}
			// ������Ʈ ���� ������ UTF-8�� �����ؼ� ���ڿ��� ����
			request = new String(bos.toByteArray(), "UTF-8");
			/*
			 * File fl = new File( "/sdcard/rec.txt" ) ; FileOutputStream fos =
			 * new FileOutputStream( fl ) ; fos.write( bos.toByteArray( ) ) ; /*
			 */

			session = requestAndSetSession(connection);

			return request;
		} catch (IOException e) {
			// ������Ʈ �޴ٰ� ������ ���� �������鼭 ���� �޼����� �д´�.
			if (connection.getResponseCode() == 500) {
				// ���� �����ϰ� ������ ���� ��ǲ��Ʈ�� �����ؼ� ����޼��� ���
				bos.reset();
				InputStream err = connection.getErrorStream();
				while (true) {
					int readlen = err.read(buf);

					if (readlen < 1)
						break;
					bos.write(buf, 0, readlen);
				}

				// �����޼����� ���ڿ��� ����
				String output = new String(bos.toByteArray(), "UTF-8");

				// ���� �����޼����� ����Ѵ�.
				System.err.println(output);
			}

			throw e;

		} finally {
			// 500������ �ƴϸ� �׳� ���� �������.... -_- �ȵǴµ� ���ֳ�?
			if (in != null)
				in.close();

			if (connection != null)
				connection.disconnect();

			session = false;
			cookies = "";
		}
	}

	// Request�� �޵� ���� ������ ���� ��Ű�� �����Ѵ�.
	private static boolean requestAndSetSession(HttpURLConnection connection) {

		// �ʿ��� Http����� �޾Ƴ�
		Map<String, List<String>> imap = connection.getHeaderFields();

		// �׸��� �ű� ������ ��Ű�� ã�Ƴ�
		if (imap.containsKey("Set-Cookie")) {
			// ��Ű�� ��Ʈ������ �� ������
			List<String> lString = imap.get("Set-Cookie");
			for (int i = 0; i < lString.size(); i++) {
				cookies += lString.get(i);
			}
			// 2.3���� �����۵����� �ʽ��ϴ� .���� �ڵ�� ��ó�մϴ�.
			// Collections c = (Collections)imap.get( "Set-Cookie" ) ;
			// m_cookies = c.toString( ) ;

			// ������ ����������
			return true;
		} else {
			return false;
		}

	}

	private static void checkSession() {
		if (!session) {
			return;
		}

		if (System.currentTimeMillis() < sessionTime + sessionLimitTime) {
			// ���ѽð� ���� �ȳѾ��� ���� ���� �����Ŵ
			sessionTime = System.currentTimeMillis();
		} else {
			// ���ѽð��� �Ѱ��� ������ ������
			cookies = "";
			session = false;
		}
	}

	// // key=value&key=value
	// private static String buildParams(Map<String, Object> params)
	// throws IOException {
	// if (params == null) {
	// return "";
	// }
	//
	// StringBuilder result = new StringBuilder();
	// for (Iterator<String> i = params.keySet().iterator(); i.hasNext();) {
	// String key = (String) i.next();
	// result.append(key);
	// result.append('=');
	// result.append(URLEncoder.encode(String.valueOf(params.get(key)),
	// "UTF-8"));
	//
	// if (i.hasNext()) {
	// result.append("&");
	// }
	// }
	//
	// return result.toString();
	// }

}
