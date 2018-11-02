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

package nl.imvertor.common.file;

import java.io.File;
import java.io.FileOutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpHeaders;
import org.apache.log4j.Logger;
import org.custommonkey.xmlunit.DetailedDiff;
import org.custommonkey.xmlunit.Difference;
import org.custommonkey.xmlunit.XMLTestCase;
import org.custommonkey.xmlunit.XMLUnit;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import net.sf.saxon.xpath.XPathFactoryImpl;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.helper.XmlDiff;
import nl.imvertor.common.xsl.extensions.ImvertorCompareXML;

/**
 * An XmlFile represents an XmlFile on the file system.
 * 
 * The XmlFile is an AnyFile and therefore does not access the chain environment.
 *  
 * @author arjan
 *
 */
public class XmlFile extends AnyFile implements ErrorHandler {

	private static final long serialVersionUID = -4351737187940152153L;

	protected static final Logger logger = Logger.getLogger(XmlFile.class);
	
	static final String JAXP_SCHEMA_LANGUAGE = "http://java.sun.com/xml/jaxp/properties/schemaLanguage";
	static final String W3C_XML_SCHEMA = "http://www.w3.org/2001/XMLSchema";

	protected static final String NAMESPACES_FEATURE_ID = "http://xml.org/sax/features/namespaces";
	protected static final String VALIDATION_FEATURE_ID = "http://xml.org/sax/features/validation";
	protected static final String SCHEMA_VALIDATION_FEATURE_ID = "http://apache.org/xml/features/validation/schema";
	protected static final String SCHEMA_FULL_CHECKING_FEATURE_ID = "http://apache.org/xml/features/validation/schema-full-checking";
	protected static final String EXTERNAL_PARAMETER_ENTITIES_ID = "http://xml.org/sax/features/external-parameter-entities";
	protected static final String EXTERNAL_GENERAL_ENTITIES_ID = "http://xml.org/sax/features/external-general-entities";
	protected static final String IGNORE_DTD_FEATURE_ID = "http://apache.org/xml/features/nonvalidating/load-external-dtd"; // http://www.isocra.com/2006/05/making-xerces-ignore-a-dtd/
	protected static final String ALLOW_MULTIPLE_NS_IMPORTS = "http://apache.org/xml/features/honour-all-schemaLocations"; // https://marc.info/?l=xerces-j-dev&m=108734363319300
		
	protected static final String LEXICAL_HANDLER_PROPERTY_ID = "http://xml.org/sax/properties/lexical-handler";
	protected static final String DEFAULT_PARSER_NAME = "org.apache.xerces.parsers.SAXParser";

	protected static final int WFCODE_OKAY = 0;
	protected static final int WFCODE_WARNING = 1;
	protected static final int WFCODE_ERROR = 2;
	protected static final int WFCODE_FATAL = 3;

	// create a pattern that matches <?xml ... ?>
	public static String xmlPiRegex = "<\\?(x|X)(m|M)(l|L).*?\\?>";
		
	// parameters die de verwerking van het XML file bepalen

	public boolean namespace = true; // namespace aware?
	public boolean validate = false; // valideren?
	public boolean xinclude = true; // herken xinclude statements?
	public boolean schema = false; // zoek naar schema bij valideren?
	public boolean schemacheck = false; // schema ook checken?
	public boolean dtd = false; // zoek naar dtd bij valideren?
	public boolean auto = false; // automagically determine how to parse this file?
	public boolean external = false; // externe entiteiten ophalen?
	public boolean inquiry = false; // zoek alleen maar naar informatie over dit file?
	public boolean allownsimports = false; // sta toe dat dezelfde namespace in meerdere schemas worden gedeclareerd

	private Document dom = null;
	
	private int wfcode = WFCODE_OKAY; // a code indicating the Wellformedness of the XML file.
	private String lastError = "";
	
	private Vector<String> messages = new Vector<String>();
	
