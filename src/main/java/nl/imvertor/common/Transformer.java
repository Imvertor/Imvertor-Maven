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
import java.io.PrintStream;
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
import nl.armatiek.saxon.extensions.http.SendRequest;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.xsl.extensions.ImvertorFileSpec;
import nl.imvertor.common.xsl.extensions.ImvertorMergeParms;
import nl.imvertor.common.xsl.extensions.ImvertorParameterFile;
import nl.imvertor.common.xsl.extensions.ImvertorTrack;

/**
 * This class represents a Saxon based transformer. 
 * 
 * @author arjan
 *
 */

public class Transformer {

	public static final Logger logger = Logger.getLogger(Transformer.class);
	public static final String VC_IDENTIFIER = "$Id: Transformer.java 7487 2016-04-02 07:27:03Z arjan $";
	
	protected static boolean MAYPROFILE = false; // profiling required? then explicitly switch on in the chain!
	
	private ErrorListener errorListener; // vooralsnog null. work in progress?
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
	
	private boolean profiled = false; // this is set irrespective of the MAYPROFILE setting. Both must be true in order for the transformer to profile.
	
	public Transformer() throws Exception {
		super();
		configurator = Configurator.getInstance();
		setXIncludeAware(true);
		processor = new Processor(configurator.getSaxonConfiguration());
		
		compiler = processor.newXsltCompiler();
	
		messageEmitter = configurator.getMessenger();
		outputProperties = new Properties();

		compiler.setURIResolver(configurator.getUriResolver());  // may be based on a filled catalog
		
		// standard extension functions:
		setExtensionFunction(new ImvertorFileSpec());
		setExtensionFunction(new ImvertorParameterFile());
		setExtensionFunction(new ImvertorTrack());
		setExtensionFunction(new ImvertorMergeParms());

		// expath file functions
		//setExtensionFunction(new Copy());
		//setExtensionFunction(new CreateDir());
		//setExtensionFunction(new Delete());
		//setExtensionFunction(new Exists());
		//setExtensionFunction(new IsDir());
		//setExtensionFunction(new Move());
		//setExtensionFunction(new Parent());
		//setExtensionFunction(new PathToURI());
		//setExtensionFunction(new ReadBinary());
		//setExtensionFunction(new ReadText());
		//setExtensionFunction(new ReadTextLines());
		//setExtensionFunction(new Size());
		//setExtensionFunction(new Write());
		//setExtensionFunction(new WriteBinary());
		//setExtensionFunction(new WriteText());
		//setExtensionFunction(new WriteTextLines());
		
		// expath http functions
		setExtensionFunction(new SendRequest());
	}
	
	/**
	 * Specify if the transformer may profile. 
	 * Transformers are profiled, and when a stage has been reached where profiling is not applicable, the profiling may be switched off.
	 *  
	 * @param may
	 */
	public static void setMayProfile(boolean may) {
		MAYPROFILE = may;
	}

	public void setProfiled(Boolean profiled) {
		this.profiled = profiled;
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
	public boolean transform(File infile, File outfile, File xslfile, String alias) throws Exception {

		String task = "Transforming";
		
		configurator.getRunner().debug(logger,"CHAIN",task + " " + infile.getCanonicalPath() + " using " + xslfile.getName());
		
		// first set the profile nature of the compiler
		compiler.setCompileWithTracing(false);
		
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
		String url = (new AnyFile(configurator.getConfigFilepath())).getFilespec("U")[1];
		
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
		transformer.setParameter(new QName("xml-stylesheet-alias"),new XdmAtomicValue(alias));
		// pass on the value of the dlogger URLs. 
		transformer.setParameter(new QName("dlogger-mode"),new XdmAtomicValue(configurator.getServerProperty("dlogger.mode")));
		transformer.setParameter(new QName("dlogger-proxy-url"),new XdmAtomicValue(configurator.getServerProperty("dlogger.proxy.url")));
		transformer.setParameter(new QName("dlogger-viewer-url"),new XdmAtomicValue(configurator.getServerProperty("dlogger.viewer.url")));
		transformer.setParameter(new QName("dlogger-client-name"),new XdmAtomicValue(configurator.getServerProperty("dlogger.client.name")));
			
		
		transformer.setSource(source);
		transformer.setDestination(processor.newSerializer(outfile));

		PrintStream stream = null;
		
		configurator.save(); // may throw exception when config file not avail
		long starttime = System.currentTimeMillis();
		transformer.transform();
		
		if (!outfile.isFile())
			throw new Exception("Transformation did not produce the expected file result " + outfile.getCanonicalPath());
		
		Long duration = (System.currentTimeMillis() - starttime);
		
		Configurator.getInstance().getRunner().debug(logger,"CHAIN","Transformation took " + duration + " msec");
		
		// send to log as to be able to determine the full chain of info through transformations. 
		configurator.getXsltCallLogger().add(configurator.getCurrentStepName(), infile.getName(), xslfile.getName(), outfile.getName(), duration);
		
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
	public boolean transform(String infilePath, String outfilePath, String xslfilePath, String alias) throws Exception {
		File infile, outfile, xslfile;
		infile = new File(infilePath);
		xslfile = new File(xslfilePath);
		if (outfilePath==null) {
			// output is ignored
			outfile = File.createTempFile("Transformer.transform.", ".xml");
			outfile.deleteOnExit();
		} else 
			outfile = new File(outfilePath);
		return transform( infile, outfile, xslfile, alias);
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
		String alias = configurator.getAlias("properties", p[1]);
		p = StringUtils.split(resultParm,"/");
		if (resultParm != null) configurator.setParm(p[0],p[1],outFile, true);
		return transform(inFile, outFile, xslFile, alias);
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
    			transform(xmlFile,new XmlFile(targetFolder,file.getName()), xslFile, null);
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
