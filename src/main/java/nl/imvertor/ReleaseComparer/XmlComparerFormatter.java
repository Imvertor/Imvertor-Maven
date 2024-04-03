package nl.imvertor.ReleaseComparer;


import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.xmlunit.diff.Comparison;
import org.xmlunit.diff.Comparison.Detail;
import org.xmlunit.diff.ComparisonFormatter;
import org.xmlunit.diff.ComparisonType;
import org.xmlunit.xpath.JAXPXPathEngine;
import org.xmlunit.xpath.XPathEngine;

import nl.imvertor.common.file.XmlFile;

public class XmlComparerFormatter implements ComparisonFormatter {

	private static String nullSignal = "(empty)";
	
	public Document controlDocument;
	public Document testDocument;
	public XPathEngine xpathEngine;
	
	private DocumentBuilderFactory factory;
	private DocumentBuilder builder;
	
	// sommige toevoegingen en verwijderingen betreffen een element met meerdere eigenschappen
	// al die eigenschappen worden gerapppirteerd. Dat hou je tegen door te onthouden welke construct is toegevoegd of verwijderd.
	private String singletonConstruct;
	
	// xmlunit doet de compare op basis van primait de elementnamen in de XML. Zorg ervoor dat die voldoende onderscheidend zijn. 
	// de elementnaam identificeert dus een "onderdeel van het model" waarover in de release notes kan worden gerapporteerd.
	private Pattern elementIdPattern = Pattern.compile("id=\"(.*?)(_TV.*?)?\"");
	
	public XmlComparerFormatter(File controlFile, File testFile) throws Exception {
		super();

        // factory and builder for DOM Documents
        factory = DocumentBuilderFactory.newInstance();
        builder = factory.newDocumentBuilder();

        // Create XPathEngine
        xpathEngine = new JAXPXPathEngine();

		controlDocument = builder.parse(controlFile);
		testDocument = builder.parse(testFile);

	}
	
	@Override
	public String getDescription(Comparison difference) {
		
		String controlDetail = getDetail(difference.getControlDetails(),controlDocument);
		String testDetail = getDetail(difference.getTestDetails(),testDocument);
		
		String[] result = {"","",""};
		
		if (controlDetail.equals(testDetail)) {
			return ""; // geen relevante verandering
		} else if (controlDetail.equals(nullSignal)) {
			result[0] = "ADDED";
			result[2] = testDetail;
			if (!testDetail.contains("value=")) 
				singletonConstruct = getElementName(testDetail);
			else 
				if (ignorable(testDetail)) return "";
		} else if (testDetail.equals(nullSignal)) {
			result[0] = "REMOVED";
			result[1] = controlDetail;
			if (!controlDetail.contains("value=")) 
				singletonConstruct = getElementName(controlDetail);
			else 
				if (ignorable(controlDetail)) return "";
		} else {
			result[0] = "CHANGED";
			result[1] = controlDetail;
			result[2] = testDetail;
			singletonConstruct = "";
			// als de aanpassing wordt gesignalleerd op een <cmp> element, skip 'm. 
			// xmlunit detecteert een aanpassing op een attribuut ook als een aanpassing op het element zelf (soort van "dubbelop").
			if (difference.getControlDetails().getTarget().getNodeType() == Node.ELEMENT_NODE)
				return "";
		}
		return "<res type=\"" + result[0] + "\">" + result[1] + result[2] + "</res>";
	}
	
	@Override
	public String getDetails(Detail details, ComparisonType type, boolean formatXml) {
		// TODO Auto-generated method stub
		return null;
	}
	
	public String getDetail(Detail detail, Document document) {
		String xpath = detail.getXPath();
		
		if (xpath == null) 
			return nullSignal;
		
		Iterable<Node> nodeList = xpathEngine.selectNodes(xpath, document);
		
		String desc = "";
		// Iterate over the nodes - dit is er altijd maar één.
        for (Node node : nodeList) desc += getNodeDescription(node,xpath);
        
		return desc;
	}

	private String getNodeDescription(Node node, String xpath) {
		Short type = node.getNodeType();
		Node descriptor = null;
		// Er worden alleen element en attribute nodes verwacht
		if (type == Node.ELEMENT_NODE) {
			descriptor = node;
		} else if (type == Node.ATTRIBUTE_NODE)
			descriptor = ((Attr) node).getOwnerElement();
		
		NamedNodeMap attributes = descriptor.getAttributes();
		return "<cmp"
			+ " id=\"" + descriptor.getNodeName() + "\"" 
			//+ " xpath=\"" + xpath + "\"" 
			//+ " node=\"" + type + "\"" 
			+ getNodeprop(attributes, "domain") 
			+ getNodeprop(attributes, "domain-stereo") 
			+ getNodeprop(attributes, "class") 
			+ getNodeprop(attributes, "class-stereo") 
			+ getNodeprop(attributes, "attass") 
			+ getNodeprop(attributes, "attass-stereo") 
			+ getNodeprop(attributes, "property")
			+ getNodeprop(attributes, "property-stereo")
			+ getNodeprop(attributes, "value") 
			+ "/>";
		
	}
	
	private String getNodeprop(NamedNodeMap attributes, String prop) {
		Node propNode = attributes.getNamedItem(prop);
		return (propNode != null) ? " " + prop + "=\"" + XmlFile.xmlescape(propNode.getNodeValue()) + "\"" : "";
	}	
	
	private Boolean ignorable(String detail) {
		return (getElementName(detail).equals(singletonConstruct));
	}
	private String getElementName(String detail) {
	    Matcher matcher = elementIdPattern.matcher(detail);
	    matcher.find();
	    return matcher.group(1);
	}
}