	public static void main(String[] args) throws Exception {
		
		//XmlFile file = new XmlFile("D:\\projects\\arjan\\Java development\\CommonHandlers\\sandbox\\EHcache\\config\\ehcache.xml");
	
		/*
	    XmlFile file = new XmlFile("D:\\projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-work\\KING-comply-extract\\app\\tests\\npsla09-1.xml");
	    System.out.println(file.isValid());
		file.getMessages();
		*/		
		JsonFile jfile1, jfile2;
		XmlFile xfile;
		
		jfile1 = new JsonFile("D:\\projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-work\\Tasks-Kadaster-JIRA\\app\\yaml\\20150101-2.0.json");
		jfile2 = new JsonFile("D:\\projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-work\\Tasks-Kadaster-JIRA\\app\\yaml\\20150101-2.0.roundtrip.json");
		xfile = new XmlFile("D:\\projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-work\\Tasks-Kadaster-JIRA\\app\\yaml\\20150101-2.0.json.xml");
		jfile1.jsonToXml(xfile);
		xfile.xmltoJson(jfile2);
		
		jfile1 = new JsonFile("D:\\projects\\validprojects\\Kadaster-Imvertor\\Imvertor-OS-testing\\trunk\\input\\eap\\Kadaster\\MIM2Json\\Omgevingswet poging 12 september(CLEAN).json");
		jfile2 = new JsonFile("c:\\temp\\jfile2.json");
		xfile = new XmlFile("c:\\temp\\jfile1.json.xml");
		jfile1.jsonToXml(xfile);
		xfile.xmlToJson(jfile2);
				
	}
	
	public XmlFile(String pathname) {
		super(pathname);
	}
	public XmlFile(File file) {
		super(file.getAbsolutePath());
	}
	public XmlFile(File folder, String filename) {
		super(folder,filename);
	}

	public String getFileType() {
		return "XML";
	}
		
	
	/**
	 * Lees een file in naar een DOM Document.
	 * 
	 * @param file
	 * @return
	 * @throws Exception
	 */
	public Document toDocument() throws Exception {
		Document d = buildDom();
		return d;
	}

	/**
	 * Zet een Document weg als file. Transformeer middels het XSLT file. Als
	 * XSLT file is "", identity transform.
	 * 
	 * @param doc
	 * @param xsltfile
	 * @param parms
	 * @throws Exception
	 */
	public void fromDocument(Document doc) throws Exception {
		DOMImplementationRegistry registry = DOMImplementationRegistry.newInstance();    
		DOMImplementationLS impl = (DOMImplementationLS) registry.getDOMImplementation("XML 3.0 LS 3.0");
		if (impl == null) {
			System.out.println("No DOMImplementation found !");
			System.exit(0);
		}
		LSSerializer serializer = impl.createLSSerializer();
		LSOutput output = impl.createLSOutput();
		output.setEncoding("UTF-8");
		output.setByteStream(new FileOutputStream(this));
		serializer.write(doc, output);
	}

	/**
	 * Build a DOM Document representation of this XML file. 
	 * 
	 * @return
	 * @throws Exception
	 */
	private Document buildDom() throws Exception {
		return this.buildDom(this);
	}
	
	/**
	 * Build a DOM Document representation of some external XML file. 
	 * 
	 * @return
	 * @throws Exception
	 */
	private Document buildDom(File file) throws Exception {
		
		DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
		InputSource in = new InputSource(file.getAbsolutePath());
		
		docFactory.setValidating(validate);
		docFactory.setXIncludeAware(xinclude);
		docFactory.setFeature(VALIDATION_FEATURE_ID, validate);
		docFactory.setFeature(NAMESPACES_FEATURE_ID, namespace);
		docFactory.setFeature(SCHEMA_VALIDATION_FEATURE_ID, schema);
		docFactory.setFeature(SCHEMA_FULL_CHECKING_FEATURE_ID, schemacheck);
		docFactory.setFeature(EXTERNAL_GENERAL_ENTITIES_ID, external);
		docFactory.setFeature(EXTERNAL_PARAMETER_ENTITIES_ID, external);
		docFactory.setFeature(ALLOW_MULTIPLE_NS_IMPORTS, allownsimports);
		
		DocumentBuilder db = docFactory.newDocumentBuilder();
		return db.parse(in);
	}
	
