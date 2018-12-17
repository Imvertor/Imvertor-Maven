package nl.imvertor.Tester;

import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import nl.imvertor.common.file.HttpFile;

public class HttpTester {
	
	public static void main(String[] args) throws URISyntaxException, Exception {
		
		HttpTester tester = new HttpTester();
		tester.test1();
		
	}

	public void test1() throws URISyntaxException, Exception {
		String body = "<?xml version=\"1.0\"?><wiki_page><text>h1. TestSub generated at " + getCurrentTimeStamp() + "</text></wiki_page>";
		
		HttpFile f = new HttpFile("c:/temp/tester.xml");
		f.setUserPass(System.getProperty("redmineUser"),System.getProperty("redminePass"));
		f.setContent(body);
		
		Map<String, String> headerMap = new HashMap<String,String>();
		headerMap.put("Content-Type", "application/xml");
		
		HashMap<String, String> parms = new HashMap<String, String>();
		
		f.put(new URI("https://armatiek-solutions.plan.io/projects/imvertor-publiek/wiki/TestSub.xml"), headerMap, parms);
		System.out.println(f.getStatus());
	}
	
	public static String getCurrentTimeStamp() {
	    SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");//dd/MM/yyyy
	    Date now = new Date();
	    String strDate = sdfDate.format(now);
	    return strDate;
	}
}
