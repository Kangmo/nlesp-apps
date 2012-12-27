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
	private static long sessionTime = 0; // 세션을 얻은 시간

	private static String request;

	// 주소, 메소드타입("GET" or "POST"), map(변수명, 값) 을 넣어주면 됨
	public static String request(URL url, String method,
			Map<String, Object> params) throws IOException {
		// 세션 시간이 넘어가지는 않았는지 확인한다.
		checkSession();

		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		// 메소드 타입을 지정 "GET"나 "POST"를 넣어야 하겠지~_~?
		connection.setRequestMethod(method);

		// 인코딩 정의 HTTP방식으로 전송할때는 urlencoded방식으로 인코딩해서 전송해야한다.
		connection.setRequestProperty("Content-Type",
				"application/x-www-form-urlencoded");
		// 인풋스트림 쓸거라고 지정
		connection.setDoInput(true);

		connection.setInstanceFollowRedirects(false); // 세션을 사용하려면 false로 설정해둬야함

		// 세션 생성해둔게 있으면 헤더에 셋팅해서 내가 전에 접속했던 녀석이라고 알려준다.
		if (session) {
			connection.setRequestProperty("cookie", cookies);
		}
		// 포스트방식일 경우
//		if (method.equals("POST")) {
//			// 데이터를 주소와 별개로 전송한다.
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

	// 변수 조립할때 쓸 문자열들
	private static final String LINE_END = "\r\n";
	private static final String TWO_HYPHENS = "--";
	private static final String BOUNDARY = "*****";
	private static final String TAG = "VKitHttpConnect";

	// / 파일을 업로드하면서 변수 전달하고 리퀘스트 받는 함수입습죠
	public static String uploadAndRequest(String urlString,
			Map<String, String> params, Map<String, String> files)
			throws IOException {
		// 세션 시간이 넘어가지는 않았는지 체크
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

		// 세션 생성해둔게 있으면 헤더에 셋팅해서 내가 전에 접속했던 녀석이라고 알려준다.
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
		// 키와 값을 차례차례 빼낸다
		for (Iterator<String> i = params.keySet().iterator(); i.hasNext();) {
			String key = (String) i.next();
			// 대충 생각해보면 감이 올지 않는가?
			// --*****\r\n
			// Content-Disposition: form-data; name=\"변수명1\"\r\n변수값1\r\n
			// --*****\r\n
			// Content-Disposition: form-data; name=\"변수명2\"\r\n변수값2\r\n

			dos.writeBytes(TWO_HYPHENS + BOUNDARY + LINE_END); // 필드 구분자 시작
			dos.writeBytes("content-disposition: form-data; name=\"" + key
					+ "\"" + LINE_END);
			dos.writeBytes(LINE_END);

			dos.writeUTF(String.valueOf(params.get(key)));

			dos.writeBytes(LINE_END);
		}

		Log.d(TAG, "VICDATA (params): + " + new String(byteOut.toByteArray()));
		// /////////////////////////////////////////////////////////////////////
		// 파일 전달
		// /////////////////////////////////////////////////////////////////////

		// 키와 값을 차례차례 빼낸다
		for (Iterator<String> i = files.keySet().iterator(); i.hasNext();) {
			String key = (String) i.next();
			String fileName = String.valueOf(files.get(key));
			Log.d(TAG, "VICDATA: writing file: " + TWO_HYPHENS + BOUNDARY
					+ LINE_END + "content-disposition: form-data; name=\""
					+ key + "\"; filename=\"" + fileName + "\"" + LINE_END
					+ "Content-Type: image/png" + LINE_END
					+ "Content-Transfer-Encoding: binary" + LINE_END);

			// 위에서 설명한 내용에서 변수값 대신 파일을 쓰는 것만 다르니까 더이상의 설명은 생략한다.
			dos.writeBytes(TWO_HYPHENS + BOUNDARY + LINE_END);
			dos.writeBytes("content-disposition: form-data; name=\"" + key
					+ "\"; filename=\"" + fileName + "\"" + LINE_END);
			dos.writeBytes("Content-Type: image/png" + LINE_END);
			dos.writeBytes("Content-Transfer-Encoding: binary" + LINE_END);
			dos.writeBytes(LINE_END);

			writeFile(dos, fileName);

			dos.writeBytes(LINE_END);
			// 변수 하나(파일하나) 전달 끗
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
		// 그림파일 읽어서 내용을 쏴준다.
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

		// 받아온 데이터를 쓰기위한 스트림
		ByteArrayOutputStream bos = new ByteArrayOutputStream();

		// 리퀘스트 데이터를 저장할 버퍼
		byte[] buf = new byte[2048];
		try {
			// int k = 0; // / 읽은 라인수

			long ti = System.currentTimeMillis(); // / == 시간 체크용 == 서버에 따라 리퀘스트
													// 오는 시간이 매우 오래걸림

			in = connection.getInputStream(); // / 인풋스트림 생성

			// == 시간 체크용 == inputstream얻는 요기서 시간 10초이상 넘어가면 큰일남
			// 갤럭시 S에서 어떤앱은 WebView라던가 Http통신에서 15초인가 넘어가면 세션 끊기는
			// 원인을 알 수 없는 경우도 있었음 다른기기 다 잘되는데 오로지 갤럭시 S만!!! 그랬음 참고 바람요
			Log.d("---recTime---", "" + (System.currentTimeMillis() - ti));
			// 루프를 돌면서 리퀘스트로 받은내용을 저장한다.
			while (true) {
				int readlen = in.read(buf);
				if (readlen < 1)
					break;
				// k += readlen;
				bos.write(buf, 0, readlen);
			}
			// 리퀘스트 받은 내용을 UTF-8로 변경해서 문자열로 저장
			request = new String(bos.toByteArray(), "UTF-8");
			/*
			 * File fl = new File( "/sdcard/rec.txt" ) ; FileOutputStream fos =
			 * new FileOutputStream( fl ) ; fos.write( bos.toByteArray( ) ) ; /*
			 */

			session = requestAndSetSession(connection);

			return request;
		} catch (IOException e) {
			// 리퀘스트 받다가 에러가 나면 에러나면서 받은 메세지를 읽는다.
			if (connection.getResponseCode() == 500) {
				// 버퍼 리셋하고 에러값 받을 인풋스트림 생성해서 레어메세지 얻기
				bos.reset();
				InputStream err = connection.getErrorStream();
				while (true) {
					int readlen = err.read(buf);

					if (readlen < 1)
						break;
					bos.write(buf, 0, readlen);
				}

				// 에러메세지를 문자열로 저장
				String output = new String(bos.toByteArray(), "UTF-8");

				// 읽은 에러메세지를 출력한다.
				System.err.println(output);
			}

			throw e;

		} finally {
			// 500에러도 아니면 그냥 접속 끊어버림.... -_- 안되는데 답있나?
			if (in != null)
				in.close();

			if (connection != null)
				connection.disconnect();

			session = false;
			cookies = "";
		}
	}

	// Request를 받되 세션 유지를 위해 쿠키를 저장한다.
	private static boolean requestAndSetSession(HttpURLConnection connection) {

		// 맵에다 Http헤더를 받아냄
		Map<String, List<String>> imap = connection.getHeaderFields();

		// 그리고 거길 뒤져서 쿠키를 찾아냄
		if (imap.containsKey("Set-Cookie")) {
			// 쿠키를 스트링으로 쫙 저장함
			List<String> lString = imap.get("Set-Cookie");
			for (int i = 0; i < lString.size(); i++) {
				cookies += lString.get(i);
			}
			// 2.3에서 정상작동하지 않습니다 .위의 코드로 대처합니다.
			// Collections c = (Collections)imap.get( "Set-Cookie" ) ;
			// m_cookies = c.toString( ) ;

			// 세션을 저장했으니
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
			// 제한시간 아직 안넘었음 세션 유지 연장시킴
			sessionTime = System.currentTimeMillis();
		} else {
			// 제한시간을 넘겼음 세션을 제거함
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