	public Document getDom() throws Exception {
		if (dom == null) 
			return buildDom(this);
		else 
			return dom;
	}
	
	/**
	 * Benader de inhoud dmv. een Xpath expressie. Geef het laatste item die aan het criterium voldoet af als String.
	 * 
	 * @param outfile
	 * @param xslFilePath
	 * @throws Exception
	 */
	public String xpath(String expression, HashMap<String, String> parms) throws Exception {
		return (String) xpathToObject(expression, parms, XPathConstants.STRING);
	}
	
	/**
	 * Benader de inhoud dmv. een Xpath expressie.  
	 * 
	 * @param outfile
	 * @param xslFilePath
	 * @throws Exception
	 */
	public Object xpathToObject(String expression, HashMap<String, String> parms, QName returnType) throws Exception {
		if (dom == null) dom = this.buildDom();
		XPathFactoryImpl xpf = new XPathFactoryImpl();
		XPath xpe = xpf.newXPath();
	    XPathExpression find = xpe.compile(expression);
	    return find.evaluate(dom, returnType);
	}

	public String xpath(String expression) throws Exception {
		return xpath(expression,new HashMap<String,String>());
	}
	
	/** 
	 * Transform the XML file to a canonical form
	 * 
	 * @param outfile
	 * @param xslFile
	 * @param parms
	 * @throws Exception
	 */
	public void fileToCanonicalFile(XmlFile outfile) throws Exception {
 		logger.debug("Canonizing " + this.getCanonicalPath());
		if (dom == null) dom = this.buildDom();
		outfile.fromDocument(dom);
	}
		
	public boolean isWellFormed() {
		messages.removeAllElements();
		try {
			wfcode = WFCODE_OKAY;
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			factory.setValidating(false);
			factory.setNamespaceAware(true);
			factory.setXIncludeAware(true);
			
			DocumentBuilder builder = factory.newDocumentBuilder();
	
			builder.setErrorHandler(this);   
			// must create URL because of strange file name character such as [ and ]
			String url = this.toURI().toURL().toString();
			builder.parse(new InputSource(url));
			
		} catch (Exception e) {
			lastError = e.getMessage();
			wfcode = WFCODE_FATAL;
		}
		return wfcode < WFCODE_ERROR;
	}
	
	public boolean isValid() {
		messages.removeAllElements();
		try {
			wfcode = WFCODE_OKAY;
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			factory.setValidating(true);
			factory.setNamespaceAware(true);
			factory.setXIncludeAware(true);
			factory.setAttribute(
				    "http://java.sun.com/xml/jaxp/properties/schemaLanguage",
				    "http://www.w3.org/2001/XMLSchema");
	
			DocumentBuilder builder = factory.newDocumentBuilder();
	
			builder.setErrorHandler(this);    
			// must create URL because of strange file name character such as [ and ]
			String url = this.toURI().toURL().toString();
			builder.parse(new InputSource(url));
		} catch (Exception e) {
			lastError = e.getMessage();
			wfcode = WFCODE_FATAL;
		}
		return wfcode < WFCODE_ERROR;
	}
	
	public Vector<String> getMessages() {
		return messages;
	}
	
	public String getLastError() {
		return lastError;
	}
	
	/**
	 * Compare this control file to the passed test file, store result in file. Return true if files are the same.
	 * 
	 * Difference types are listed as constants in 
	 * <a href="http://xmlunit.sourceforge.net/api/org/custommonkey/xmlunit/DifferenceConstants.html">here</a>
	 * 
	 * @param controlXmlPath
	 * @param testXmlPath
	 * @param resultPath
	 * @return
	 * @throws Exception
	 */
	public boolean xmlUnitCompareXML(XmlFile testXmlFile, XmlFile resultFile, Integer maxReported) throws Exception {
		XmlFile controlXmlFile = this;
		
		XMLUnit.setCompareUnmatched(false);
		XMLTestCase testcase = new Case(this.getName());
		
		DetailedDiff myDiff = new DetailedDiff(testcase.compareXML(controlXmlFile.getContent(), testXmlFile.getContent()));
        
		@SuppressWarnings("unchecked")
		List<Difference> allDifferences = myDiff.getAllDifferences();
        Iterator<Difference> it = allDifferences.iterator();
        String analysis = "<diffs>";
        int cnt = 0;
        while (it.hasNext() && cnt < maxReported) {
        	Difference d = it.next();
           	analysis += "<diff"
        			+ " desc=\"" + safe(d.getDescription()) + "\""
        			+ ">";
           	analysis += "<ctrl"
        			+ " path=\"" + d.getControlNodeDetail().getXpathLocation() + "\""
        			+ " value=\"" + safe(d.getControlNodeDetail().getValue()) + "\""
        			+ "/>";
           	analysis += "<test"
        			+ " path=\"" + d.getTestNodeDetail().getXpathLocation() + "\""
        			+ " value=\"" + safe(d.getTestNodeDetail().getValue()) + "\""
        			+ "/>";
            analysis += "</diff>";
            cnt += 1;
        }
        analysis += "</diffs>";
        resultFile.setContent(analysis);
    	return (allDifferences.size() == 0) ? true: false;
    }
	
