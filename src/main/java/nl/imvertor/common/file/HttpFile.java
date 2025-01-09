package nl.imvertor.common.file;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.methods.RequestBuilder;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;

public class HttpFile extends AnyFile {

	private static final long serialVersionUID = 3111631389431655771L;
	
	public final static int METHOD_POST_FILE = 0;
	public final static int METHOD_POST_CONTENT = 1;
	
	private CredentialsProvider provider;
	private UsernamePasswordCredentials credentials;
	private CloseableHttpClient client;
		
	private int status = -1;
	
	public HttpFile(File file) {
		super(file);
		init();
	}
	public HttpFile(String file) {
		super(file);
		init();
	}
	
	public void setUserPass(String user, String pass) {
		init(user,pass);
	}

	private void init() {
		provider = new BasicCredentialsProvider();
		client = HttpClients.createDefault();
	}
	
	private void init(String user, String pass) {
		provider = new BasicCredentialsProvider();
 		credentials = new UsernamePasswordCredentials(user, pass);
 		provider.setCredentials(AuthScope.ANY, credentials);
 		client = HttpClientBuilder.create().setDefaultCredentialsProvider(provider).build();
	}
	
	/**
     * Get info from URL.
     *      
     * @return Body of the request
     * @throws Exception 
     */
	public String get(URI url, Map<String, String> headerMap, HashMap<String, String> parms) throws Exception {

		// create a request builder
		RequestBuilder builder = RequestBuilder.get();
		builder.setUri(url);

		// add headers
		if (headerMap != null) {
			Iterator<Entry<String,String>> it = headerMap.entrySet().iterator();
			while (it.hasNext()) {
				Entry<String,String> e = it.next();
				builder.addHeader(e.getKey().toString(), e.getValue().toString());
			}
		}

		// add parms
		if (parms != null) {
			Iterator<Entry<String,String>> paramIterator = parms.entrySet().iterator();
			while (paramIterator.hasNext()) {
				Entry<String,String> e = paramIterator.next();
				builder.addParameter(new BasicNameValuePair(e.getKey().toString(), e.getValue().toString()));
			}
		}

		// build and execute the request
		HttpUriRequest request = builder.build();
		HttpResponse response = client.execute(request);

		// get the status of the response
		this.status = response.getStatusLine().getStatusCode();

		// get the contents of the response
		return getResponseBody(response);

	}
	
	public void put(URI url, Map<String, String> headerMap, HashMap<String, String> parms) throws Exception {
		
		String body = getContent(); 
		
		// create a request builder
		RequestBuilder builder = RequestBuilder.put();
	
		builder.setUri(url);
		builder.setEntity(new StringEntity(body));

		// add headers
		if (headerMap != null) {
			Iterator<Entry<String,String>> it = headerMap.entrySet().iterator();
			while (it.hasNext()) {
				Entry<String,String> e = it.next();
				builder.addHeader(e.getKey().toString(), e.getValue().toString());
			}
		}
		
	    // add parms
 		if (parms != null) {
 			Iterator<Entry<String,String>> paramIterator = parms.entrySet().iterator();
 			while (paramIterator.hasNext()) {
 		 		Entry<String,String> e = paramIterator.next();
 		 		builder.addParameter(new BasicNameValuePair(e.getKey().toString(), e.getValue().toString()));
 	 		}
 	    }
		
		// build and execute the request
		HttpUriRequest request = builder.build();
		HttpResponse response = client.execute(request);

		// get the status of the response
		this.status = response.getStatusLine().getStatusCode();

		// no other response
	
	}
	
	// http://www.baeldung.com/httpclient-post-http-request
	
	/**
	 * 
	 * 
	 * @param url
	 * @param parms
	 * @param payload
	 * @return
	 * @throws Exception
	 */
	public String post(int method, URI url, Map<String, String> headerMap, HashMap<String, String> parms, String[] payload) throws Exception {
		
		HttpPost httpPost = new HttpPost(url);
	 
	 	// add headers
	    if (headerMap != null) {
	    	Iterator<Entry<String,String>> headerIterator = headerMap.entrySet().iterator();
	 		while (headerIterator.hasNext()) {
	 			Entry<String,String> e = headerIterator.next();
	 			httpPost.addHeader(e.getKey().toString(), e.getValue().toString());
	 		}
	    }
	    
	    // add parms
 		if (parms != null) {
 			Iterator<Entry<String,String>> paramIterator = parms.entrySet().iterator();
 			List<NameValuePair> params = new ArrayList<NameValuePair>();
 		 	while (paramIterator.hasNext()) {
 		 		Entry<String,String> e = paramIterator.next();
 	 			params.add(new BasicNameValuePair(e.getKey().toString(), e.getValue().toString()));
 	 		}
 		    httpPost.setEntity(new UrlEncodedFormEntity(params));
	    }
 		
 		// check which type of post is intended
 		if (method == METHOD_POST_CONTENT && payload != null) {
	 		StringEntity entity = new StringEntity(payload[0]); // only the first content string is used
		    httpPost.setEntity(entity);
 		} else if (method == METHOD_POST_FILE && payload != null) {
			MultipartEntityBuilder builder = MultipartEntityBuilder.create();
 			for (int i = 0; i < payload.length; i++) {
 				File file = new File(payload[i]);
 	 		    builder.addBinaryBody("file",file,
 	 		      ContentType.APPLICATION_OCTET_STREAM, file.getName());
 			}
 		    HttpEntity multipart = builder.build();
 		    httpPost.setEntity(multipart);
 		} 
 	    
	    // execute the post request
	    CloseableHttpResponse response = client.execute(httpPost);
	    
	    // get the status of the response
	 	this.status = response.getStatusLine().getStatusCode();
	 	
	 	// and get the contents of the response
	 	String body = getResponseBody(response);
	
	 	// close the client
	    client.close();

	    return body;
	}
	
	public int getStatus() {
		return status;
	}
	public String getResponseBody(HttpResponse response) throws Exception, IOException {
		return IOUtils.toString(response.getEntity().getContent(), StandardCharsets.UTF_8);
	}

}
