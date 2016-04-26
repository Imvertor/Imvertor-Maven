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
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Set;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;

import net.sf.saxon.Configuration;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.lib.FeatureKeys;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;
import net.sf.saxon.trans.XPathException;

/**
 * An XslFile represents an Xsl stylesheet
 * 
 * The XslFile is an XmlFile and therefore does not access the chain environment.
 *  
 * @author arjan
 *
 */
public class XslFile extends XmlFile {

	private static final long serialVersionUID = -4351737187940152153L;

	protected static final Logger logger = Logger.getLogger(XslFile.class);
	
	private static Configuration saxonConfig = new Configuration();
	private static Processor processor;
	private static XsltCompiler compiler;
	private HashMap<String, String> parms;
	private HashMap<String, String> features;
	
	public XslFile(String pathname) throws TransformerConfigurationException, IOException {
		super(pathname);
		init();
	}
	public XslFile(File file) throws TransformerConfigurationException, IOException {
		super(file.getAbsolutePath());
		init();
	}
	public XslFile(File folder, String filename) throws TransformerConfigurationException, IOException {
		super(folder,filename);
		init();
	}

	public String getFileType() {
		return "XSL";
	}
		
	// XSLFile transforms and XML file.
	
	public void setExtensionFunction(ExtensionFunctionDefinition extension) throws XPathException, TransformerConfigurationException {
		saxonConfig.registerExtensionFunction(extension);
	}
	public void setXIncludeAware(boolean aware) throws XPathException, TransformerConfigurationException {
		saxonConfig.setXIncludeAware(aware);
	}
	
	public void transform(String inputPath, String outputPath) throws Exception {
		transform(new XmlFile(inputPath), new File(outputPath));
	}
	
	/**
	 * Initialize the XSL file. 
	 * This means a base configuration and base transformer.
	 * 
	 * @throws TransformerConfigurationException
	 * @throws IOException 
	 */
	private void init() throws TransformerConfigurationException, IOException {
		getInitialParms();
		getInitialFeatures();
	}
	/**
	 * Return a parms table for XSLT processing holding some initial key/values on the XSLT file.
	 * 
	 * @return
	 * @throws IOException 
	 */
	public HashMap<String, String> getInitialParms() throws IOException {
		parms = new HashMap<String, String>();
		parms.put("system.xslfile.filepath", this.getCanonicalPath());
		parms.put("system.xslfile.datetime", this.getIsoDateTime());
		return parms;
	}
	/**
	 * Return a features table for XSLT processing holding the default features.
	 * 
	 * @return
	 */
	public HashMap<String, String> getInitialFeatures() {
		features = new HashMap<String, String>();
		features.put(FeatureKeys.SUPPRESS_XSLT_NAMESPACE_CHECK, "true");
		return features;
	}
	
	/**
	 * Transform using a parameter set passed as a hashmap, and feature keys passed a a hashmap.
	 * 
	 * Feature keys are described in 
     * http://www.saxonica.com/html/documentation/javadoc/net/sf/saxon/lib/FeatureKeys.html 
     * and 
     * http://www.saxonica.com/html/documentation/configuration/config-features.html and
     * and streamline the transformation.
	 * 
	 * @param infile
	 * @param outfile
	 * @param parms
	 * @throws Exception
	 */
    public void transform(XmlFile infile, File outfile, HashMap<String, String> parms, HashMap<String, String> features) throws Exception {
		
    	logger.debug("Transforming " + this.getCanonicalPath() + " using " + this.getName());
		
    	features = (features == null) ? this.features : features;
    	parms = (parms == null) ? this.parms : parms;
    	
    	if (processor == null) {
    		setXIncludeAware(true);
    		processor = new Processor(saxonConfig);
    		Iterator<String> it = features.keySet().iterator();
    		while (it.hasNext()) {
    			String key = it.next();
    	 		processor.setConfigurationProperty(key, features.get(key)); 
	 	    }
    		compiler = processor.newXsltCompiler();
    	}
    	
    	StreamSource source = new StreamSource(infile);
		StreamSource xslt = new StreamSource(this);
		
		XsltExecutable exec = compiler.compile(xslt);
		XsltTransformer transformer = exec.load();
		
		if (parms != null) {
			Set<Entry<String,String>> entries = parms.entrySet();
		    Iterator<Entry<String, String>> it = entries.iterator();
		    while (it.hasNext()) {
		      Entry<String, String> entry = (Entry<String, String>) it.next();
		      transformer.setParameter(new QName(entry.getKey()), new XdmAtomicValue(entry.getValue()));
		    }
		}
		transformer.setSource(source);
		transformer.setDestination(processor.newSerializer(outfile));
		
		transformer.transform();
	}
    
    /**
     * Transform using default feature keys. 
     * 
     * @param infile
     * @param outfile
     * @throws Exception
     */
     public void transform(XmlFile infile, File outfile,  HashMap<String, String> parms) throws Exception {
    	transform(infile, outfile, parms, null);
    }

     /**
      * Transform using default feature keys and parameter set. 
      * 
      * @param infile
      * @param outfile
      * @throws Exception
      */
      public void transform(XmlFile infile, File outfile) throws Exception {
     	transform(infile, outfile, null, null);
     }	
	
}
