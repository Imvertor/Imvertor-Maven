package nl.imvertor.common.log;

import java.util.Iterator;
import java.util.Vector;

public class XsltCallLogger {

	public static Vector<XsltCallLog> logs;
	
	public XsltCallLogger() {
		logs = new Vector<XsltCallLog>();
	}
	
	public String export() {
		Iterator<XsltCallLog> it = logs.iterator();
		String r = "";
		while (it.hasNext()) {
			XsltCallLog log = it.next();
			r += "<call step=\"" + log.step + "\" input=\"" + log.input + "\" xslt=\"" + log.xslt + "\" output=\"" + log.output + "\" duration=\"" + log.duration + "\"/>";
		}
		return "<calls>" + r + "</calls>";
	}

	public void add(String step, String input, String xslt, String output, Long duration) {
		XsltCallLog log = new XsltCallLog();
		log.step = step;
		log.input = input;
		log.xslt = xslt;
		log.output = output;
		log.duration = duration;
		logs.addElement(log);
	}
	
	private class XsltCallLog {
		public String step;
		public String input;
		public String xslt;
		public String output;
		public Long duration;
	}
}
