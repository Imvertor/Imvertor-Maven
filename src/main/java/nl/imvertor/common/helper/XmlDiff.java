package nl.imvertor.common.helper;

import java.io.File;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import nl.imvertor.common.file.XmlFile;

public class XmlDiff {

	private String xmlDiffServiceUrl;

	/**
	 * Pass URL with full parameter set.
	 * 
	 * @param xmlDiffServiceUrl
	 */
	public XmlDiff(String xmlDiffServiceUrl) {
		this.xmlDiffServiceUrl = xmlDiffServiceUrl;
	}

	public void compare(File docA, File docB, File docResult) throws Exception {
		CloseableHttpClient client = HttpClients.createDefault();
		try {
			HttpPost post = new HttpPost(xmlDiffServiceUrl);
			FileBody fileBodyA = new FileBody(docA, ContentType.APPLICATION_OCTET_STREAM);
			FileBody fileBodyB = new FileBody(docB, ContentType.APPLICATION_OCTET_STREAM); 
			MultipartEntityBuilder builder = MultipartEntityBuilder.create();
			builder.setMode(HttpMultipartMode.BROWSER_COMPATIBLE);
			builder.addPart("fileA", fileBodyA);
			builder.addPart("fileB", fileBodyB);
			HttpEntity entity = builder.build();
			post.setEntity(entity);
			HttpResponse response = client.execute(post);
			XmlFile.setFileContent(docResult.getCanonicalPath(), EntityUtils.toString(response.getEntity(), "UTF-8"));
		} finally {
			client.close();
		}
	}
	  
}