/*
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package nl.imvertor.common;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;

import net.sf.saxon.event.PipelineConfiguration;
import net.sf.saxon.event.SequenceWriter;
import net.sf.saxon.om.AxisInfo;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.tree.iter.AxisIterator;
import nl.imvertor.common.wrapper.XMLConfiguration;

/**
 * A Messenger passes messages from XSLT of java top the XML configuration file.
 * The messages are subsequently available for processing by any next step.
 * 
 * 
 * @author arjan
 *
 */
public class Messenger extends SequenceWriter {

	public static final Logger logger = Logger.getLogger(Messenger.class);
	public static final String VC_IDENTIFIER = "$Id: Messenger.java 7431 2016-02-24 12:46:42Z arjan $";

	private String fatalValue = "FATAL";
	private Pattern messagePattern = Pattern.compile("^(.+?): \\[(.+?)\\] (.+?)$");
	
	public Messenger(PipelineConfiguration pcfg) {
		super(pcfg);
	}
	
	@Override
	/**
	 * This method implements writing the contents of an XSLT message to the configuration element "/messages".
	 * 
	 * Each next step in the chain may pick up this messages, e.g. process them for documentation purposes.
	 * 
	 * A message sent out takes the form of a 1/ single string, in which case the string is sent to the system.out stream, 
	 * or 2/ a sequence of specific elements with text content, in which case it is appended to the xml configuration.   
	 *  
	 * A fatal message (FATAL) will result in an exception thrown. This ends the process (and logging).
	 * 
	 */
	public void write(Item item) {
		
		Configurator cfg = Configurator.getInstance();
		Boolean suppresswarnings = cfg.getSuppressWarnings();
		
		Runner runner = cfg.getRunner();

		// deterrmine the document passed in the message
		NodeInfo messageroot = ((NodeInfo) item).getDocumentRoot();
		AxisIterator elements = messageroot.iterateAxis(AxisInfo.CHILD);
		NodeInfo originalChild = (NodeInfo) elements.next();
		NodeInfo child = originalChild;
		NodeInfo sibling = (NodeInfo) elements.next();
		
		// determine the source, text and type of the message, assuming it is a structured message.
		String src = null, name = null, text = null, type = null, id = null, wiki = null;
		String mode = "CHAIN"; // default, may be overridden.
		while (child != null) {
			if (child.getNodeKind() == net.sf.saxon.type.Type.ELEMENT) {
				String elementName = child.getDisplayName();
				String elementValue = child.getStringValue();
				if (elementName.equals("imvert-message:type")) type = elementValue;
				if (elementName.equals("imvert-message:name")) name = elementValue;
				if (elementName.equals("imvert-message:text")) text = elementValue;
				if (elementName.equals("imvert-message:src")) src = elementValue;
				if (elementName.equals("imvert-message:id")) id = elementValue;
				if (elementName.equals("imvert-message:wiki")) wiki = elementValue;
				if (elementName.equals("imvert-message:mode")) mode = elementValue;
					}
			child = sibling;
			sibling = (NodeInfo) elements.next();
		}
		try {
			// Check if this is actually a structured message
			if (src != null) {
				// then signal to screen if needed, and die if fatal
				String ctext = src + ": [" + name + "] " + text;
				
				switch (type) {
					case "FATAL":
						runner.fatal(logger,ctext,null,id,wiki); // The FATAL level designates very severe error events that will presumably lead the application to abort.
						break;  
					case "ERROR":
						runner.error(logger,ctext,id, wiki); // The ERROR level designates error events that might still allow the application to continue running.
						break;  
					case "WARNING":
						if (!suppresswarnings) runner.warn(logger,ctext,id, wiki); // The WARN level designates potentially harmful situations.
						break;  
					case "INFO": 
						runner.info(logger,ctext); // The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
						break;  
					case "DEBUG": // The DEBUG Level designates fine-grained informational events that are most useful to debug an application.
						runner.debug(logger,mode,ctext);
						break;  
					case "TRACE": // The TRACE Level designates finer-grained informational events than the DEBUG 
						runner.trace(logger,ctext);
						break;  
				}
				if (type.equals(fatalValue))
					runner.fatal(logger,src + " - " + text,null,id);
			} else { 
				// otherwise return the string representation immediately, this is the regular XSLT message.
				child = originalChild;
				while (child != null) {
					System.out.println(child.getStringValue());
					child = sibling;
					sibling = (NodeInfo) elements.next();
				}
			}
		} catch (Exception e) {
			// TODO: handle exception
		}
	}
	
	/**
	 * Write a message directly to the configuration file.
	 * This is confined to warnings, errors, and debug in debug mode.
	 * 
	 * @param type
	 * @param text
	 * @param src
	 */
	public void writeMsg(String src, String type, String name, String text, String id, String wiki) {
		if (exists(src) && exists(type) && exists(text)) {
			XMLConfiguration cfg = Configurator.getInstance().getXmlConfiguration();
			if (cfg != null) {
				int messageIndex = cfg.getMaxIndex("messages/message") + 2;   // -1 when no messages.
				cfg.addProperty("messages/message", "");
				cfg.addProperty("messages/message[" + messageIndex + "]/src", src);
				cfg.addProperty("messages/message[" + messageIndex + "]/type", type);
				cfg.addProperty("messages/message[" + messageIndex + "]/name", name);
				cfg.addProperty("messages/message[" + messageIndex + "]/text", text);
				// split up the message 
				Matcher m = messagePattern.matcher(text);
				if (m.matches()) {
					cfg.addProperty("messages/message[" + messageIndex + "]/stepname", m.group(1));
					cfg.addProperty("messages/message[" + messageIndex + "]/stepconstruct", m.group(2));
					cfg.addProperty("messages/message[" + messageIndex + "]/steptext", m.group(3));
				}
				if (id != null) cfg.addProperty("messages/message[" + messageIndex + "]/id", id);
				if (wiki != null) cfg.addProperty("messages/message[" + messageIndex + "]/wiki", wiki);
			}
		}
	}
	public void writeMsg(String src, String type, String name, String text) {
		writeMsg(src, type, name, text, null, null);
	}
	
	private boolean exists(String v) {
		return (v != null) && !v.equals("");
	}
}
