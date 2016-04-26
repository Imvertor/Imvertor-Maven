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

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import com.sun.org.apache.xml.internal.resolver.CatalogManager;
import com.sun.org.apache.xml.internal.resolver.tools.CatalogResolver;

import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.xsl.extensions.ImvertorFileSpec;
import nl.imvertor.common.xsl.extensions.ImvertorParameterFile;

/**
 * This class represents a Saxon based transformer. 
 * 
 * @author arjan
 *
 */

public class Transformer {

	public static final Logger logger = Logger.getLogger(Transformer.class);
	public static final String VC_IDENTIFIER = "$Id: Transformer.java 7487 2016-04-02 07:27:03Z arjan $";
	
	private ErrorListener errorListener;
	private Messenger messageEmitter;

	private static Processor processor;
	private static XsltCompiler compiler;
	
	private Properties outputProperties;

	private String stylesheetIdentifier;
	
	private Configurator configurator;

	private HashMap<String,String> parms = new HashMap<String,String>();

	private File infile;
	private File outfile;
	private File xslfile;
	
	public Transformer() throws Exception {
		super();
		configurator = Configurator.getInstance();
		setXIncludeAware(true);
		processor = new Processor(configurator.getSaxonConfiguration());
		
		if (System.getProperty("xml.catalog") != null) {
			// OASIS catalog support
			String catalog = System.getProperty("xml.catalog");
			CatalogManager manager = CatalogManager.getStaticManager();
			
			CatalogResolver resolver = new CatalogResolver(manager); // note that CatalogManager.properties must be on the classpath!
			resolver.getCatalog().parseCatalog(catalog);
			compiler.setURIResolver(resolver);
		}
		
		compiler = processor.newXsltCompiler();
		compiler.setErrorListener(errorListener); // for compile time errors
		messageEmitter = configurator.getMessenger();
		outputProperties = new Properties();
		
		// standard extension functions:
		setExtensionFunction(new ImvertorFileSpec());
		setExtensionFunction(new ImvertorParameterFile());
	}
	
	/**
	 * Set an XML parameter. This is passed in each call. 
	 * 
	 * Imvertor stepping is based on reading the XML Configuration file. 
	 * For specific purposes, regular XSL parameters may be passed directly.
	 *  
	 * @param name
	 * @param value
	 */
	public void setXslParm(String name, String value) {
		parms.put(name,value);
	}
	
	/**
	 * Set output properties for this transformer. 
	 * 
	 * see http://www.saxonica.com/documentation/javadoc/net/sf/saxon/lib/SaxonOutputKeys.html
	 * 
	 * examples:
	 * 	transformer.setOutputProperty(OutputKeys.METHOD, "xml");
	 * 	transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
	 * 	transformer.setOutputProperty(OutputKeys.INDENT, "no");
	 * 	transformer.setOutputProperty(OutputKeys.MEDIA_TYPE, "text/xml");
	 * @param key
	 * @param value
	 */
	public void setOutputProperty(String key, String value) {
		outputProperties.setProperty(key, value);
	}
		
	/**
	 * Transform a file, write to a result file, using the xsl file passed.
	 * 
	 * @param infile
	 * @param outfile
	 * @param xslfile
	 * @return
	 * @throws Exception
	 */
	public boolean transform(File infile, File outfile, File xslfile) throws Exception {

		logger.debug("Transforming " + infile.getCanonicalPath() + " using " + xslfile.getName());

		// record for later inspection
		this.infile = infile;
		this.outfile = outfile;
		this.xslfile = xslfile;
		
		if (!infile.isFile())
			throw new Exception("No such input file: " + infile.getCanonicalPath());
		if (!xslfile.isFile())
			throw new Exception("No such XSL file: " + xslfile.getCanonicalPath());
		
		StreamSource source = new StreamSource(infile);
		StreamSource xslt = new StreamSource(xslfile);

		XsltExecutable exec = compiler.compile(xslt);
		XsltTransformer transformer = exec.load();
		
		transformer.getUnderlyingController().setMessageEmitter(messageEmitter);
		
		if (errorListener != null)
			transformer.setErrorListener(errorListener); // for runtime errors
		if (outputProperties != null) {
			for (String key : outputProperties.stringPropertyNames()) {
				String value = outputProperties.getProperty(key);      
			    transformer.setParameter(new QName(key), new XdmAtomicValue(value));
			}
		}
		String url = (new AnyFile(configurator.getConfigFilepath())).getFilespec()[1];
		
		// pass all parameters if available to the transformer
		Iterator<Entry<String,String>> it = parms.entrySet().iterator();
		while (it.hasNext()) {
			Entry<String,String> e = it.next();
			transformer.setParameter(new QName(e.getKey().toString()),new XdmAtomicValue(e.getValue().toString()));
		}
		transformer.setParameter(new QName("xml-configuration-url"),new XdmAtomicValue(url));
		transformer.setParameter(new QName("xml-input-name"),new XdmAtomicValue(infile.getName()));
		transformer.setParameter(new QName("xml-output-name"),new XdmAtomicValue(outfile.getName()));
		transformer.setParameter(new QName("xml-stylesheet-name"),new XdmAtomicValue(xslfile.getName()));
		transformer.setSource(source);
		transformer.setDestination(processor.newSerializer(outfile));
		
		configurator.save(); // may throw exception when config file not avail
		transformer.transform();
		if (!outfile.isFile())
			throw new Exception("Transformation did not produce the expected file result " + outfile.getCanonicalPath());
		
		return (configurator.forceCompile() || configurator.getRunner().getFirstErrorText(stylesheetIdentifier) == null);

	}
	