	/** 
	 * Replace special characters in XML string.
	 * 
	 * @param s
	 * @return
	 */
	private String safe(String s) {
     	s = StringUtils.replace(s,"&","&amp;");
     	s = StringUtils.replace(s,"<","&lt;");
     	s = StringUtils.replace(s,">","&gt;");
     	s = StringUtils.replace(s,"\"","&quot;");
    	return s;
    }
	    
	/**
	 * Introduce the XmlFile class as a valid JUnit TestCase class.
	 * 
	 * @author arjan
	 *
	 */
	private class Case extends XMLTestCase {
    	
    	public Case(String name) {
            super(name);
        }
    	
    }	
	
	@Override
	public void error(SAXParseException exception) throws SAXException {
		messages.add("(" + getName() + ")" + exception.getMessage());
		wfcode = WFCODE_ERROR;
	}
	@Override
	public void fatalError(SAXParseException exception) throws SAXException {
		messages.add("(" + getName() + ")" + exception.getMessage());
		wfcode = WFCODE_FATAL;
	}
	@Override
	public void warning(SAXParseException exception) throws SAXException {
		messages.add("(" + getName() + ")" + exception.getMessage());
        wfcode = WFCODE_WARNING;
	}

	public static String xmlescape(String s) {
		s = s.replace("&", "&amp;");
		s = s.replace("<", "&lt;");
		return s;
	}
	
	/**
	 * See IM-147 Documentatie release ondersteunen.
	 * 
	 * This method compares the current XML file to any other XML file. Results are written to a listing XML file.
	 * 
	 * This XML file is the control XML file, and is compared to test XML file.
	 * 
	 * @return
	 * @throws Exception
	 */
	public boolean compare(XmlFile testXmlFile, Configurator configurator) throws Exception {
		
		String compareLabel = configurator.getXParm("system/compare-label");
		String compareKey = configurator.getXParm("cli/comparekey",false);
		if (compareKey == null) compareKey = "name";
		
		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorCompareXML());
		
		Boolean valid = true;
		
		//TODO Duplicate, redundant?
		XmlFile ctrlNameFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_CONTROL_NAME_FILE")); // imvertor.20.docrelease.1.1.compare-control-name.xml
		XmlFile testNameFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_TEST_NAME_FILE")); // imvertor.20.docrelease.1.2.compare-test-name.xml
		XmlFile infoConfig   = new XmlFile(configurator.getXParm("properties/IMVERTOR_COMPARE_CONFIG")); // Imvert-compare-config.xml
	
		// This transformer will pass regular XML parameters to the stylesheet. 
		// This is because the compare core code is not part of the Imvertor framework, but developed separately.
		// We therefore do not use the XMLConfiguration approach here.
		transformer.setXslParm("compare-key", compareKey); // the name or id specifies how teo determine "the same" construct
	
		
		transformer.setXslParm("info-config", infoConfig.toURI().toString());  
		transformer.setXslParm("info-ctrlpath", this.getCanonicalPath());  
		transformer.setXslParm("info-testpath", "(test path)");  

		transformer.setXslParm("compare-label", compareLabel);
		
