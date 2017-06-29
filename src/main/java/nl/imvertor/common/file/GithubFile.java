package nl.imvertor.common.file;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Authenticator;
import java.net.PasswordAuthentication;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;

public class GithubFile {
	
	private URL url;
	private String user = null;
	private String pass = null;
	
	private int status = -1; // latest response
	private String message = null; // latest response
	
	public static void main(String[] args) throws Exception {
		String sha = args[3];
		
		String jsonstring = "{"
				+ "\"message\": \"Test JAVA 2\","
				+ "\"committer\": {\"name\": \"Arjan Loeffen\",\"email\": \"arjan.loeffen@armatiek.nl\"},"
				+ "\"content\": \"bXkgbmV3IGZpbGUgY29udGVudHM=\""
				+ "}";
		
		GithubFile f = new GithubFile(new URL(args[0]), args[1], args[2]);
		System.out.println(f.put(jsonstring));
		//System.out.println(f.get());
	}
	
	public GithubFile(URL url) {
		this.url = url;
	}
	
	public GithubFile(URL url, String user, String pass) {
		this.url = url;
		this.user = user;
		this.pass = pass;
		
		Authenticator.setDefault (new Authenticator() {
		    protected PasswordAuthentication getPasswordAuthentication() {
		        return new PasswordAuthentication (user, pass.toCharArray());
		    }
		});
	}
	
	public String put(String contents) throws IOException  {
		
		String responseString = null;
		
		HttpsURLConnection httpsURLConnection = null;
		DataOutputStream dataOutputStream = null;
		try {
		    httpsURLConnection = (HttpsURLConnection) url.openConnection();
		    httpsURLConnection.setRequestMethod("PUT");
		    httpsURLConnection.setDoInput(true);
		    httpsURLConnection.setDoOutput(true);
		    dataOutputStream = new DataOutputStream(httpsURLConnection.getOutputStream());
		    dataOutputStream.write(contents.getBytes());
		    
		    this.status = httpsURLConnection.getResponseCode();
		    this.message = httpsURLConnection.getResponseMessage();
		    
		    if (this.status == 200 || this.status == 204) {
			    BufferedReader in = new BufferedReader(new InputStreamReader(httpsURLConnection.getInputStream()));
				String inputLine;
				StringBuffer response = new StringBuffer();
				while ((inputLine = in.readLine()) != null) {
					response.append(inputLine);
				}
				in.close();
				responseString = response.toString();
		    }
		} 
		finally {
		    if (dataOutputStream != null) {
		        try {
		            dataOutputStream.flush();
		            dataOutputStream.close();
		        } catch (IOException exception) {
		           this.status = 0;
		        }
		    }
		    if (httpsURLConnection != null) {
		        httpsURLConnection.disconnect();
		    }
		}
		return responseString;
	}
	
	public String get() throws IOException {
		   HttpsURLConnection httpsURLConnection = null;
		   try {
			   httpsURLConnection = (HttpsURLConnection) url.openConnection();
			   httpsURLConnection.setRequestMethod("GET");
		
			   this.status = httpsURLConnection.getResponseCode();
			   this.message = httpsURLConnection.getResponseMessage();
			    
			   BufferedReader in = new BufferedReader(new InputStreamReader(httpsURLConnection.getInputStream()));
			   String inputLine;
			   StringBuffer response = new StringBuffer();
			   while ((inputLine = in.readLine()) != null) {
				   response.append(inputLine);
			   }
			   in.close();
			   return response.toString();
		   } finally {
			   if (httpsURLConnection != null) {
				   httpsURLConnection.disconnect();
			   }
		   }
	}
}