	/**
	 * Transform a file, write to a result file, using the xsl file passed.
	 * Provide string file paths.
	 * 
	 * @param infilePath
	 * @param outfilePath
	 * @param xslfilePath
	 * @return
	 * @throws Exception
	 */
	public boolean transform(String infilePath, String outfilePath, String xslfilePath) throws Exception {
		File infile, outfile, xslfile;
		infile = new File(infilePath);
		xslfile = new File(xslfilePath);
		if (outfilePath==null) {
			// output is ignored
			outfile = File.createTempFile("Transformer.transform.", ".xml");
			outfile.deleteOnExit();
		} else 
			outfile = new File(outfilePath);
		return transform( infile, outfile, xslfile );
	}

	/**
	 * Perform a transformation on the configuration parameters passed.
	 * The string passed takes the form a/b where a is group name and b parameter name 
	 * When resultname is passed, record the XML configuration parameter system/[resultname] which can be used to access that result file in the next step.  
	 * 
	 * @throws Exception 
	 */
	
	public boolean transformStep(String infileParm, String outfileParm, String xslfileParm, String resultParm) throws Exception {
		Configurator configurator = Configurator.getInstance();
		String[] p;
		p = StringUtils.split(infileParm,"/");
		String inFile = configurator.getParm(p[0],p[1]);
		p = StringUtils.split(outfileParm,"/");
		String outFile = configurator.getParm(p[0],p[1]);
		p = StringUtils.split(xslfileParm,"/");
		String xslFile = configurator.getXslPath(configurator.getParm(p[0],p[1]));
		p = StringUtils.split(resultParm,"/");
		if (resultParm != null) configurator.setParm(p[0],p[1],outFile, true);
		return transform(inFile, outFile, xslFile);
	}
	
	public boolean transformStep(String infileParm, String outfileParm, String xslfileParm) throws Exception {
		return transformStep(infileParm, outfileParm, xslfileParm, null);
	}
	
	
	/**
	 * Transform files in a folder (and subfolders) by applying a stylesheet; store the results in the target (sub)folder.
	 * Any file that doesn't match the file name pattern is copied as-is.
	 * 
	 * @param sourceFolder
	 * @param targetFolder
	 * @param nameRegExp
	 * @param xslFile
	 * @param param
	 * @throws Exception
	 */
	public void transformFolder(AnyFolder sourceFolder, AnyFolder targetFolder, String nameRegExp, XslFile xslFile) throws Exception {
		String filePath = sourceFolder.getAbsolutePath();
		File startDir = new File(filePath);
		Pattern pattern = Pattern.compile(nameRegExp);
		File[] filesAndDirs = startDir.listFiles();
	    List<File> filesDirs = Arrays.asList(filesAndDirs);
	    for (File file : filesDirs) {
    		Matcher matcher = pattern.matcher(file.getName());
    		if (matcher.find() && file.isFile()) {
    			// transform
    			XmlFile xmlFile = new XmlFile(file);
    			transform(xmlFile,new XmlFile(targetFolder,file.getName()), xslFile);
    		} else if (file.isDirectory()) {
    			// create target directory an process that
    			AnyFolder subFolder = new AnyFolder(targetFolder,file.getName());
    			subFolder.mkdir();
    			transformFolder(new AnyFolder(file), subFolder, nameRegExp, xslFile);
			} else 
    			// make a normal copy
    			(new AnyFile(file)).copyFile(targetFolder);
	    }
	}
	
	/**
	 * Define an extension function for this transformer
	 * 
	 * @param extension
	 * @throws XPathException
	 * @throws TransformerConfigurationException
	 */
    public void setExtensionFunction(ExtensionFunctionDefinition extension) throws XPathException, TransformerConfigurationException {
		configurator.getSaxonConfiguration().registerExtensionFunction(extension);
	}
    
	/**
	 * XML input documents may or may not use XInclude
	 * 
	 * @param aware
	 * @throws XPathException
	 * @throws TransformerConfigurationException
	 */
    public void setXIncludeAware(boolean aware) throws XPathException, TransformerConfigurationException {
		configurator.getSaxonConfiguration().setXIncludeAware(aware);
	}
    
    /**
     * Return a String from a Saxon sequence passed as an argument  
     * 
     * @param argument
     * @return
     * @throws XPathException
     */
	public static String getStringvalue(Sequence argument) throws XPathException {
		if (argument == null) return null;
		StringValue v = (StringValue) argument.head();
		return (v != null) ? v.getStringValue() : null;
	}
	
	public File getSourceFile() {
		return infile;
	}
	public File getResultFile() {
		return outfile;
	}
	public File getXslFile() {
		return xslfile;
	}
}