		// determine temporary files
		XmlFile controlModelFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_CONTROL_MODEL_FILE")); // imvertor.20.docrelease.1.1.compare-control-model.xml
		XmlFile testModelFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_TEST_MODEL_FILE")); // imvertor.20.docrelease.1.2.compare-test-model.xml
		XmlFile controlSimpleFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_CONTROL_SIMPLE_FILE")); // imvertor.20.docrelease.1.1.compare-control-simple.xml
		XmlFile testSimpleFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_TEST_SIMPLE_FILE")); // imvertor.20.docrelease.1.2.compare-test-simple.xml
		
		XmlFile diffXml = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_DIFF_FILE")); // imvertor.20.docrelease.2.compare-diff.xml
		XmlFile listingXml = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_LISTING_FILE")); // imvertor.20.docrelease.3.compare-listing.xml
			
		XslFile tempXsl = new XslFile(configurator.getXParm("properties/COMPARE_GENERATED_XSLPATH"));
		
		//clean 
		XslFile cleanerXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_CLEAN_XSLPATH"));
		XslFile simpleXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_SIMPLE_XSLPATH"));
		
		valid = valid && transformer.transform(this,controlModelFile,cleanerXsl,null);
		valid = valid && transformer.transform(testXmlFile,testModelFile,cleanerXsl,null);
		
		// simplify
		transformer.setXslParm("ctrl-name-mapping-filepath", ctrlNameFile.toURI().toString()); // file:/D:/.../Imvertor-OS-work/imvert/imvertor.20.compare-control-name.xml
		transformer.setXslParm("test-name-mapping-filepath", testNameFile.toURI().toString());
		
		transformer.setXslParm("comparison-role", "ctrl");
		valid = valid && transformer.transform(controlModelFile,controlSimpleFile,simpleXsl,null);
		transformer.setXslParm("comparison-role", "test");
		valid = valid && transformer.transform(testModelFile,testSimpleFile,simpleXsl,null);
		
		// compare 
		XslFile compareXsl = new XslFile(configurator.getXParm("properties/COMPARE_GENERATOR_XSLPATH"));
		
		transformer.setXslParm("ctrl-filepath", controlSimpleFile.getCanonicalPath());
		transformer.setXslParm("test-filepath", testSimpleFile.getCanonicalPath());
		transformer.setXslParm("diff-filepath", diffXml.getCanonicalPath());
		
		valid = valid && transformer.transform(controlSimpleFile, tempXsl, compareXsl,null);
		
		// create listing
		XslFile listingXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_LISTING_XSLPATH"));
		valid = valid && transformer.transform(controlSimpleFile,listingXml,listingXsl,null);
		
		// get the number of differences found
		int differences = ((NodeList) listingXml.xpathToObject("/*:report/*:diffs/*",null,XPathConstants.NODESET)).getLength();
		configurator.setXParm("appinfo/compare-differences-" + compareLabel, differences);

		// Build report
		boolean result = valid && (differences == 0);
	
