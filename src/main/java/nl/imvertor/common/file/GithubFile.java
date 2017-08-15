package nl.imvertor.common.file;

import java.io.File;
import java.net.URI;
import java.util.HashMap;

import org.apache.commons.lang3.StringEscapeUtils;
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
	
	public String error = "";
	public String stage = "init";
		
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
		String SHA_FINALIZE = null;
		String CONTENT = null;
		
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
			payload = "{\"base_tree\": \""+SHA_TREE+"\",\"tree\": [{\"path\": \""+OUTFILE+"\",\"mode\": \"100644\",\"type\": \"blob\",\"content\": \""+escaped+"\"}]}"; //  \"encoding\": \"utf-8\", 
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
				SHA_FINALIZE = object.getJSONObject("object").getString("sha");
			
			break;
				
		}
		
		// TODO wat te doen met de tussenresultaten (sha's), relevant?
		
		if (getStatus() >= 400) 
			error = object.getString("message");
		
	}
	
	public JSONObject getFromRemote(String USER, String REPO, String OAUTH, String suburl) throws Exception {
		URI url = URI.create("https://api.github.com/repos/" + USER + "/" + REPO + "/" + suburl);
	    
		HashMap<String,String> headerMap = new HashMap<String,String>();
		headerMap.put(HttpHeaders.AUTHORIZATION,"token " + OAUTH);
		
		String result = get(url, headerMap);
		
		return new JSONObject(result);
	}
	
	public JSONObject postToRemote(String USER, String REPO, String OAUTH, String suburl, String payload) throws Exception {
	
		URI url = URI.create("https://api.github.com/repos/" + USER + "/" + REPO + "/" + suburl);
	     
		HashMap<String,String> headerMap = new HashMap<String,String>();
		headerMap.put(HttpHeaders.AUTHORIZATION,"token " + OAUTH);
		headerMap.put(HttpHeaders.ACCEPT, "application/json");
		headerMap.put(HttpHeaders.CONTENT_TYPE, "application/json");
		
		String result = post(HttpFile.METHOD_POST_CONTENT, url, headerMap, null, payload);
		
		return new JSONObject(result);
	}

	public String getError() {
		return error;
	}
	public String getStage() {
		return stage;
	}
}
