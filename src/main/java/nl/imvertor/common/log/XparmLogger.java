package nl.imvertor.common.log;

import java.util.Iterator;
import java.util.Stack;
import java.util.Vector;

import nl.imvertor.common.file.XmlFile;

public class XparmLogger {

	public static Vector<XparmLog> logs;
	
	public static Stack<String> origin; 
	
	public XparmLogger() {
		logs = new Vector<XparmLog>();
		origin = new Stack<String>();
		origin.push("#CHAIN");
	}
	
	public String export() {
		Iterator<XparmLog> it = logs.iterator();
		String r = "";
		while (it.hasNext()) {
			XparmLog log = it.next();
			r += "<xparm origin=\"" + log.origin + "\" name=\"" + log.name + "\" value=\"" + log.value + "\" replace=\"" + log.replace + "\"/>";
		}
		return "<xparms>" + r + "</xparms>";
	}

	public void openOrigin(String origin) {
		XparmLogger.origin.push(origin);
	}
	
	public void closeOrigin() {
		XparmLogger.origin.pop();
	}
	
	public void add(String name, String value, Boolean replace) {
		XparmLog log = new XparmLog();
		log.origin = origin.peek();
		log.name = name;
		log.value = XmlFile.xmlescape(value);
		log.replace = replace;
		logs.addElement(log);
	}
	
	private class XparmLog {
		public String origin;
		public String name;
		public String value;
		public Boolean replace;
	}
}