		return result;
	}
	
	/**
	 * Compare two files based on XML diff REST interface.
	 * 
	 * @param testXmlFile
	 * @param configurator
	 * @return
	 * @throws Exception
	 */
	public boolean compareXMLDiff(XmlFile testXmlFile, Configurator configurator) throws Exception {
		
		String compareLabel = configurator.getXParm("system/compare-label");
		String compareKey = configurator.getXParm("cli/comparekey",false);
		if (compareKey == null) compareKey = "name";
		
		// create a transformer
		Transformer transformer = new Transformer();
		
		Boolean valid = true;
		
		//TODO Duplicate, redundant?
		XmlFile ctrlNameFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_CONTROL_NAME_FILE")); // imvertor.20.docrelease.1.1.compare-control-name.xml
		XmlFile testNameFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_TEST_NAME_FILE")); // imvertor.20.docrelease.1.2.compare-test-name.xml
		XmlFile infoConfig   = new XmlFile(configurator.getXParm("properties/IMVERTOR_COMPARE_CONFIG")); // Imvert-compare-config.xml
	
		// This transformer will pass regular XML parameters to the stylesheet. 
		// This is because the compare core code is not part of the Imvertor framework, but developed separately.
		// We therefore do not use the XMLConfiguration approach here.
		transformer.setXslParm("compare-key", compareKey); // the name or id specifies how to determine "the same" construct
		
		transformer.setXslParm("info-config", infoConfig.toURI().toString());  
		transformer.setXslParm("info-ctrlpath", this.getCanonicalPath());  
		transformer.setXslParm("info-testpath", "(test path)");  

		transformer.setXslParm("compare-label", compareLabel);
		
		// determine temporary files
		XmlFile controlModelFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_CONTROL_MODEL_FILE")); // imvertor.20.docrelease.1.1.compare-control-model.xml
		XmlFile testModelFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_TEST_MODEL_FILE")); // imvertor.20.docrelease.1.2.compare-test-model.xml
		XmlFile controlSimpleFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_CONTROL_SIMPLE_FILE")); // imvertor.20.docrelease.1.1.compare-control-simple.xml
		XmlFile testSimpleFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_TEST_SIMPLE_FILE")); // imvertor.20.docrelease.1.2.compare-test-simple.xml
		
		XmlFile diffXml = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_DIFF_FILE")); // imvertor.20.docrelease.2.compare-diff.xml
		XmlFile listingXml = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_LISTING_FILE")); // imvertor.20.docrelease.3.compare-listing.xml
			
		//clean 
		XslFile cleanerXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_CLEAN_XSLPATH"));
		XslFile simpleXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_SIMPLE_XSLPATH"));
		
		valid = valid && transformer.transform(this,controlModelFile,cleanerXsl,null);
		valid = valid && transformer.transform(testXmlFile,testModelFile,cleanerXsl,null);
		
		// simplify
		transformer.setXslParm("ctrl-name-mapping-filepath", ctrlNameFile.toURI().toString()); // file:/D:/.../Imvertor-OS-work/imvert/imvertor.20.compare-control-name.xml
		transformer.setXslParm("test-name-mapping-filepath", testNameFile.toURI().toString());
		
		transformer.setXslParm("comparison-role", "ctrl");
		valid = valid && transformer.transform(controlModelFile,controlSimpleFile,simpleXsl,null);
		transformer.setXslParm("comparison-role", "test");
		valid = valid && transformer.transform(testModelFile,testSimpleFile,simpleXsl,null);
		
		// compare 
		callXmlDiff(controlSimpleFile, testSimpleFile, diffXml);
		
		// create listing
		XslFile listingXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_XMLDIFF_XSLPATH"));
		valid = valid && transformer.transform(diffXml,listingXml,listingXsl,null);
		
		// get the number of differences found
		int differences = ((NodeList) listingXml.xpathToObject("/*/*",null,XPathConstants.NODESET)).getLength();
		configurator.setXParm("appinfo/compare-differences-" + compareLabel, differences);

		// Build report
		boolean result = valid && (differences == 0);
	
		return result;
	}
	
	public void callXmlDiff(XmlFile docA, XmlFile docB, XmlFile docResult) throws Exception {
			
			URI url = new URI(Configurator.getInstance().getServerProperty("xmldiff.url"));
			
			XmlDiff xmlDiff = new XmlDiff(url.toString());	
			xmlDiff.compare(docA, docB, docResult);

	}
	
	/*
	 * Replace this file by a pretty printed form
	 */
	public void prettyPrintXml(boolean hasMixedContent) throws Exception {
		XslFile prettyPrinter = new XslFile(Configurator.getInstance().getBaseFolder(),"xsl/common/tools/PrettyPrinter.xsl");
		Transformer transformer = new Transformer();
		transformer.setXslParm("xml-mixed-content",(hasMixedContent) ? "true" : "false");
		
		// Create a temporary file 
		AnyFile tmpFile = new AnyFile(File.createTempFile("prettyPrintXml.", ".xml"));
		transformer.transform(this, tmpFile, prettyPrinter,"PRETTYPRINTER");
		tmpFile.copyFile(this);
		tmpFile.delete();
	}
	
	public void xmlToJson(JsonFile targetFile) throws Exception {
    	targetFile.setContent(JsonFile.xmlToJson(getContent()));
    }

}
