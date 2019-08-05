package nl.imvertor.common.file;

import java.io.File;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;

import org.apache.commons.text.StringEscapeUtils;
import org.apache.http.HttpHeaders;
import org.json.JSONObject;

/**
 * This class implements the full commit and push of a file to the specified Github location.
 * 
 * 
 * @author arjan
 *
 */
public class GithubFile extends HttpFile {
	
   	private static final long serialVersionUID = 1671504389004682658L;
	
	private String error = "";
	private String stage = "init";
	private URI url;
	
	public static void main(String[] args) throws Exception {
		
		/*
		PropertiesFile props = new PropertiesFile(args[0]);
		
		String USER = props.getProperty("user");
		String REPO = props.getProperty("repo");
		String OAUTH = props.getProperty("token");
		
		String BRANCH = props.getProperty("branch");
		String INFILE = props.getProperty("infile");
		String OUTFILE = props.getProperty("outfile");
		String MESSAGE = props.getProperty("message");
		String HTMLFILE = props.getProperty("htmlfile");

		GithubFile file = new GithubFile(HTMLFILE);
		file.publish(USER, REPO, OAUTH, BRANCH, INFILE, OUTFILE, MESSAGE);
		*/
	}

	public GithubFile(File file) {
		super(file);
	}

	public GithubFile(String file) {
		super(file);
	}

	public String getEncoding() {
		return (encoding == null) ? StandardCharsets.UTF_8.name() : encoding; 
	}
	
    public void publish(
			String USER,
			String REPO,
			String OAUTH,
			String BRANCH,
			String INFILE,
			String OUTFILE,
			String MESSAGE) throws Exception {
	
 		String SHA_LATEST_COMMIT = null;
		String SHA_TREE = null;
		String SHA_NEW_TREE = null;
		String SHA_NEW_COMMIT = null;
		//String SHA_FINALIZE = null;
		//String CONTENT = null;
		
		String payload = null;
		
		JSONObject object;
		while (true) {
			
			stage = "GET Request: save sha-latest-commit";
			object = getFromRemote(USER, REPO, OAUTH,"git/refs/heads/" + BRANCH);
			if (getStatus() < 400) 
				SHA_LATEST_COMMIT = object.getJSONObject("object").getString("sha");
			else 
				break;
			
			stage = "GET Request: save sha-base-tree";
			object = getFromRemote(USER, REPO, OAUTH,"git/commits/" + SHA_LATEST_COMMIT);
			if (getStatus() < 400) 
				SHA_TREE = object.getJSONObject("tree").getString("sha");
			else 
				break;
			
			stage = "POST Request: save sha-new-tree";
			String escaped = StringEscapeUtils.escapeJson(getContent());
			payload = "{\"base_tree\": \""+SHA_TREE+"\",\"tree\": [{\"path\": \""+OUTFILE+"\",\"mode\": \"100644\",\"type\": \"blob\",\"content\": \""+escaped+"\"}]}"; //  
			object = postToRemote(USER, REPO, OAUTH,"git/trees", payload);
			
			if (getStatus() < 400) 
				SHA_NEW_TREE = object.getString("sha");
			else 
				break;
				
			stage = "POST Request: save sha-newest-commit";
			payload = "{\"parents\": [\""+SHA_LATEST_COMMIT+"\"],\"tree\": \""+SHA_NEW_TREE+"\",\"message\": \""+MESSAGE+"\"}";
			object = postToRemote(USER, REPO, OAUTH,"git/commits", payload);
			if (getStatus() < 400) 
				SHA_NEW_COMMIT = object.getString("sha");
			else 
				break;
				
			stage = "POST Request: finalize";
			payload = "{\"sha\": \""+SHA_NEW_COMMIT+"\"}";
			object = postToRemote(USER, REPO, OAUTH,"git/refs/heads/" + BRANCH, payload);
			if (getStatus() < 400) 
				object.getJSONObject("object").getString("sha"); // could assign to SHA_FINALIZE but is not used.
			
			break;
				
		}
		
		// TODO wat te doen met de tussenresultaten (sha's), relevant?
		
		if (getStatus() >= 400) 
			error = object.getString("message");
		
	}
	
	public JSONObject getFromRemote(String USER, String REPO, String OAUTH, String suburl) throws Exception {
		url = URI.create("https://api.github.com/repos/" + USER + "/" + REPO + "/" + suburl);
	    
		HashMap<String,String> headerMap = new HashMap<String,String>();
		headerMap.put(HttpHeaders.AUTHORIZATION,"token " + OAUTH);
		String result = get(url, headerMap, null);
		
		return new JSONObject(result);
	}
	
	public JSONObject postToRemote(String USER, String REPO, String OAUTH, String suburl, String payload) throws Exception {
	
		url = URI.create("https://api.github.com/repos/" + USER + "/" + REPO + "/" + suburl);
	     
		HashMap<String,String> headerMap = new HashMap<String,String>();
		headerMap.put(HttpHeaders.AUTHORIZATION,"token " + OAUTH);
		headerMap.put(HttpHeaders.ACCEPT, "application/json");
		headerMap.put(HttpHeaders.CONTENT_TYPE, "application/json");
		headerMap.put(HttpHeaders.CONTENT_ENCODING, getEncoding());
		
		String result = post(HttpFile.METHOD_POST_CONTENT, url, headerMap, null, new String[] {payload});
		
		return new JSONObject(result);
	}

	/**
	 * get the last error reported, or "" when no errors.
	 * 
	 * @return
	 */
	public String getError() {
		return error;
	}
	/**
	 * Get the most recent stage.
	 * 
	 * @return
	 */
	public String getStage() {
		return stage;
	}
	/**
	 * Return the latest URI call
	 * 
	 * @return
	 */
	public URI getURI() {
		return url;
	}

}
